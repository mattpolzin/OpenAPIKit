//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore
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
        public var parameters: ComponentDictionary<Parameter>
        public var examples: ComponentDictionary<Example>
        public var requestBodies: ComponentDictionary<Request>
        public var headers: ComponentDictionary<Header>
        public var securitySchemes: ComponentDictionary<SecurityScheme>
        public var callbacks: ComponentDictionary<Callbacks>
        public var links: ComponentDictionary<Link>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            schemas: ComponentDictionary<JSONSchema> = [:],
            responses: ComponentDictionary<Response> = [:],
            parameters: ComponentDictionary<Parameter> = [:],
            examples: ComponentDictionary<Example> = [:],
            requestBodies: ComponentDictionary<Request> = [:],
            headers: ComponentDictionary<Header> = [:],
            securitySchemes: ComponentDictionary<SecurityScheme> = [:],
            links: ComponentDictionary<Link> = [:],
            callbacks: ComponentDictionary<Callbacks> = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemas = schemas
            self.responses = responses
            self.parameters = parameters
            self.examples = examples
            self.requestBodies = requestBodies
            self.headers = headers
            self.securitySchemes = securitySchemes
            self.links = links
            self.callbacks = callbacks
            self.vendorExtensions = vendorExtensions
        }

        /// An empty OpenAPI Components Object.
        public static let noComponents: Components = .init()

        public var isEmpty: Bool {
            return self == .noComponents
        }
    }
}

extension OpenAPI {

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

        if !links.isEmpty {
            try container.encode(links, forKey: .links)
        }

        if !callbacks.isEmpty {
            try container.encode(callbacks, forKey: .callbacks)
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

            parameters = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Parameter>.self, forKey: .parameters)
            ?? [:]

            examples = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Example>.self, forKey: .examples)
                ?? [:]

            requestBodies = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Request>.self, forKey: .requestBodies)
                ?? [:]

            headers = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Header>.self, forKey: .headers)
                ?? [:]

            securitySchemes = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.SecurityScheme>.self, forKey: .securitySchemes) ?? [:]

            links = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Link>.self, forKey: .links) ?? [:]

            callbacks = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.Callbacks>.self, forKey: .callbacks) ?? [:]

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
        case links
        case callbacks

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .schemas,
                .responses,
                .parameters,
                .examples,
                .requestBodies,
                .headers,
                .securitySchemes,
                .links,
                .callbacks
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
            case "links":
                self = .links
            case "callbacks":
                self = .callbacks
            default:
                self = .extendedKey(for: stringValue)
            }
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
            case .links:
                return "links"
            case .callbacks:
                return "callbacks"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Components: Validatable {}
