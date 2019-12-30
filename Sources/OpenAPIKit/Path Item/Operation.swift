//
//  Operation.swift
//  
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly

extension OpenAPI.PathItem {
    public struct Operation: Equatable {
        public let tags: [String]?
        public let summary: String?
        public let description: String?
        public let externalDocs: OpenAPI.ExternalDoc?
        public let operationId: String?
        public let parameters: Parameter.Array
        public let requestBody: OpenAPI.Request?
        public let responses: OpenAPI.Response.Map
        //            public let callbacks:
        public let deprecated: Bool // default is false
        //            public let security:
        public let servers: [OpenAPI.Server]?

        public init(tags: [String]? = nil,
                    summary: String? = nil,
                    description: String? = nil,
                    externalDocs: OpenAPI.ExternalDoc? = nil,
                    operationId: String? = nil,
                    parameters: Parameter.Array,
                    requestBody: OpenAPI.Request? = nil,
                    responses: OpenAPI.Response.Map,
                    deprecated: Bool = false,
                    servers: [OpenAPI.Server]? = nil) {
            self.tags = tags
            self.summary = summary
            self.description = description
            self.externalDocs = externalDocs
            self.operationId = operationId
            self.parameters = parameters
            self.requestBody = requestBody
            self.responses = responses
            self.deprecated = deprecated
            self.servers = servers
        }

        public init(tags: String...,
                    summary: String? = nil,
                    description: String? = nil,
                    externalDocs: OpenAPI.ExternalDoc? = nil,
                    operationId: String? = nil,
                    parameters: Parameter.Array,
                    requestBody: OpenAPI.Request? = nil,
                    responses: OpenAPI.Response.Map,
                    deprecated: Bool = false,
                    servers: [OpenAPI.Server]? = nil) {
            self.init(
                tags: tags,
                summary: summary,
                description: description,
                externalDocs: externalDocs,
                operationId: operationId,
                parameters: parameters,
                requestBody: requestBody,
                responses: responses,
                deprecated: deprecated,
                servers: servers
            )
        }
    }
}

// MARK: - Codable

extension OpenAPI.PathItem.Operation {
    private enum CodingKeys: String, CodingKey {
        case tags
        case summary
        case description
        case externalDocs
        case operationId
        case parameters
        case requestBody
        case responses
        //        case callbacks
        case deprecated
        //        case security
        case servers
    }
}

extension OpenAPI.PathItem.Operation: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try tags.encodeIfNotNil(to: &container, forKey: .tags)

        try summary.encodeIfNotNil(to: &container, forKey: .summary)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        try externalDocs.encodeIfNotNil(to: &container, forKey: .externalDocs)

        try operationId.encodeIfNotNil(to: &container, forKey: .operationId)

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        try requestBody.encodeIfNotNil(to: &container, forKey: .requestBody)

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            responses.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .responses)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        try servers.encodeIfNotNil(to: &container, forKey: .servers)
    }
}

extension OpenAPI.PathItem.Operation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        tags = try container.decodeIfPresent([String].self, forKey: .tags)

        summary = try container.decodeIfPresent(String.self, forKey: .summary)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)

        operationId = try container.decodeIfPresent(String.self, forKey: .operationId)

        parameters = try container.decodeIfPresent(OpenAPI.PathItem.Parameter.Array.self, forKey: .parameters) ?? []

        requestBody = try container.decodeIfPresent(OpenAPI.Request.self, forKey: .requestBody)

        // hack to workaround Dictionary bug
        let responsesDict = try container.decode([String: Either<OpenAPI.Response, JSONReference<OpenAPI.Components, OpenAPI.Response>>].self, forKey: .responses)
        responses = Dictionary(responsesDict.compactMap { statusCodeString, response in
            OpenAPI.Response.StatusCode(rawValue: statusCodeString).map { ($0, response) } },
                               uniquingKeysWith: { $1 })

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false

        servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers)
    }
}
