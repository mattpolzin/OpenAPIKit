//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly

extension OpenAPI {
    /// An OpenAPI Path Item
    /// This type describes the endpoints a server has
    /// bound to a particular path.
    public enum PathItem: Equatable {
        case reference(JSONReference<Components, PathItem>)
        case operations(Properties)
    }
}

extension OpenAPI.PathItem {
    public struct Properties: Equatable {
        public let summary: String?
        public let description: String?
        //        public let servers:
        public let parameters: Parameter.Array

        public let get: Operation?
        public let put: Operation?
        public let post: Operation?
        public let delete: Operation?
        public let options: Operation?
        public let head: Operation?
        public let patch: Operation?
        public let trace: Operation?

        public typealias Operation = OpenAPI.PathItem.Operation
        public typealias Parameter = OpenAPI.PathItem.Parameter

        public init(summary: String? = nil,
                    description: String? = nil,
                    parameters: Parameter.Array = [],
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

        let maybeOperations: Result<Properties, Swift.Error>
        do {
            maybeOperations = .success(try container.decode(Properties.self))
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

extension OpenAPI.PathItem.Properties {
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

extension OpenAPI.PathItem.Properties: Encodable {
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

extension OpenAPI.PathItem.Properties: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        summary = try container.decodeIfPresent(String.self, forKey: .summary)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        parameters = try container.decodeIfPresent(Parameter.Array.self, forKey: .parameters) ?? []

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
