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
        public var tags: [String]?
        public var summary: String?
        public var description: String?
        public var externalDocs: OpenAPI.ExternalDoc?
        public var operationId: String?
        public var parameters: Parameter.Array
        public var requestBody: Either<JSONReference<OpenAPI.Components, OpenAPI.Request>, OpenAPI.Request>?
        public var responses: OpenAPI.Response.Map
        //            public let callbacks:
        public var deprecated: Bool // default is false
        public var security: [OpenAPI.SecurityRequirement]? // must be optional because an empty array here overrides a populated array in `Document`
        public var servers: [OpenAPI.Server]?

        public init(tags: [String]? = nil,
                    summary: String? = nil,
                    description: String? = nil,
                    externalDocs: OpenAPI.ExternalDoc? = nil,
                    operationId: String? = nil,
                    parameters: Parameter.Array = [],
                    requestBody: OpenAPI.Request? = nil,
                    responses: OpenAPI.Response.Map,
                    deprecated: Bool = false,
                    security: [OpenAPI.SecurityRequirement]? = nil,
                    servers: [OpenAPI.Server]? = nil) {
            self.tags = tags
            self.summary = summary
            self.description = description
            self.externalDocs = externalDocs
            self.operationId = operationId
            self.parameters = parameters
            self.requestBody = requestBody.map(Either.init)
            self.responses = responses
            self.deprecated = deprecated
            self.security = security
            self.servers = servers
        }

        // variadic tags
        public init(tags: String...,
                    summary: String? = nil,
                    description: String? = nil,
                    externalDocs: OpenAPI.ExternalDoc? = nil,
                    operationId: String? = nil,
                    parameters: Parameter.Array,
                    requestBody: OpenAPI.Request? = nil,
                    responses: OpenAPI.Response.Map,
                    deprecated: Bool = false,
                    security: [OpenAPI.SecurityRequirement]? = nil,
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
                security: security,
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
        case security
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

        try container.encode(responses, forKey: .responses)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        if let securityRequirements = security {
            try encodeSecurity(requirements: securityRequirements, to: &container, forKey: .security)
        }

        try servers.encodeIfNotNil(to: &container, forKey: .servers)
    }
}

extension OpenAPI.PathItem.Operation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            tags = try container.decodeIfPresent([String].self, forKey: .tags)

            summary = try container.decodeIfPresent(String.self, forKey: .summary)

            description = try container.decodeIfPresent(String.self, forKey: .description)

            externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)

            operationId = try container.decodeIfPresent(String.self, forKey: .operationId)

            parameters = try container.decodeIfPresent(OpenAPI.PathItem.Parameter.Array.self, forKey: .parameters) ?? []

            requestBody = try container.decodeIfPresent(Either<JSONReference<OpenAPI.Components, OpenAPI.Request>, OpenAPI.Request>.self, forKey: .requestBody)

            responses = try container.decode(OpenAPI.Response.Map.self, forKey: .responses)

            deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false

            // TODO: would be ideal to validate against components from here, but not
            //      sure off the top of my head the best way to go about that other than
            // perhaps storing a copy of components in the userInfo for the decoder.
            security = try decodeSecurityRequirements(from: container, forKey: .security, given: nil)

            servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers)
        } catch let error as DecodingError {

            var codingPath = error.codingPath.dropFirst(2)
            let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

            throw OpenAPI.Error.Decoding.Operation(
                endpoint: verb,
                context: .generic(error.replacingPath(with: Array(codingPath))),
                codingPath: error.codingPath
            )
        }
    }
}
