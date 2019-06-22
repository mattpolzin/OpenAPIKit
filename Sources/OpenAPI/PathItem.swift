//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly

public enum OpenAPIContentType: String, Encodable, Equatable, Hashable {
    case json = "application/json"
}

public struct OpenAPIContent: Encodable, Equatable {
    public let schema: Either<JSONSchemaObject, JSONReference<OpenAPIComponents, JSONSchemaObject>>
    //        public let example:
    //        public let examples:
    //        public let encoding:

    public init(schema: Either<JSONSchemaObject, JSONReference<OpenAPIComponents, JSONSchemaObject>>) {
        self.schema = schema
    }
}

/// An OpenAPI Path Item
/// This type describes the endpoints a server has
/// bound to a particular path.
public enum OpenAPIPathItem: Equatable {
    case reference(JSONReference<OpenAPIComponents, OpenAPIPathItem>)
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

        public typealias ParameterArray = [Either<Parameter, JSONReference<OpenAPIComponents, Parameter>>]

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

            public typealias SchemaProperty = Either<JSONSchemaObject, JSONReference<OpenAPIComponents, JSONSchemaObject>>

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
            public let operationId: String
            public let parameters: ParameterArray
            public let requestBody: OpenAPIRequest?
            public let responses: ResponseMap
            //            public let callbacks:
            public let deprecated: Bool // default is false
            //            public let security:
            //            public let servers:

            public init(tags: [String]? = nil,
                        summary: String? = nil,
                        description: String? = nil,
                        operationId: String,
                        parameters: ParameterArray,
                        requestBody: OpenAPIRequest? = nil,
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

            public typealias ResponseMap = [OpenAPIResponse.StatusCode: Either<OpenAPIResponse, JSONReference<OpenAPIComponents, OpenAPIResponse>>]

            public typealias ContentMap = [OpenAPIContentType: OpenAPIContent]
        }
    }
}

// MARK: - Codable

extension OpenAPIPathItem: Encodable {
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

extension OpenAPIPathItem.PathProperties.Operation: Encodable {
    private enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case description
        case externalDocs
        case operationId
        case parameters
        case requestBody
        case responses
        case callbacks
        case deprecated
        case security
        case servers
    }

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

        try container.encode(operationId, forKey: .operationId)

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

extension OpenAPIPathItem.PathProperties.Parameter: Encodable {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool?
        let location: String
        switch parameterLocation {
        case .query(required: let req):
            required = req
            location = "query"
        case .header(required: let req):
            required = req
            location = "header"
        case .path:
            required = true
            location = "path"
        case .cookie(required: let req):
            required = req
            location = "cookie"
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

        try container.encode(deprecated, forKey: .deprecated)
    }
}

extension OpenAPIPathItem.PathProperties: Encodable {
    private enum CodingKeys: String, CodingKey {
        case summary
        case description
        case servers
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
