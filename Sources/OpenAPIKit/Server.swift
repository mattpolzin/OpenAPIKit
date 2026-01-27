//
//  Server.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Server Object"
    ///
    /// See [OpenAPI Server Object](https://spec.openapis.org/oas/v3.2.0.html#server-object).
    ///
    public struct Server: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        /// OpenAPI Server URLs can have variable placeholders in them.
        /// The `urlTemplate` can be asked for a well-formed Foundation
        /// `URL` if all variables in it have been replaced by constant values.
        public let urlTemplate: URLTemplate
        /// An optional unique string to refer to the host designated by the URL.
        public let name: String?
        public let description: String?
        /// A map from the names of variables found in the `urlTemplate` to
        /// descriptions, allowed values, and defaults.
        public let variables: OrderedDictionary<String, Variable>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        /// Create an OpenAPI Server Object.
        public init(
            url: URL,
            name: String? = nil,
            description: String? = nil,
            variables: OrderedDictionary<String, Variable> = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.urlTemplate = URLTemplate(url: url)
            self.name = name
            self.description = description
            self.variables = variables
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = [
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Server", fieldName: "name", value: name, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }

        /// Create an OpenAPI Server Object with a URL containing
        /// variables that can change depending on the context in
        /// which the API is invoked,
        public init(
            urlTemplate: URLTemplate,
            name: String? = nil,
            description: String? = nil,
            variables: OrderedDictionary<String, Variable> = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.urlTemplate = urlTemplate
            self.name = name
            self.description = description
            self.variables = variables
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = [
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Server", fieldName: "name", value: name, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }
    }
}

extension OpenAPI.Server: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.urlTemplate == rhs.urlTemplate
        && lhs.description == rhs.description
        && lhs.variables == rhs.variables
        && lhs.vendorExtensions == rhs.vendorExtensions
    }
}

extension OpenAPI.Server {
    /// OpenAPI Spec "Server Variable Object"
    ///
    /// See [OpenAPI Server Variable Object](https://spec.openapis.org/oas/v3.2.0.html#server-variable-object).
    ///
    public struct Variable: Equatable, CodableVendorExtendable, Sendable {
        public var `enum`: [String]?
        public var `default`: String
        public var description: String?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            enum: [String]? = nil,
            default: String,
            description: String? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.enum = `enum`
            self.default = `default`
            self.description = description
            self.vendorExtensions = vendorExtensions
        }
    }
}

// MARK: - Describable

extension OpenAPI.Server : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Server {
        guard let description = description else { return self }
        return OpenAPI.Server(
            urlTemplate: urlTemplate,
            description: description,
            variables: variables,
            vendorExtensions: vendorExtensions
        )
    }
}

// MARK: - Codable
extension OpenAPI.Server: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(urlTemplate, forKey: .url)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)

        if variables.count > 0 {
            try container.encode(variables, forKey: .variables)
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Server: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        urlTemplate = try container.decode(URLTemplate.self, forKey: .url)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        variables = try container.decodeIfPresent(OrderedDictionary<String, Variable>.self, forKey: .variables) ?? [:]

        vendorExtensions = try Self.extensions(from: decoder)

        conditionalWarnings = [
            OASWarnings.Doc.nonNilVersionWarning(objectName: "Server", fieldName: "name", value: name, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }
}

extension OpenAPI.Server {
    internal enum CodingKeys: ExtendableCodingKey {
        case url
        case name
        case description
        case variables

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .url,
                .name,
                .description,
                .variables
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "url":
                self = .url
            case "name":
                self = .name
            case "description":
                self = .description
            case "variables":
                self = .variables
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .url:
                return "url"
            case .name:
                return "name"
            case .description:
                return "description"
            case .variables:
                return "variables"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Server.Variable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let `enum` = `enum`, !`enum`.isEmpty {
            try container.encode(`enum`, forKey: .enum)
        }

        try container.encode(`default`, forKey: .default)

        try container.encodeIfPresent(description, forKey: .description)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Server.Variable: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        `enum` = try container.decodeIfPresent([String].self, forKey: .enum) 

        `default` = try container.decode(String.self, forKey: .default)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Server.Variable {
    internal enum CodingKeys: ExtendableCodingKey {
        case `enum`
        case `default`
        case description
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .enum,
                .default,
                .description
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "enum":
                self = .enum
            case "default":
                self = .default
            case "description":
                self = .description
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .enum:
                return "enum"
            case .default:
                return "default"
            case .description:
                return "description"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Server: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        return (self, .init(), [])
    }
}

extension OpenAPI.Server: Validatable {}
extension OpenAPI.Server.Variable: Validatable {}
