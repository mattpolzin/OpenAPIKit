//
//  DocumentInfo.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI.Document {
    /// OpenAPI Spec "Info Object"
    ///
    /// See [OpenAPI Info Object](https://spec.openapis.org/oas/v3.1.1.html#info-object).
    public struct Info: Equatable, CodableVendorExtendable, Sendable {
        public var title: String
        public var summary: String?
        public var description: String?
        public var termsOfService: URL?
        public var contact: Contact?
        public var license: License?
        public var version: String

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            title: String,
            summary: String? = nil,
            description: String? = nil,
            termsOfService: URL? = nil,
            contact: Contact? = nil,
            license: License? = nil,
            version: String,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.title = title
            self.summary = summary
            self.description = description
            self.termsOfService = termsOfService
            self.contact = contact
            self.license = license
            self.version = version
            self.vendorExtensions = vendorExtensions
        }

        /// OpenAPI Spec "Contact Object"
        ///
        /// See [OpenAPI Contact Object](https://spec.openapis.org/oas/v3.1.1.html#contact-object).
        public struct Contact: Equatable, CodableVendorExtendable, Sendable {
            public let name: String?
            public let url: URL?
            public let email: String?

            /// Dictionary of vendor extensions.
            ///
            /// These should be of the form:
            /// `[ "x-extensionKey": <anything>]`
            /// where the values are anything codable.
            public var vendorExtensions: [String: AnyCodable]

            public init(
                name: String? = nil,
                url: URL? = nil,
                email: String? = nil,
                vendorExtensions: [String: AnyCodable] = [:]
            ) {
                self.name = name
                self.url = url
                self.email = email
                self.vendorExtensions = vendorExtensions
            }
        }

        /// OpenAPI Spec "License Object"
        ///
        /// See [OpenAPI License Object](https://spec.openapis.org/oas/v3.1.1.html#license-object).
        public struct License: Equatable, CodableVendorExtendable, Sendable {
            public let name: String
            public let identifier: Identifier?

            /// Dictionary of vendor extensions.
            ///
            /// These should be of the form:
            /// `[ "x-extensionKey": <anything>]`
            /// where the values are anything codable.
            public var vendorExtensions: [String: AnyCodable]

            /// Create a License that optionally points to a URL containing
            /// detailed information.
            public init(
                name: String,
                url: URL? = nil,
                vendorExtensions: [String: AnyCodable] = [:]
            ) {
                self.name = name
                self.identifier = url.map { .url($0) }
                self.vendorExtensions = vendorExtensions
            }

            /// Create a License that contains an SPDX identifier.
            public init(
                name: String,
                spdxIdentifier: String,
                vendorExtensions: [String: AnyCodable] = [:]
            ) {
                self.name = name
                self.identifier = .spdx(spdxIdentifier)
                self.vendorExtensions = vendorExtensions
            }

            /// The `identifier`/`url` property of the OpenAPI Spec "License Object"
            /// that can be either a URL or an SPDX identifier.
            public enum Identifier: Equatable, Sendable {
                case url(URL)
                /// See https://spdx.dev/spdx-specification-21-web-version/#h.jxpfx0ykyb60
                /// for more on SPDX.
                case spdx(String)
            }
        }
    }
}

extension OpenAPI.Document.Info.License {
    // MARK: MIT License
    public static func MIT(url: URL) -> Self {
        return .init(name: "MIT", url: url)
    }

    public static var MIT: Self {
        return .init(name: "MIT", url: URL(string: "https://www.mit.edu/~amini/LICENSE.md")!)
    }

    // MARK: Apache License
    public static func apache2(url: URL) -> Self {
        return .init(name: "Apache 2.0", url: url)
    }

    public static var apache2: Self {
        return .init(name: "Apache 2.0", url: URL(string: "https://www.apache.org/licenses/LICENSE-2.0.txt")!)
    }
}

// MARK: - Describable & Summarizable
extension OpenAPI.Document.Info : OpenAPISummarizable {
    public func overriddenNonNil(summary: String?) -> OpenAPI.Document.Info {
        guard let summary = summary else { return self }
        return OpenAPI.Document.Info(
            title: title,
            summary: summary,
            description: description,
            termsOfService: termsOfService,
            contact: contact,
            license: license,
            version: version,
            vendorExtensions: vendorExtensions
        )
    }

    public func overriddenNonNil(description: String?) -> OpenAPI.Document.Info {
        guard let description = description else { return self }
        return OpenAPI.Document.Info(
            title: title,
            summary: summary,
            description: description,
            termsOfService: termsOfService,
            contact: contact,
            license: license,
            version: version,
            vendorExtensions: vendorExtensions
        )
    }
}

// MARK: - Codable
extension OpenAPI.Document.Info.License: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        if let identifier = self.identifier {
            switch identifier {
            case .spdx(let string):
                try container.encodeIfPresent(string, forKey: .identifier)
            case .url(let url):
                try container.encodeIfPresent(url.absoluteString, forKey: .url)
            }
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Document.Info.License: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        if let url = try container.decodeURLAsStringIfPresent(forKey: .url) {
            identifier = .url(url)
        } else if let string = try container.decodeIfPresent(String.self, forKey: .identifier) {
            identifier = .spdx(string)
        } else {
            identifier = nil
        }

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Document.Info.License {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case url
        case identifier

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
                .url,
                .identifier
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "name":
                self = .name
            case "url":
                self = .url
            case "identifier":
                self = .identifier
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .name:
                return "name"
            case .url:
                return "url"
            case .identifier:
                return "identifier"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Document.Info.Contact: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(url?.absoluteString, forKey: .url)
        try container.encodeIfPresent(email, forKey: .email)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Document.Info.Contact: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)
        url = try container.decodeURLAsStringIfPresent(forKey: .url)
        email = try container.decodeIfPresent(String.self, forKey: .email)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Document.Info.Contact {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case url
        case email

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
                .url,
                .email
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "name":
                self = .name
            case "url":
                self = .url
            case "email":
                self = .email
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .name:
                return "name"
            case .url:
                return "url"
            case .email:
                return "email"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Document.Info: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(termsOfService?.absoluteString, forKey: .termsOfService)
        try container.encodeIfPresent(contact, forKey: .contact)
        try container.encodeIfPresent(license, forKey: .license)
        try container.encode(version, forKey: .version)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Document.Info: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        termsOfService = try container.decodeURLAsStringIfPresent(forKey: .termsOfService)
        contact = try container.decodeIfPresent(Contact.self, forKey: .contact)
        license = try container.decodeIfPresent(License.self, forKey: .license)
        version = try container.decode(String.self, forKey: .version)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Document.Info {
    internal enum CodingKeys: ExtendableCodingKey {
        case title
        case summary
        case description
        case termsOfService
        case contact
        case license
        case version
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .title,
                .summary,
                .description,
                .termsOfService,
                .contact,
                .license,
                .version
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "title":
                self = .title
            case "summary":
                self = .summary
            case "description":
                self = .description
            case "termsOfService":
                self = .termsOfService
            case "contact":
                self = .contact
            case "license":
                self = .license
            case "version":
                self = .version
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .title:
                return "title"
            case .summary:
                return "summary"
            case .description:
                return "description"
            case .termsOfService:
                return "termsOfService"
            case .contact:
                return "contact"
            case .license:
                return "license"
            case .version:
                return "version"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Document.Info: Validatable {}
extension OpenAPI.Document.Info.Contact: Validatable {}
extension OpenAPI.Document.Info.License: Validatable {}
