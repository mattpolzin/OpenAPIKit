//
//  Components.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    /// What the spec calls the "Components Object".
    /// This is a place to put reusable components to
    /// be referenced from other parts of the spec.
    public struct Components: Equatable, ReferenceRoot {
        public static var refName: String { return "components" }

        public let schemas: SchemasDict
        public let responses: ResponsesDict
        public let parameters: ParametersDict
        public let examples: ExamplesDict
        public let requestBodies: RequestBodiesDict
        public let headers: HeadersDict
        //    public let securitySchemas:
        //    public let links:
        //    public let callbacks:

        public init(schemas: [String: SchemasDict.Value],
                    responses: [String: ResponsesDict.Value],
                    parameters: [String: ParametersDict.Value],
                    examples: [String: ExamplesDict.Value],
                    requestBodies: [String: RequestBodiesDict.Value],
                    headers: [String: HeadersDict.Value]) {
            self.schemas = SchemasDict(schemas)
            self.responses = ResponsesDict(responses)
            self.parameters = ParametersDict(parameters)
            self.examples = ExamplesDict(examples)
            self.requestBodies = RequestBodiesDict(requestBodies)
            self.headers = HeadersDict(headers)
        }

        public static var noComponents: Components {
            return .init(schemas: [:],
                         responses: [:],
                         parameters: [:],
                         examples: [:],
                         requestBodies: [:],
                         headers: [:])
        }

        public enum SchemasName: RefName {
            public static var refName: String { return "schemas" }
        }

        public typealias SchemasDict = RefDict<Components, SchemasName, JSONSchema>

        public enum ResponsesName: RefName {
            public static var refName: String { return "responses" }
        }

        public typealias ResponsesDict = RefDict<Components, ResponsesName, JSONSchema>

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

        public typealias RequestBodiesDict = RefDict<Components, RequestBodiesName, OpenAPI.Example>

        public enum HeadersName: RefName {
            public static var refName: String { return "headers" }
        }

        public typealias HeadersDict = RefDict<Components, HeadersName, Header>
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
        // case securitySchemas
        // case links
        // case callbacks
    }
}
