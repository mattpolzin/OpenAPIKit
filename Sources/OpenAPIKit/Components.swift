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
    public struct Components: Equatable, ReferenceRoot {
        public static var refName: String { return "components" }

        public var schemas: SchemasDict
        public var responses: ResponsesDict
        public var parameters: ParametersDict
        public var examples: ExamplesDict
        public var requestBodies: RequestBodiesDict
        public var headers: HeadersDict
        public var securitySchemes: SecuritySchemesDict
        //    public var links:
        //    public var callbacks:

        public init(schemas: OrderedDictionary<String, SchemasDict.Value> = [:],
                    responses: OrderedDictionary<String, ResponsesDict.Value> = [:],
                    parameters: OrderedDictionary<String, ParametersDict.Value> = [:],
                    examples: OrderedDictionary<String, ExamplesDict.Value> = [:],
                    requestBodies: OrderedDictionary<String, RequestBodiesDict.Value> = [:],
                    headers: OrderedDictionary<String, HeadersDict.Value> = [:],
                    securitySchemes: OrderedDictionary<String, SecuritySchemesDict.Value> = [:]) {
            self.schemas = SchemasDict(schemas)
            self.responses = ResponsesDict(responses)
            self.parameters = ParametersDict(parameters)
            self.examples = ExamplesDict(examples)
            self.requestBodies = RequestBodiesDict(requestBodies)
            self.headers = HeadersDict(headers)
            self.securitySchemes = SecuritySchemesDict(securitySchemes)
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

        public enum SchemasName: RefName {
            public static var refName: String { return "schemas" }
        }

        public typealias SchemasDict = RefDict<Components, SchemasName, JSONSchema>

        public enum ResponsesName: RefName {
            public static var refName: String { return "responses" }
        }

        public typealias ResponsesDict = RefDict<Components, ResponsesName, OpenAPI.Response>

        public enum ParametersName: RefName {
            public static var refName: String { return "parameters" }
        }

        public typealias ParametersDict = RefDict<Components, ParametersName, PathItem.Parameter>

        public enum ExamplesName: RefName {
            public static var refName: String { return "examples" }
        }

        public typealias ExamplesDict = RefDict<Components, ExamplesName, OpenAPI.Example>

        public enum RequestBodiesName: RefName {
            public static var refName: String { return "requestBodies" }
        }

        public typealias RequestBodiesDict = RefDict<Components, RequestBodiesName, OpenAPI.Request>

        public enum HeadersName: RefName {
            public static var refName: String { return "headers" }
        }

        public typealias HeadersDict = RefDict<Components, HeadersName, Header>

        public enum SecuritySchemesName: RefName {
            public static var refName: String { return "securitySchemes" }
        }

        public typealias SecuritySchemesDict = RefDict<Components, SecuritySchemesName, SecurityScheme>
    }
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
    ///     then this method will throw `ReferenceError`. This could be because
    ///     the given reference is a remote file reference with no local component or
    ///     an unsafe local reference.
    public func contains<Ref: Equatable>(_ ref: JSONReference<Self, Ref>) throws -> Bool {
        let localRef: JSONReference<Self, Ref>.Local
        if case .internal(let local) = ref {
            localRef = local
        } else if case .external(_, let local?) = ref {
            localRef = local
        } else {
            throw ReferenceError.cannotLookupRemoteReference
        }

        guard case .node(let internalRef) = localRef else {
            throw ReferenceError.cannotLookupUnsafeReference
        }

        return contains(internalRef)
    }

    /// Check if the `Components` contains the given internal reference or not.
    public func contains<Ref: Equatable>(_ ref: JSONReference<Self, Ref>.InternalReference) -> Bool {
        return ref.contained(by: self)
    }

    public enum ReferenceError: Swift.Error, Equatable {
        case cannotLookupRemoteReference
        case cannotLookupUnsafeReference
    }
}

// MARK: - Codable
extension OpenAPI.Components: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !schemas.dict.isEmpty {
            try container.encode(schemas, forKey: .schemas)
        }

        if !responses.dict.isEmpty {
            try container.encode(responses, forKey: .responses)
        }

        if !parameters.dict.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        if !examples.dict.isEmpty {
            try container.encode(examples, forKey: .examples)
        }

        if !requestBodies.dict.isEmpty {
            try container.encode(requestBodies, forKey: .requestBodies)
        }

        if !headers.dict.isEmpty {
            try container.encode(headers, forKey: .headers)
        }

        if !securitySchemes.dict.isEmpty {
            try container.encode(securitySchemes, forKey: .securitySchemes)
        }
    }
}

extension OpenAPI.Components: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schemas = try container.decodeIfPresent(SchemasDict.self, forKey: .schemas)
            ?? SchemasDict([:])

        responses = try container.decodeIfPresent(ResponsesDict.self, forKey: .responses)
            ?? ResponsesDict([:])

        parameters = try container.decodeIfPresent(ParametersDict.self, forKey: .parameters)
            ?? ParametersDict([:])

        examples = try container.decodeIfPresent(ExamplesDict.self, forKey: .examples)
            ?? ExamplesDict([:])

        requestBodies = try container.decodeIfPresent(RequestBodiesDict.self, forKey: .requestBodies)
            ?? RequestBodiesDict([:])

        headers = try container.decodeIfPresent(HeadersDict.self, forKey: .headers)
            ?? HeadersDict([:])

        securitySchemes = try container.decodeIfPresent(SecuritySchemesDict.self, forKey: .securitySchemes) ?? SecuritySchemesDict([:])
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
