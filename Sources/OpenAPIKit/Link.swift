//
//  Link.swift
//  
//
//  Created by Mathew Polzin on 1/23/20.
//

// TODO: create validation that operationIds in Link objects
//       refer to Operation objects in the document that have the
//       given ids.

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Link Object"
    ///
    /// See [OpenAPI Link Object](https://spec.openapis.org/oas/v3.2.0.html#link-object).
    public struct Link: Equatable, CodableVendorExtendable, Sendable {
        /// The **OpenAPI**` `operationRef` or `operationId` field, depending on whether
        /// a `URL` of a remote or local Operation Object or a `operationId` (String) of an
        /// operation defined in the same document is given.
        public var operation: Either<URL, String>
        /// A map from parameter names to either runtime expressions that evaluate to values or
        /// constant values (`AnyCodable`).
        ///
        /// See the docuemntation for the [OpenAPI Link Object](https://spec.openapis.org/oas/v3.2.0.html#link-object) for more details.
        ///
        /// Empty dictionaries will be omitted from encoding.
        public var parameters: OrderedDictionary<String, Either<RuntimeExpression, AnyCodable>>
        /// A literal value or expression to use as a request body when calling the target operation.
        public var requestBody: Either<RuntimeExpression, AnyCodable>?
        public var description: String?
        public var server: Server?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            operation: Either<URL, String>,
            parameters: OrderedDictionary<String, Either<RuntimeExpression, AnyCodable>> = [:],
            requestBody: Either<RuntimeExpression, AnyCodable>? = nil,
            description: String? = nil,
            server: Server? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.operation = operation
            self.parameters = parameters
            self.requestBody = requestBody
            self.description = description
            self.server = server
            self.vendorExtensions = vendorExtensions
        }

        /// Create a Link by referring to an `operationId` of some `Operation` elsewhere
        /// in the same document.
        public init(
            operationId: String,
            parameters: OrderedDictionary<String, Either<RuntimeExpression, AnyCodable>> = [:],
            requestBody: Either<RuntimeExpression, AnyCodable>? = nil,
            description: String? = nil,
            server: Server? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.init(
                operation: .b(operationId),
                parameters: parameters,
                requestBody: requestBody,
                description: description,
                server: server,
                vendorExtensions: vendorExtensions
            )
        }

        /// Create a Link by referring to an `operationRef` pointing to an `Operation`
        /// either in the same document or elsewhere.
        public init(
            operationRef: URL,
            parameters: OrderedDictionary<String, Either<RuntimeExpression, AnyCodable>> = [:],
            requestBody: Either<RuntimeExpression, AnyCodable>? = nil,
            description: String? = nil,
            server: Server? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.init(
                operation: .a(operationRef),
                parameters: parameters,
                requestBody: requestBody,
                description: description,
                server: server,
                vendorExtensions: vendorExtensions
            )
        }
    }
}

extension OpenAPI.Link {
    public typealias Map = OrderedDictionary<String, Either<OpenAPI.Reference<OpenAPI.Link>, OpenAPI.Link>>
}

// MARK: `Either` convenience methods
extension Either where A == OpenAPI.Reference<OpenAPI.Link>, B == OpenAPI.Link {

    public static func link(
        operationId: String,
        parameters: OrderedDictionary<String, Either<OpenAPI.RuntimeExpression, AnyCodable>> = [:],
        requestBody: Either<OpenAPI.RuntimeExpression, AnyCodable>? = nil,
        description: String? = nil,
        server: OpenAPI.Server? = nil
    ) -> Self {
        return .b(
            .init(
                operationId: operationId,
                parameters: parameters,
                requestBody: requestBody,
                description: description,
                server: server
            )
        )
    }

    public static func link(
        operationRef: URL,
        parameters: OrderedDictionary<String, Either<OpenAPI.RuntimeExpression, AnyCodable>> = [:],
        requestBody: Either<OpenAPI.RuntimeExpression, AnyCodable>? = nil,
        description: String? = nil,
        server: OpenAPI.Server? = nil
    ) -> Self {
        return .b(
            .init(
                operationRef: operationRef,
                parameters: parameters,
                requestBody: requestBody,
                description: description,
                server: server
            )
        )
    }
}

// MARK: - Describable

extension OpenAPI.Link: OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Link {
        guard let description = description else { return self }
        var link = self
        link.description = description
        return link
    }
}

// MARK: - Codable

extension OpenAPI.Link: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch operation {
        case .a(let url):
            try container.encode(url.absoluteString, forKey: .operationRef)
        case .b(let id):
            try container.encode(id, forKey: .operationId)
        }

        if !parameters.isEmpty {
            try container.encode(parameters, forKey: .parameters)
        }

        try container.encodeIfPresent(requestBody, forKey: .requestBody)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(server, forKey: .server)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Link: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let operationString = try container.decodeIfPresent(String.self, forKey: .operationId) {
            operation = .b(operationString)
        } else {
            operation = .a(try container.decodeURLAsString(forKey: .operationRef))
        }

        parameters = try container.decodeIfPresent(OrderedDictionary<String, Either<OpenAPI.RuntimeExpression, AnyCodable>>.self, forKey: .parameters) ?? [:]

        requestBody = try container.decodeIfPresent(Either<OpenAPI.RuntimeExpression, AnyCodable>.self, forKey: .requestBody)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        server = try container.decodeIfPresent(OpenAPI.Server.self, forKey: .server)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Link {
    internal enum CodingKeys: ExtendableCodingKey {
        case operationId
        case operationRef
        case parameters
        case requestBody
        case description
        case server

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .operationId,
                .operationRef,
                .parameters,
                .requestBody,
                .description,
                .server
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "operationId":
                self = .operationId
            case "operationRef":
                self = .operationRef
            case "parameters":
                self = .parameters
            case "requestBody":
                self = .requestBody
            case "description":
                self = .description
            case "server":
                self = .server
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .operationId:
                return "operationId"
            case .operationRef:
                return "operationRef"
            case .parameters:
                return "parameters"
            case .requestBody:
                return "requestBody"
            case .description:
                return "description"
            case .server:
                return "server"
            case .extended(let key):
                return key
            }
        }
    }
}

// MARK: - LocallyDereferenceable
extension OpenAPI.Link: LocallyDereferenceable {
    /// Links do not contain any references but for convenience
    /// they can be "dereferenced" to themselves.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> OpenAPI.Link {
        var vendorExtensions = self.vendorExtensions
        if let name {
            vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        return .init(
            operation: operation,
            parameters: parameters,
            requestBody: requestBody,
            description: description,
            server: server,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPI.Link: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        let (newServer, newComponents, newMessages) = try await server.externallyDereferenced(with: loader)

        var newLink = self
        newLink.server = newServer

        return (newLink, newComponents, newMessages)
    }
}

extension OpenAPI.Link: Validatable {}
