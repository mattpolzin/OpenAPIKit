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
    /// See [OpenAPI Components Object](https://spec.openapis.org/oas/v3.1.1.html#components-object).
    /// 
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    ///
    /// Most of the components dictionaries can contain either the component
    /// directly or a $ref to the component. This distinction can be seen in
    /// the types as either `ComponentDictionary<T>` (direct) or
    /// `ComponentReferenceDictionary<T>` (direct or by-reference).
    ///
    /// If you are building a Components Object in Swift you may choose to make
    /// all of your components direct in which case the
    /// `OpenAPI.Components.direct()` convenience constructor will save you
    /// some typing and verbosity.
    ///
    /// **Example**
    ///     OpenAPI.Components(
    ///       parameters: [ "my_param": .parameter(.cookie(name: "my_param", schema: .string)) ]
    ///     )
    ///
    ///     // The above value is the same as the below value
    ///
    ///     OpenAPI.Components.direct(
    ///       parameters: [ "my_param": .cookie(name: "my_param", schema: .string) ]
    ///     )
    ///
    ///     // However, the `init()` initializer does allow you to use references where desired
    ///
    ///     OpenAPI.Components(
    ///       parameters: [
    ///         "my_direct_param": .parameter(.cookie(name: "my_param", schema: .string)),
    ///         "my_param": .reference(.component(named: "my_direct_param"))
    ///       ]
    ///     )
    public struct Components: Equatable, CodableVendorExtendable, Sendable {

        public var schemas: ComponentDictionary<JSONSchema>
        public var responses: ComponentReferenceDictionary<Response>
        public var parameters: ComponentReferenceDictionary<Parameter>
        public var examples: ComponentReferenceDictionary<Example>
        public var requestBodies: ComponentReferenceDictionary<Request>
        public var headers: ComponentReferenceDictionary<Header>
        public var securitySchemes: ComponentReferenceDictionary<SecurityScheme>
        public var links: ComponentReferenceDictionary<Link>
        public var callbacks: ComponentReferenceDictionary<Callbacks>
      
        public var pathItems: ComponentDictionary<PathItem>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            schemas: ComponentDictionary<JSONSchema> = [:],
            responses: ComponentReferenceDictionary<Response> = [:],
            parameters: ComponentReferenceDictionary<Parameter> = [:],
            examples: ComponentReferenceDictionary<Example> = [:],
            requestBodies: ComponentReferenceDictionary<Request> = [:],
            headers: ComponentReferenceDictionary<Header> = [:],
            securitySchemes: ComponentReferenceDictionary<SecurityScheme> = [:],
            links: ComponentReferenceDictionary<Link> = [:],
            callbacks: ComponentReferenceDictionary<Callbacks> = [:],
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

        /// Construct components as "direct" entries (no references). When
        /// building a document in Swift code, this is often sufficient and it
        /// means you don't need to wrap every entry in an `Either`.
        public static func direct(
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
        ) -> Self {
            .init(
                schemas: schemas,
                responses: responses.mapValues { .b($0) },
                parameters: parameters.mapValues { .b($0) },
                examples: examples.mapValues { .b($0) },
                requestBodies: requestBodies.mapValues { .b($0) },
                headers: headers.mapValues { .b($0) },
                securitySchemes: securitySchemes.mapValues { .b($0) },
                links: links.mapValues { .b($0) },
                callbacks: callbacks.mapValues { .b($0) },
                pathItems: pathItems,
                vendorExtensions: vendorExtensions
            )
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
    public typealias ComponentReferenceDictionary<T: ComponentDictionaryLocatable> = OrderedDictionary<ComponentKey, Either<OpenAPI.Reference<T>, T>>
}

extension OpenAPI.Components {
    public struct ComponentCollision: Swift.Error {
        public let componentType: String
        public let existingComponent: String
        public let newComponent: String
    }

    private func detectCollision<T: Equatable>(type: String) throws -> (_ old: T, _ new: T) throws -> T {
        return { old, new in
            // theoretically we can detect collisions here, but we would need to compare
            // for equality up-to but not including the difference between an external and
            // internal reference which is not supported yet.
//            if(old == new) { return old }
//            throw ComponentCollision(componentType: type, existingComponent: String(describing:old), newComponent: String(describing:new))

            // Given we aren't ensuring there are no collisions, the old version is going to be
            // the one more likely to have been _further_ dereferenced than the new record, so
            // we keep that version.
            return old
        }
    }

    public mutating func merge(_ other: OpenAPI.Components) throws {
        try schemas.merge(other.schemas, uniquingKeysWith: detectCollision(type: "schema"))
        try responses.merge(other.responses, uniquingKeysWith: detectCollision(type: "responses"))
        try parameters.merge(other.parameters, uniquingKeysWith: detectCollision(type: "parameters"))
        try examples.merge(other.examples, uniquingKeysWith: detectCollision(type: "examples"))
        try requestBodies.merge(other.requestBodies, uniquingKeysWith: detectCollision(type: "requestBodies"))
        try headers.merge(other.headers, uniquingKeysWith: detectCollision(type: "headers"))
        try securitySchemes.merge(other.securitySchemes, uniquingKeysWith: detectCollision(type: "securitySchemes"))
        try links.merge(other.links, uniquingKeysWith: detectCollision(type: "links"))
        try callbacks.merge(other.callbacks, uniquingKeysWith: detectCollision(type: "callbacks"))
        try pathItems.merge(other.pathItems, uniquingKeysWith: detectCollision(type: "pathItems"))
        try vendorExtensions.merge(other.vendorExtensions, uniquingKeysWith: detectCollision(type: "vendorExtensions"))
    }

    /// Sort the components within each type by the component key.
    public mutating func sort() {
        schemas.sortKeys()
        responses.sortKeys()
        parameters.sortKeys()
        examples.sortKeys()
        requestBodies.sortKeys()
        headers.sortKeys()
        securitySchemes.sortKeys()
        links.sortKeys()
        callbacks.sortKeys()
        pathItems.sortKeys()
    }
}

extension OpenAPI.Components {
    /// The extension name used to store a Components Object name (the key something is stored under
    /// within the Components Object). This is used by OpenAPIKit to store the previous Component name 
    /// of an OpenAPI Object that has been dereferenced (pulled out of the Components and stored inline
    /// in the OpenAPI Document).
    public static let componentNameExtension: String = "x-component-name"
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

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Components: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            schemas = try container.decodeIfPresent(OpenAPI.ComponentDictionary<JSONSchema>.self, forKey: .schemas)
                ?? [:]

            responses = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Response>.self, forKey: .responses)
                ?? [:]

            parameters = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Parameter>.self, forKey: .parameters)
            ?? [:]

            examples = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Example>.self, forKey: .examples)
                ?? [:]

            requestBodies = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Request>.self, forKey: .requestBodies)
                ?? [:]

            headers = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Header>.self, forKey: .headers)
                ?? [:]

            securitySchemes = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.SecurityScheme>.self, forKey: .securitySchemes) ?? [:]

            links = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Link>.self, forKey: .links) ?? [:]

            callbacks = try container.decodeIfPresent(OpenAPI.ComponentReferenceDictionary<OpenAPI.Callbacks>.self, forKey: .callbacks) ?? [:]
          
            pathItems = try container.decodeIfPresent(OpenAPI.ComponentDictionary<OpenAPI.PathItem>.self, forKey: .pathItems) ?? [:]

            vendorExtensions = try Self.extensions(from: decoder)
        } catch let error as EitherDecodeNoTypesMatchedError {
            if let underlyingError = OpenAPI.Error.Decoding.Document.eitherBranchToDigInto(error) {
                throw (underlyingError.underlyingError ?? underlyingError)
            }

            throw error
        } catch let error as DecodingError {
            if let underlyingError = error.underlyingError as? KeyDecodingError {
                throw GenericError(
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
    internal mutating func externallyDereference<Loader: ExternalLoader>(with loader: Loader.Type, depth: ExternalDereferenceDepth = .iterations(1), context: [Loader.Message] = []) async throws -> [Loader.Message] {
        if case let .iterations(number) = depth,
           number <= 0 {
            return context
        }

        // NOTE: The links and callbacks related code commented out below pushes Swift 5.8 and 5.9
        //       over the edge and you get exit code 137 crashes in CI.
        //       Swift 5.10 handles it fine.

        let oldSchemas = schemas
        let oldResponses = responses
        let oldParameters = parameters
        let oldExamples = examples
        let oldRequestBodies = requestBodies
        let oldHeaders = headers
        let oldSecuritySchemes = securitySchemes
        let oldLinks = links
        let oldCallbacks = callbacks
        let oldPathItems = pathItems

        async let (newSchemas, c1, m1) = oldSchemas.externallyDereferenced(with: loader)
        async let (newResponses, c2, m2) = oldResponses.externallyDereferenced(with: loader)
        async let (newParameters, c3, m3) = oldParameters.externallyDereferenced(with: loader)
        async let (newExamples, c4, m4) = oldExamples.externallyDereferenced(with: loader)
        async let (newRequestBodies, c5, m5) = oldRequestBodies.externallyDereferenced(with: loader)
        async let (newHeaders, c6, m6) = oldHeaders.externallyDereferenced(with: loader)
        async let (newSecuritySchemes, c7, m7) = oldSecuritySchemes.externallyDereferenced(with: loader)
//        async let (newLinks, c8, m8) = oldLinks.externallyDereferenced(with: loader)
//        async let (newCallbacks, c9, m9) = oldCallbacks.externallyDereferenced(with: loader)
        async let (newPathItems, c10, m10) = oldPathItems.externallyDereferenced(with: loader)

        schemas = try await newSchemas
        responses = try await newResponses
        parameters = try await newParameters
        examples = try await newExamples
        requestBodies = try await newRequestBodies
        headers = try await newHeaders
        securitySchemes = try await newSecuritySchemes
//        links = try await newLinks
//        callbacks = try await newCallbacks
        pathItems = try await newPathItems

        let c1Resolved = try await c1
        let c2Resolved = try await c2
        let c3Resolved = try await c3
        let c4Resolved = try await c4
        let c5Resolved = try await c5
        let c6Resolved = try await c6
        let c7Resolved = try await c7
//        let c8Resolved = try await c8
//        let c9Resolved = try await c9
        let c10Resolved = try await c10

        // For Swift 5.10+ we can delete the following links and callbacks code and uncomment the
        // preferred code above.
        let (newLinks, c8, m8) = try await oldLinks.externallyDereferenced(with: loader)
        links = newLinks
        let c8Resolved = c8
        let (newCallbacks, c9, m9) = try await oldCallbacks.externallyDereferenced(with: loader)
        callbacks = newCallbacks
        let c9Resolved = c9

        let noNewComponents =
            c1Resolved.isEmpty
            && c2Resolved.isEmpty
            && c3Resolved.isEmpty
            && c4Resolved.isEmpty
            && c5Resolved.isEmpty
            && c6Resolved.isEmpty
            && c7Resolved.isEmpty
            && c8Resolved.isEmpty
            && c9Resolved.isEmpty
            && c10Resolved.isEmpty

        let newMessages = try await context + m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 

        if noNewComponents { return newMessages }

        try merge(c1Resolved)
        try merge(c2Resolved)
        try merge(c3Resolved)
        try merge(c4Resolved)
        try merge(c5Resolved)
        try merge(c6Resolved)
        try merge(c7Resolved)
        try merge(c8Resolved)
        try merge(c9Resolved)
        try merge(c10Resolved)

        switch depth {
            case .iterations(let number):
                return try await externallyDereference(with: loader, depth: .iterations(number - 1), context: newMessages)
            case .full:
                return try await externallyDereference(with: loader, depth: .full, context: newMessages)
        }
    }
}

extension OpenAPI.Components: Validatable {}
