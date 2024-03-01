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
    /// See [OpenAPI Components Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#components-object).
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
        public var links: ComponentDictionary<Link>
        public var callbacks: ComponentDictionary<Callbacks>
      
        public var pathItems: ComponentDictionary<PathItem>

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
            pathItems: ComponentDictionary<PathItem> = [:],
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
            self.pathItems = pathItems
            self.vendorExtensions = vendorExtensions
        }

        /// An empty OpenAPI Components Object.
        public static let noComponents: Components = .init()

        public var isEmpty: Bool {
            return self == .noComponents
        }
    }
}

extension OpenAPI.Components {
    /// The extension name used to store a Components Object name (the key something is stored under
    /// within the Components Object). This is used by OpenAPIKit to store the previous Component name 
    /// of an OpenAPI Object that has been dereferenced (pulled out of the Components and stored inline
    /// in the OpenAPI Document).
    public static let componentNameExtension: String = "x-component-name"
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
      
        if !pathItems.isEmpty {
            try container.encode(pathItems, forKey: .pathItems)
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
          
            pathItems = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.PathItem>.self, forKey: .pathItems) ?? [:]

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
        case pathItems

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
                .callbacks,
                .pathItems
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
            case "pathItems":
                self = .pathItems
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
            case .pathItems:
                return "pathItems"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Components {
    private mutating func externallyDereference<Context, T>(dictionary: OpenAPI.ComponentDictionary<T>, with loader: inout ExternalLoader<Context>) throws -> OpenAPI.ComponentDictionary<T> where Context: ExternalLoaderContext, T: LocallyDereferenceable {
        var newValues = OpenAPI.ComponentDictionary<T>()
        for (key, value) in dictionary {
            newValues[key] = try value.externallyDereferenced(with: &loader)
        }
        return newValues
    }

    internal mutating func externallyDereference<Context>(in context: Context) throws -> ExternalLoader<Context> where Context: ExternalLoaderContext {
        var loader = ExternalLoader<Context>(components: self, context: context)

        schemas = try externallyDereference(dictionary: schemas, with: &loader)
        responses = try externallyDereference(dictionary: responses, with: &loader)
        parameters = try externallyDereference(dictionary: parameters, with: &loader)
        examples = try externallyDereference(dictionary: examples, with: &loader)
        requestBodies = try externallyDereference(dictionary: requestBodies, with: &loader)
        headers = try externallyDereference(dictionary: headers, with: &loader)
        securitySchemes = try externallyDereference(dictionary: securitySchemes, with: &loader)

        var newCallbacks = OpenAPI.ComponentDictionary<OpenAPI.Callbacks>()
        for (key, value) in callbacks {
            newCallbacks[key] = try value.externallyDereferenced(with: &loader)
        }
        callbacks = newCallbacks

        return loader
    }
}

extension OpenAPI.Components: Validatable {}
