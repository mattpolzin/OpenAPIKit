//
//  Components+Locatable.swift
//  
//
//  Created by Mathew Polzin on 3/30/20.
//

import OpenAPIKitCore

/// Anything conforming to ComponentDictionaryLocatable knows
/// where to find resources of its type in the Components Dictionary.
public protocol ComponentDictionaryLocatable {
    /// The JSON Reference path of this type.
    ///
    /// This can be used to create a JSON path
    /// like `#/name1/name2/name3`
    static var openAPIComponentsKey: String { get }
    static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { get }
}

extension JSONSchema: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "schemas" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.schemas }
}

extension OpenAPI.Response: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "responses" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.responses }
}

extension OpenAPI.Callbacks: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "callbacks" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.callbacks }
}

extension OpenAPI.Parameter: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "parameters" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.parameters }
}

extension OpenAPI.Example: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "examples" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.examples }
}

extension OpenAPI.Request: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "requestBodies" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.requestBodies }
}

extension OpenAPI.Header: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "headers" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.headers }
}

extension OpenAPI.SecurityScheme: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "securitySchemes" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.securitySchemes }
}

/// A dereferenceable type can be recursively looked up in
/// the `OpenAPI.Components` until there are no `JSONReferences`
/// left in it or any of its properties.
public protocol LocallyDereferenceable {
    associatedtype DereferencedSelf

    /// Remove all references from `self` by looking up each reference
    /// in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    ///
    ///     Can also throw `ReferenceCycleError` if a reference
    ///     cycle is encountered while dereferencing this component.
    func dereferenced(in components: OpenAPI.Components) throws -> DereferencedSelf

    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> DereferencedSelf
}

extension LocallyDereferenceable {
    // default implementation of public `dereferenced(in:)` based on internal
    // method that tracks reference cycles.
    public func dereferenced(in components: OpenAPI.Components) throws -> DereferencedSelf {
        try _dereferenced(in: components, following: [])
    }
}
