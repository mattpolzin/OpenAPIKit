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
    /// See [OpenAPI Components Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#components-object).
    /// 
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable, CodableVendorExtendable {

        public var schemas: ComponentDictionary<JSONSchema>
        public var responses: ComponentDictionary<Response>
        public var parameters: ComponentDictionary<PathItem.Parameter>
        public var examples: ComponentDictionary<Example>
        public var requestBodies: ComponentDictionary<Request>
        public var headers: ComponentDictionary<Header>
        public var securitySchemes: ComponentDictionary<SecurityScheme>
        //    public var links:
        //    public var callbacks:

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(schemas: ComponentDictionary<JSONSchema> = [:],
                    responses: ComponentDictionary<Response> = [:],
                    parameters: ComponentDictionary<PathItem.Parameter> = [:],
                    examples: ComponentDictionary<Example> = [:],
                    requestBodies: ComponentDictionary<Request> = [:],
                    headers: ComponentDictionary<Header> = [:],
                    securitySchemes: ComponentDictionary<SecurityScheme> = [:],
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.schemas = schemas
            self.responses = responses
            self.parameters = parameters
            self.examples = examples
            self.requestBodies = requestBodies
            self.headers = headers
            self.securitySchemes = securitySchemes
            self.vendorExtensions = vendorExtensions
        }

        public static let noComponents: Components = .init()

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

        try encodeExtensions(to: &container)
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

            vendorExtensions = try Self.extensions(from: decoder)
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
    internal enum CodingKeys: ExtendableCodingKey {
        case schemas
        case responses
        case parameters
        case examples
        case requestBodies
        case headers
         case securitySchemes
        // case links
        // case callbacks

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .schemas,
                .responses,
                .parameters,
                .examples,
                .requestBodies,
                .headers,
                .securitySchemes
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "schemas":
                self = .schemas
            case "responses":
                self = .responses
            case "parameters":
                self = .parameters
            case "examples":
                self = .examples
            case "requestBodies":
                self = .requestBodies
            case "headers":
                self = .headers
            case "securitySchemes":
                self = .securitySchemes
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String {
            switch self {
            case .schemas:
                return "schemas"
            case .responses:
                return "responses"
            case .parameters:
                return "parameters"
            case .examples:
                return "examples"
            case .requestBodies:
                return "requestBodies"
            case .headers:
                return "headers"
            case .securitySchemes:
                return "securitySchemes"
            case .extended(let key):
                return key
            }
        }

        var intValue: Int? {
            return nil
        }
    }
}
