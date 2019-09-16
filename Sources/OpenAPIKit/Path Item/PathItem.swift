//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly

extension OpenAPI {
    public enum HttpVerb: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
    }
}

extension OpenAPI {
    public struct PathComponents: RawRepresentable, Equatable, Hashable {
        public let components: [String]

        public init(_ components: [String]) {
            self.components = components
        }

        public init?(rawValue: String) {
            components = rawValue.split(separator: "/").map(String.init)
        }

        public var rawValue: String {
            return "/\(components.joined(separator: "/"))"
        }
    }

    /// An OpenAPI Path Item
    /// This type describes the endpoints a server has
    /// bound to a particular path.
    public enum PathItem: Equatable {
        case reference(JSONReference<Components, PathItem>)
        case operations(Properties)

        public typealias Map = [PathComponents: PathItem]
    }
}

extension OpenAPI.PathItem {
    public struct Properties: Equatable {
        public let summary: String?
        public let description: String?
        public let servers: [OpenAPI.Server]?
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
                    servers: [OpenAPI.Server]? = nil,
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
            self.servers = servers
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

extension OpenAPI.PathItem.Properties {
    public func `for`(_ verb: OpenAPI.HttpVerb) -> Operation? {
        switch verb {
        case .delete:
            return self.delete
        case .get:
            return self.get
        case .head:
            return self.head
        case .options:
            return self.options
        case .patch:
            return self.patch
        case .post:
            return self.post
        case .put:
            return self.put
        }
    }
}

// MARK: - Codable

extension OpenAPI.PathComponents: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension OpenAPI.PathComponents: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let rawValue = try container.decode(String.self)

        components = rawValue.split(separator: "/").map(String.init)
    }
}

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

        let maybeRef: Result<JSONReference<OpenAPI.Components, OpenAPI.PathItem>, Swift.Error>
        do {
            maybeRef = .success(try container.decode(JSONReference<OpenAPI.Components, OpenAPI.PathItem>.self))
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

        if servers != nil {
            try container.encode(servers, forKey: .servers)
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

        servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers)

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
