//
//  Components+Locatable.swift
//  
//
//  Created by Mathew Polzin on 3/30/20.
//

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
