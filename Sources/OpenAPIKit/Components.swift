//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Components Object".
    ///
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#components-object
    /// 
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable {

        public var schemas: ComponentDictionary<JSONSchema>
        public var responses: ComponentDictionary<Response>
        public var parameters: ComponentDictionary<PathItem.Parameter>
        public var examples: ComponentDictionary<Example>
        public var requestBodies: ComponentDictionary<Request>
        public var headers: ComponentDictionary<Header>
        public var securitySchemes: ComponentDictionary<SecurityScheme>
        //    public var links:
        //    public var callbacks:

        public init(schemas: ComponentDictionary<JSONSchema> = [:],
                    responses: ComponentDictionary<Response> = [:],
                    parameters: ComponentDictionary<PathItem.Parameter> = [:],
                    examples: ComponentDictionary<Example> = [:],
                    requestBodies: ComponentDictionary<Request> = [:],
                    headers: ComponentDictionary<Header> = [:],
                    securitySchemes: ComponentDictionary<SecurityScheme> = [:]) {
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

        public var isEmpty: Bool {
            return self == .noComponents
        }
    }
}

extension OpenAPI {
    public struct ComponentKey: RawRepresentable, ExpressibleByStringLiteral, Codable, Equatable, Hashable, StringConvertibleHintProvider {
        public let rawValue: String

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }

        public init?(rawValue: String) {
            var allowedCharacters = CharacterSet.alphanumerics
            allowedCharacters.insert(charactersIn: "-_.")
            guard CharacterSet(charactersIn: rawValue).isSubset(of: allowedCharacters) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public static func problem(with proposedString: String) -> String? {
            if Self(rawValue: proposedString) == nil {
                return "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(proposedString)' does not.."
            }
            return nil
        }

        public init(from decoder: Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            guard let key = Self(rawValue: rawValue) else {
                throw InconsistencyError(
                    subjectName: "Component Key",
                    details: "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(rawValue)' does not..",
                    codingPath: decoder.codingPath
                )
            }
            self = key
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            // we check for consistency on encode because a string literal
            // may result in an invalid component key being constructed.
            guard Self(rawValue: rawValue) != nil else {
                throw InconsistencyError(
                    subjectName: "Component Key",
                    details: "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(rawValue)' does not..",
                    codingPath: container.codingPath
                )
            }

            try container.encode(rawValue)
        }
    }

    public typealias ComponentDictionary<T> = OrderedDictionary<ComponentKey, T>
}

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

/// A type conforming to `AnyStringyContainer` can
/// be asked whether it contains a given string.
public protocol AnyStringyContainer {
    func contains(_ key: String) -> Bool
}

// MARK: - Reference Support
extension JSONSchema: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "schemas" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.schemas }
}

extension OpenAPI.Response: ComponentDictionaryLocatable {
    public static var openAPIComponentsKey: String { "responses" }
    public static var openAPIComponentsKeyPath: KeyPath<OpenAPI.Components, OpenAPI.ComponentDictionary<Self>> { \.responses }
}

extension OpenAPI.PathItem.Parameter: ComponentDictionaryLocatable {
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

extension OpenAPI.Components {
    /// Check if the `Components` contains the given reference or not.
    ///
    /// Look up a reference in this components dictionary. If you want a
    /// non-throwing alternative, you can pull a `JSONReference.InternalReference`
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
    public func contains<ReferenceType: Equatable & ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> Bool {
        return reference.name
            .flatMap(OpenAPI.ComponentKey.init(rawValue:))
            .map { self[keyPath: ReferenceType.openAPIComponentsKeyPath].contains(key: $0) }
            ?? false
    }

    /// Retrieve item referenced from the `Components`.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>) -> ReferenceType? {
        guard case .internal(let localReference) = reference else {
            return nil
        }

        return self[localReference]
    }

    /// Retrieve item referenced from the `Components`.
    public subscript<ReferenceType: ComponentDictionaryLocatable>(_ reference: JSONReference<ReferenceType>.InternalReference) -> ReferenceType? {
        return reference.name
            .flatMap(OpenAPI.ComponentKey.init(rawValue:))
            .flatMap { self[keyPath: ReferenceType.openAPIComponentsKeyPath][$0] }
    }

    /// Pass a value that can be either a reference to a component or the component itself.
    /// `dereference()` will return the component value if it is found (in the Either wrapper
    /// or in the Components Object).
    ///
    /// - Important: Dereferencing an external reference (i.e. one that points to another file)
    ///     is not currently supported by OpenAPIKit and will therefore always result in `nil`.
    public func dereference<ReferenceType: ComponentDictionaryLocatable>(_ maybeReference: Either<JSONReference<ReferenceType>, ReferenceType>) -> ReferenceType? {
        switch maybeReference {
        case .a(let reference):
            return self[reference]
        case .b(let value):
            return value
        }
    }

    /// Create a `JSONReference`.
    ///
    /// - throws: If the given name does not refer to an existing component of the given type.
    public func reference<ReferenceType: ComponentDictionaryLocatable & Equatable>(named name: String, ofType: ReferenceType.Type) throws -> JSONReference<ReferenceType> {
        let internalReference = JSONReference<ReferenceType>.InternalReference.component(name: name)
        let reference = JSONReference<ReferenceType>.internal(internalReference)

        guard contains(internalReference) else {
            throw ReferenceError.missingComponentOnReferenceCreation(name: name, key: ReferenceType.openAPIComponentsKey)
        }
        return reference
    }

    public enum ReferenceError: Swift.Error, Equatable, CustomStringConvertible {
        case cannotLookupRemoteReference
        case missingComponentOnReferenceCreation(name: String, key: String)

        public var description: String {
            switch self {
            case .cannotLookupRemoteReference:
                return "You cannot look up remote JSON references in the Components Object local to this file."
            case .missingComponentOnReferenceCreation(name: let name, key: let key):
                return "You cannot create references to components that do not exist in the Components Object this way. You can construct a `JSONReference` directly if you need to circumvent this protection. '\(name)' was not found in \(key)."
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

        do {
            schemas = try container.decodeIfPresent(OpenAPI.ComponentDictionary<JSONSchema>.self, forKey: .schemas)
                ?? [:]

            responses = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Response>.self, forKey: .responses)
                ?? [:]

            parameters = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.PathItem.Parameter>.self, forKey: .parameters)
            ?? [:]

            examples = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Example>.self, forKey: .examples)
                ?? [:]

            requestBodies = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Request>.self, forKey: .requestBodies)
                ?? [:]

            headers = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Header>.self, forKey: .headers)
                ?? [:]

            securitySchemes = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.SecurityScheme>.self, forKey: .securitySchemes) ?? [:]
        } catch let error as DecodingError {
            if let underlyingError = error.underlyingError as? KeyDecodingError {
                throw InconsistencyError(
                    subjectName: error.subjectName,
                    details: underlyingError.localizedDescription,
                    codingPath: error.codingPath
                )
            }
            throw error
        }
    }
}

extension OpenAPI.Components {
    internal enum CodingKeys: String, CodingKey {
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
