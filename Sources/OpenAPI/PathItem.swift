//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly

extension OpenAPI {
    public enum ContentType: String, Codable, Equatable, Hashable {
        case json = "application/json"
    }

    public struct Content: Codable, Equatable {
        public let schema: Either<JSONSchemaObject, JSONReference<Components, JSONSchemaObject>>
        //        public let example:
        //        public let examples:
        //        public let encoding:

        public init(schema: Either<JSONSchemaObject, JSONReference<Components, JSONSchemaObject>>) {
            self.schema = schema
        }
    }

    /// An OpenAPI Path Item
    /// This type describes the endpoints a server has
    /// bound to a particular path.
    public enum PathItem: Equatable {
        case reference(JSONReference<Components, PathItem>)
        case operations(PathProperties)

        public struct PathProperties: Equatable {
            public let summary: String?
            public let description: String?
            //        public let servers:
            public let parameters: ParameterArray

            public let get: Operation?
            public let put: Operation?
            public let post: Operation?
            public let delete: Operation?
            public let options: Operation?
            public let head: Operation?
            public let patch: Operation?
            public let trace: Operation?

            public init(summary: String? = nil,
                        description: String? = nil,
                        parameters: ParameterArray = [],
                        get: Operation? = nil,
                        put: Operation? = nil,
                        post: Operation? = nil,
                        delete: Operation? = nil,
                        options: Operation? = nil,
                        head: Operation? = nil,
                        patch: Operation? = nil,
                        trace: Operation? = nil) {
                self.summary = summary
                self.description = description
                self.parameters = parameters

                self.get = get
                self.put = put
                self.post = post
                self.delete = delete
                self.options = options
                self.head = head
                self.patch = patch
                self.trace = trace
            }

            public typealias ParameterArray = [Either<Parameter, JSONReference<Components, Parameter>>]

            public struct Parameter: Equatable {
                public let name: String
                public let parameterLocation: Location
                public let description: String?
                public let deprecated: Bool // default is false
                public let schemaOrContent: Either<SchemaProperty, Operation.ContentMap>
                // TODO: serialization rules
                /*
                 Serialization Rules
                 */

                public typealias SchemaProperty = Either<JSONSchemaObject, JSONReference<Components, JSONSchemaObject>>

                public init(name: String,
                            parameterLocation: Location,
                            schemaOrContent: Either<SchemaProperty, Operation.ContentMap>,
                            description: String? = nil,
                            deprecated: Bool = false) {
                    self.name = name
                    self.parameterLocation = parameterLocation
                    self.schemaOrContent = schemaOrContent
                    self.description = description
                    self.deprecated = deprecated
                }

                public enum Location: Equatable {
                    case query(required: Bool?)
                    case header(required: Bool?)
                    case path
                    case cookie(required: Bool?)
                }
            }

            public struct Operation: Equatable {
                public let tags: [String]?
                public let summary: String?
                public let description: String?
                //            public let externalDocs:
                public let operationId: String?
                public let parameters: ParameterArray
                public let requestBody: Request?
                public let responses: ResponseMap
                //            public let callbacks:
                public let deprecated: Bool // default is false
                //            public let security:
                //            public let servers:

                public init(tags: [String]? = nil,
                            summary: String? = nil,
                            description: String? = nil,
                            operationId: String? = nil,
                            parameters: ParameterArray,
                            requestBody: Request? = nil,
                            responses: ResponseMap,
                            deprecated: Bool = false) {
                    self.tags = tags
                    self.summary = summary
                    self.description = description
                    self.operationId = operationId
                    self.parameters = parameters
                    self.requestBody = requestBody
                    self.responses = responses
                    self.deprecated = deprecated
                }

                public typealias ResponseMap = [Response.StatusCode: Either<Response, JSONReference<Components, Response>>]

                public typealias ContentMap = [ContentType: Content]
            }
        }
    }
}



// MARK: - Codable

extension OpenAPI.PathItem: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .reference(let reference):
            try container.encode(reference)

        case .operations(let operations):
            try container.encode(operations)
        }
    }
}

extension OpenAPI.PathItem: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let maybeRef: Result<JSONReference<OpenAPI.Components, Self>, Swift.Error>
        do {
            maybeRef = .success(try container.decode(JSONReference<OpenAPI.Components, Self>.self))
        } catch let err {
            maybeRef = .failure(err)
        }

        let maybeOperations: Result<PathProperties, Swift.Error>
        do {
            maybeOperations = .success(try container.decode(PathProperties.self))
        } catch let err {
            maybeOperations = .failure(err)
        }

        switch (maybeRef, maybeOperations) {
        case (.success(let ref), _):
            self = .reference(ref)
        case (_, .success(let operations)):
            self = .operations(operations)
        default:
            throw OpenAPI.DecodingError.foundNeither(option1: "$ref",
                                                     option2: "Operations",
                                                     codingPath: decoder.codingPath,
                                                     notOption1Because: maybeRef.error,
                                                     notOption2Because: maybeOperations.error)
        }
    }
}

extension OpenAPI.PathItem.PathProperties.Operation {
    private enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case description
//        case externalDocs
        case operationId
        case parameters
        case requestBody
        case responses
//        case callbacks
        case deprecated
//        case security
//        case servers
    }
}

extension OpenAPI.PathItem.PathProperties.Operation: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if tags != nil {
            try container.encode(tags, forKey: .tags)
        }

        if summary != nil {
            try container.encode(summary, forKey: .summary)
        }

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        if operationId != nil {
            try container.encode(operationId, forKey: .operationId)
        }

        try container.encode(parameters, forKey: .parameters)

        if requestBody != nil {
            try container.encode(requestBody, forKey: .requestBody)
        }

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            responses.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .responses)

        try container.encode(deprecated, forKey: .deprecated)
    }
}

extension OpenAPI.PathItem.PathProperties.Operation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        tags = try container.decodeIfPresent([String].self, forKey: .tags)

        summary = try container.decodeIfPresent(String.self, forKey: .summary)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        operationId = try container.decodeIfPresent(String.self, forKey: .operationId)

        parameters = try container.decodeIfPresent(OpenAPI.PathItem.PathProperties.ParameterArray.self, forKey: .parameters) ?? []

        requestBody = try container.decodeIfPresent(OpenAPI.Request.self, forKey: .requestBody)

        // hack to workaround Dictionary bug
        let responsesDict = try container.decode([String: Either<OpenAPI.Response, JSONReference<OpenAPI.Components, OpenAPI.Response>>].self, forKey: .responses)
        responses = Dictionary(responsesDict.compactMap { statusCodeString, response in
            OpenAPI.Response.StatusCode(rawValue: statusCodeString).map { ($0, response) } },
                           uniquingKeysWith: { $1 })

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
    }
}

extension OpenAPI.PathItem.PathProperties.Parameter {
    private enum CodingKeys: String, CodingKey {
        case name
        case parameterLocation = "in"
        case description
        case required
        case deprecated

        // the following are alternatives
        case content
        case schema
    }

    private enum LocationString: String, Codable {
        case query
        case header
        case path
        case cookie
    }
}

extension OpenAPI.PathItem.PathProperties.Parameter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool?
        let location: LocationString
        switch parameterLocation {
        case .query(required: let req):
            required = req
            location = .query
        case .header(required: let req):
            required = req
            location = .header
        case .path:
            required = true
            location = .path
        case .cookie(required: let req):
            required = req
            location = .cookie
        }
        try container.encode(location, forKey: .parameterLocation)

        try container.encode(required, forKey: .required)

        switch schemaOrContent {
        case .a(let schema):
            try container.encode(schema, forKey: .schema)
        case .b(let contentMap):
            // Hack to work around Dictionary encoding
            // itself as an array in this case:
            let stringKeyedDict = Dictionary(
                contentMap.map { ($0.key.rawValue, $0.value) },
                uniquingKeysWith: { $1 }
            )
            try container.encode(stringKeyedDict, forKey: .content)
        }

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }
    }
}

extension OpenAPI.PathItem.PathProperties.Parameter: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        let location = try container.decode(LocationString.self, forKey: .parameterLocation)

        switch location {
        case .query:
            parameterLocation = .query(required: required)
        case .header:
            parameterLocation = .header(required: required)
        case .path:
            if !required {
                throw OpenAPI.DecodingError.unsatisfied(requirement: "positional path parameters must be explicitly set to required.", codingPath: decoder.codingPath)
            }
            parameterLocation = .path
        case .cookie:
            parameterLocation = .cookie(required: required)
        }

        // hacky workaround for Dictionary decoding bug
        let maybeContentDict = try container.decodeIfPresent([String: OpenAPI.Content].self, forKey: .content)
        let maybeContent = maybeContentDict.map { contentDict in
            Dictionary(contentDict.compactMap { contentTypeString, content in
                OpenAPI.ContentType(rawValue: contentTypeString).map { ($0, content) } },
                       uniquingKeysWith: { $1 })
        }

        let maybeSchema = try container.decodeIfPresent(SchemaProperty.self, forKey: .schema)

        switch (maybeContent, maybeSchema) {
        case (let content?, _):
            schemaOrContent = .init(content)
        case (_, let schema?):
            schemaOrContent = .init(schema)
        default:
            throw OpenAPI.DecodingError.unsatisfied(requirement: "A single path parameter must specify one but not both 'content' and 'schema'.", codingPath: decoder.codingPath)
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
    }
}

extension OpenAPI.PathItem.PathProperties {
    private enum CodingKeys: String, CodingKey {
        case summary
        case description
//        case servers
        case parameters

        case get
        case put
        case post
        case delete
        case options
        case head
        case patch
        case trace
    }
}

extension OpenAPI.PathItem.PathProperties: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if summary != nil {
            try container.encode(summary, forKey: .summary)
        }

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        try container.encode(parameters, forKey: .parameters)

        if get != nil {
            try container.encode(get, forKey: .get)
        }

        if put != nil {
            try container.encode(put, forKey: .put)
        }

        if post != nil {
            try container.encode(post, forKey: .post)
        }

        if delete != nil {
            try container.encode(delete, forKey: .delete)
        }

        if options != nil {
            try container.encode(options, forKey: .options)
        }

        if head != nil {
            try container.encode(head, forKey: .head)
        }

        if patch != nil {
            try container.encode(patch, forKey: .patch)
        }

        if trace != nil {
            try container.encode(trace, forKey: .trace)
        }
    }
}

extension OpenAPI.PathItem.PathProperties: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        summary = try container.decodeIfPresent(String.self, forKey: .summary)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        parameters = try container.decodeIfPresent(ParameterArray.self, forKey: .parameters) ?? []

        get = try container.decodeIfPresent(Operation.self, forKey: .get)
        put = try container.decodeIfPresent(Operation.self, forKey: .put)
        post = try container.decodeIfPresent(Operation.self, forKey: .post)
        delete = try container.decodeIfPresent(Operation.self, forKey: .delete)
        options = try container.decodeIfPresent(Operation.self, forKey: .options)
        head = try container.decodeIfPresent(Operation.self, forKey: .head)
        patch = try container.decodeIfPresent(Operation.self, forKey: .patch)
        trace = try container.decodeIfPresent(Operation.self, forKey: .trace)
    }
}
