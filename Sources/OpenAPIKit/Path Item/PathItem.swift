//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly
import OrderedDictionary

extension OpenAPI {
    /// OpenAPI Spec "Paths Object" path field pattern support.
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#paths-object
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#patterned-fields
    public struct Path: RawRepresentable, Equatable, Hashable {
        public let components: [String]

        public init(_ components: [String]) {
            self.components = components
        }

        public init(rawValue: String) {
            let pathComponents = rawValue.split(separator: "/").map(String.init)
            components = pathComponents.count > 0 && pathComponents[0].isEmpty
                ? Array(pathComponents.dropFirst())
                : pathComponents
        }

        public var rawValue: String {
            return "/\(components.joined(separator: "/"))"
        }
    }
}

extension OpenAPI.Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension OpenAPI {
    /// OpenAPI Spec "Path Item Object"
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#path-item-object
    public struct PathItem: Equatable {
        public var summary: String?
        public var description: String?
        public var servers: [OpenAPI.Server]?
        public var parameters: Parameter.Array

        public var get: Operation?
        public var put: Operation?
        public var post: Operation?
        public var delete: Operation?
        public var options: Operation?
        public var head: Operation?
        public var patch: Operation?
        public var trace: Operation?

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

        public mutating func get(_ op: Operation?) {
            get = op
        }

        public mutating func put(_ op: Operation?) {
            put = op
        }

        public mutating func post(_ op: Operation?) {
            post = op
        }

        public mutating func delete(_ op: Operation?) {
            delete = op
        }

        public mutating func options(_ op: Operation?) {
            options = op
        }

        public mutating func head(_ op: Operation?) {
            head = op
        }

        public mutating func patch(_ op: Operation?) {
            patch = op
        }

        public mutating func trace(_ op: Operation?) {
            trace = op
        }

        public typealias Map = OrderedDictionary<Path, PathItem>
    }
}

extension OpenAPI.PathItem {
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
        case .trace:
            return self.trace
        }
    }

    public mutating func set(operation: Operation?, for verb: OpenAPI.HttpVerb) {
        switch verb {
        case .delete:
            self.delete(operation)
        case .get:
            self.get(operation)
        case .head:
            self.head(operation)
        case .options:
            self.options(operation)
        case .patch:
            self.patch(operation)
        case .post:
            self.post(operation)
        case .put:
            self.put(operation)
        case .trace:
            self.trace(operation)
        }
    }

    public subscript(verb: OpenAPI.HttpVerb) -> Operation? {
        get {
            return `for`(verb)
        }
        set {
            set(operation: newValue, for: verb)
        }
    }
}

// MARK: - Codable

extension OpenAPI.Path: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension OpenAPI.Path: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let rawValue = try container.decode(String.self)

        self.init(rawValue: rawValue)
    }
}

extension OpenAPI.PathItem {
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

extension OpenAPI.PathItem: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try summary.encodeIfNotNil(to: &container, forKey: .summary)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        try servers.encodeIfNotNil(to: &container, forKey: .servers)

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        try get.encodeIfNotNil(to: &container, forKey: .get)
        try put.encodeIfNotNil(to: &container, forKey: .put)
        try post.encodeIfNotNil(to: &container, forKey: .post)
        try delete.encodeIfNotNil(to: &container, forKey: .delete)
        try options.encodeIfNotNil(to: &container, forKey: .options)
        try head.encodeIfNotNil(to: &container, forKey: .head)
        try patch.encodeIfNotNil(to: &container, forKey: .patch)
        try trace.encodeIfNotNil(to: &container, forKey: .trace)
    }
}

extension OpenAPI.PathItem: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
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
        }  catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Path(error)
        } catch let error as OpenAPI.Error.Decoding.Operation {

            throw OpenAPI.Error.Decoding.Path(error)
        } catch let error as PolyDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Path(error)
        }
    }
}
