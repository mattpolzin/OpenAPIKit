//
//  PathItem.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

extension OpenAPI {
    /// OpenAPI Spec "Paths Object" path field pattern support.
    ///
    /// See [OpenAPI Paths Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#paths-object)
    /// and [OpenAPI Patterned Fields](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#patterned-fields).
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
    /// 
    /// See [OpenAPI Path Item Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#path-item-object).
    public struct PathItem: Equatable, CodableVendorExtendable {
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

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            summary: String? = nil,
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
            trace: Operation? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
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
            self.vendorExtensions = vendorExtensions
        }

        /// Set the `GET` endpoint operation.
        public mutating func get(_ op: Operation?) {
            get = op
        }

        /// Set the `PUT` endpoint operation.
        public mutating func put(_ op: Operation?) {
            put = op
        }

        /// Set the `POST` endpoint operation.
        public mutating func post(_ op: Operation?) {
            post = op
        }

        /// Set the `DELETE` endpoint operation.
        public mutating func delete(_ op: Operation?) {
            delete = op
        }

        /// Set the `OPTIONS` endpoint operation.
        public mutating func options(_ op: Operation?) {
            options = op
        }

        /// Set the `HEAD` endpoint operation.
        public mutating func head(_ op: Operation?) {
            head = op
        }

        /// Set the `PATCH` endpoint operation.
        public mutating func patch(_ op: Operation?) {
            patch = op
        }

        /// Set the `TRACE` endpoint operation.
        public mutating func trace(_ op: Operation?) {
            trace = op
        }
    }
}

extension OpenAPI.PathItem {
    public typealias Map = OrderedDictionary<OpenAPI.Path, OpenAPI.PathItem>
}

extension OpenAPI.PathItem {
    /// Retrieve the operation for the given verb, if one is set for this path.
    public func `for`(_ verb: OpenAPI.HttpMethod) -> OpenAPI.Operation? {
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

    /// Set the operation for the given verb, overwriting any already set operation for the same verb.
    public mutating func set(operation: OpenAPI.Operation?, for verb: OpenAPI.HttpMethod) {
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

    public subscript(verb: OpenAPI.HttpMethod) -> OpenAPI.Operation? {
        get {
            return `for`(verb)
        }
        set {
            set(operation: newValue, for: verb)
        }
    }

    /// An `Endpoint` is the combination of an
    /// HTTP method and an operation.
    public struct Endpoint: Equatable {
        public let method: OpenAPI.HttpMethod
        public let operation: OpenAPI.Operation
    }

    /// Get all endpoints defined at this path.
    ///
    /// - Returns: An array of `Endpoints` with the method (i.e. `.get`) and the operation for
    ///     the method.
    public var endpoints: [Endpoint] {
        return OpenAPI.HttpMethod.allCases.compactMap { method in
            self.for(method).map { .init(method: method, operation: $0) }
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

extension OpenAPI.PathItem: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(servers, forKey: .servers)

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        try container.encodeIfPresent(get, forKey: .get)
        try container.encodeIfPresent(put, forKey: .put)
        try container.encodeIfPresent(post, forKey: .post)
        try container.encodeIfPresent(delete, forKey: .delete)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(head, forKey: .head)
        try container.encodeIfPresent(patch, forKey: .patch)
        try container.encodeIfPresent(trace, forKey: .trace)

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.PathItem: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            summary = try container.decodeIfPresent(String.self, forKey: .summary)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers)
            parameters = try container.decodeIfPresent(OpenAPI.Parameter.Array.self, forKey: .parameters) ?? []

            get = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .get)
            put = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .put)
            post = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .post)
            delete = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .delete)
            options = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .options)
            head = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .head)
            patch = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .patch)
            trace = try container.decodeIfPresent(OpenAPI.Operation.self, forKey: .trace)

            vendorExtensions = try Self.extensions(from: decoder)
        } catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Path(error)
        } catch let error as InconsistencyError {

            throw OpenAPI.Error.Decoding.Path(error)
        } catch let error as OpenAPI.Error.Decoding.Operation {

            throw OpenAPI.Error.Decoding.Path(error)
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Path(error)
        }
    }
}

extension OpenAPI.PathItem {
    internal enum CodingKeys: ExtendableCodingKey {
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

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .summary,
                .description,
                .servers,
                .parameters,
                
                .get,
                .put,
                .post,
                .delete,
                .options,
                .head,
                .patch,
                .trace
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "summary":
                self = .summary
            case "description":
                self = .description
            case "servers":
                self = .servers
            case "parameters":
                self = .parameters
            case "get":
                self = .get
            case "put":
                self = .put
            case "post":
                self = .post
            case "delete":
                self = .delete
            case "options":
                self = .options
            case "head":
                self = .head
            case "patch":
                self = .patch
            case "trace":
                self = .trace
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .summary:
                return "summary"
            case .description:
                return "description"
            case .servers:
                return "servers"
            case .parameters:
                return "parameters"
            case .get:
                return "get"
            case .put:
                return "put"
            case .post:
                return "post"
            case .delete:
                return "delete"
            case .options:
                return "options"
            case .head:
                return "head"
            case .patch:
                return "patch"
            case .trace:
                return "trace"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.PathItem: Validatable {}
