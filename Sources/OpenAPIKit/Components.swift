//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import OrderedDictionary

extension OpenAPI {
    /// What the spec calls the "Components Object".
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable {

//        @ComponentDictionary
        public var schemas: OrderedDictionary<String, JSONSchema>

//        @ComponentDictionary
        public var responses: OrderedDictionary<String, Response>

//        @ComponentDictionary
        public var parameters: OrderedDictionary<String, PathItem.Parameter>

//        @ComponentDictionary
        public var examples: OrderedDictionary<String, Example>

//        @ComponentDictionary
        public var requestBodies: OrderedDictionary<String, Request>

//        @ComponentDictionary
        public var headers: OrderedDictionary<String, Header>

//        @ComponentDictionary
        public var securitySchemes: OrderedDictionary<String, SecurityScheme>
        //    public var links:
        //    public var callbacks:

        public init(schemas: OrderedDictionary<String, JSONSchema> = [:],
                    responses: OrderedDictionary<String, Response> = [:],
                    parameters: OrderedDictionary<String, PathItem.Parameter> = [:],
                    examples: OrderedDictionary<String, Example> = [:],
                    requestBodies: OrderedDictionary<String, Request> = [:],
                    headers: OrderedDictionary<String, Header> = [:],
                    securitySchemes: OrderedDictionary<String, SecurityScheme> = [:]) {
            self.schemas = schemas
            self.responses = responses
            self.parameters = parameters
            self.examples = examples
            self.requestBodies = requestBodies
            self.headers = headers
            self.securitySchemes = securitySchemes
        }

        public static let noComponents: Components = .init(
            schemas: [:],
            responses: [:],
            parameters: [:],
            examples: [:],
            requestBodies: [:],
            headers: [:],
            securitySchemes: [:]
        )

        var isEmpty: Bool {
            return self == .noComponents
        }
    }
}

/// Anything conforming to ComponentDictionaryLocatable knows
/// where to find resources of its type in the Components Dictionary.
public protocol ComponentDictionaryLocatable {
    /// The JSON Reference path of this type.
    ///
    /// This can be used to create a JSON path
    /// like `#/name1/name2/name3`
    static var openAPIComponentsKey: String { get }
    static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { get }
}

/// A type conforming to `AnyStringyContainer` can
/// be asked whether it contains a given string.
public protocol AnyStringyContainer {
    func contains(_ key: String) -> Bool
}

//@propertyWrapper
//public struct ComponentDictionary<ReferenceType: Equatable & Codable>: Equatable, AnyStringyContainer {
//
//    public typealias Value = ReferenceType
//    public typealias Key = String
//
//    public init(wrappedValue: OrderedDictionary<String, ReferenceType>) {
//        self.wrappedValue = wrappedValue
//    }
//
//    public var wrappedValue: OrderedDictionary<String, ReferenceType>
//
//    public func contains(_ key: String) -> Bool {
//        return wrappedValue.contains(key: key)
//    }
//}

extension JSONSchema: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "schemas" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.schemas }
}

extension OpenAPI.Response: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "responses" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.responses }
}

extension OpenAPI.PathItem.Parameter: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "parameters" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.parameters }
}

extension OpenAPI.Example: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "examples" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.examples }
}

extension OpenAPI.Request: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "requestBodies" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.requestBodies }
}

extension OpenAPI.Header: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "headers" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.headers }
}

extension OpenAPI.SecurityScheme: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "securitySchemes" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OrderedDictionary<String, Self>> { \.securitySchemes }
}

extension OpenAPI.Components {
    /// Check if the `Components` contains the given reference or not.
    ///
    /// Look up a reference in this components dictionary. If you want a
    /// non-throwing alternative, you can pull a `JSONReference.Reference`
    /// out of your `JSONReference` and pass that to `contains`
    /// instead.
    ///
    /// - throws: If the given reference cannot be checked against `Components`
    ///     then this method will throw `ReferenceError`. This will occur when
    ///     the given reference is a remote file reference.
    public func contains<ReferenceType: Equatable & ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) throws -> Bool {
        guard case .internal(let localReference) = reference else {
            throw ReferenceError.cannotLookupRemoteReference
        }

        return contains(localReference)
    }

    /// Check if the `Components` contains the given internal reference or not.
    public func contains<ReferenceType: Equatable & ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.Reference) -> Bool {
        return reference.name.map { self[keyPath: ReferenceType.openAPIComponentsKeyPath].contains(key: $0) } ?? false
    }

    public enum ReferenceError: Swift.Error, Equatable, CustomStringConvertible {
        case cannotLookupRemoteReference

        public var description: String {
            switch self {
            case .cannotLookupRemoteReference:
                return "You cannot look up remote JSON references in the Components Object local to this file."
            }
        }
    }
}

// MARK: - Codable
extension OpenAPI.Components: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !schemas.isEmpty {
            try container.encode(schemas, forKey: .schemas)
        }

        if !responses.isEmpty {
            try container.encode(responses, forKey: .responses)
        }

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        if !examples.isEmpty {
            try container.encode(examples, forKey: .examples)
        }

        if !requestBodies.isEmpty {
            try container.encode(requestBodies, forKey: .requestBodies)
        }

        if !headers.isEmpty {
            try container.encode(headers, forKey: .headers)
        }

        if !securitySchemes.isEmpty {
            try container.encode(securitySchemes, forKey: .securitySchemes)
        }
    }
}

extension OpenAPI.Components: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schemas = try container.decodeIfPresent(OrderedDictionary<String, JSONSchema>.self, forKey: .schemas)
            ?? [:]

        responses = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.Response>.self, forKey: .responses)
            ?? [:]

        parameters = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.PathItem.Parameter>.self, forKey: .parameters)
        ?? [:]

        examples = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.Example>.self, forKey: .examples)
            ?? [:]

        requestBodies = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.Request>.self, forKey: .requestBodies)
            ?? [:]

        headers = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.Header>.self, forKey: .headers)
            ?? [:]

        securitySchemes = try container.decodeIfPresent(OrderedDictionary<String, OpenAPI.SecurityScheme>.self, forKey: .securitySchemes) ?? [:]
    }
}

extension OpenAPI.Components {
    enum CodingKeys: String, CodingKey {
        case schemas
        case responses
        case parameters
        case examples
        case requestBodies
        case headers
         case securitySchemes
        // case links
        // case callbacks
    }
}

//extension ComponentDictionary: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//
//        try container.encode(wrappedValue)
//    }
//}
//
//extension ComponentDictionary: Decodable {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//
//        wrappedValue = try container.decode(OrderedDictionary<String, ReferenceType>.self)
//    }
//}
