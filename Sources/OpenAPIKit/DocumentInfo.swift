//
//  DocumentInfo.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import Foundation

extension OpenAPI.Document {
    public struct Info: Equatable {
        public let title: String
        public let description: String?
        public let termsOfService: URL?
        public let contact: Contact?
        public let license: License?
        public let version: String

        public init(title: String,
                    description: String? = nil,
                    termsOfService: URL? = nil,
                    contact: Contact? = nil,
                    license: License? = nil,
                    version: String) {
            self.title = title
            self.description = description
            self.termsOfService = termsOfService
            self.contact = contact
            self.license = license
            self.version = version
        }

        public struct Contact: Equatable {
            public let name: String?
            public let url: URL?
            public let email: String?

            public init(name: String? = nil,
                        url: URL? = nil,
                        email: String? = nil) {
                self.name = name
                self.url = url
                self.email = email
            }
        }

        public struct License: Equatable {
            public let name: String
            public let url: URL?

            public init(name: String,
                        url: URL? = nil) {
                self.name = name
                self.url = url
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
        return .init(name: "MIT")
    }

    // MARK: Apache License
    public static func apache2(url: URL) -> Self {
        return .init(name: "Apache 2.0", url: url)
    }

    public static var apache2: Self {
        return .init(name: "Apache 2.0")
    }
}

// MARK: - Codable
extension OpenAPI.Document.Info.License: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        try url.encodeIfNotNil(to: &container, forKey: .url)
    }
}

extension OpenAPI.Document.Info.License: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        url = try container.decodeIfPresent(URL.self, forKey: .url)
    }
}

extension OpenAPI.Document.Info.License {
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

extension OpenAPI.Document.Info.Contact: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try name.encodeIfNotNil(to: &container, forKey: .name)

        try url.encodeIfNotNil(to: &container, forKey: .url)

        try email.encodeIfNotNil(to: &container, forKey: .email)
    }
}

extension OpenAPI.Document.Info.Contact: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)

        url = try container.decodeIfPresent(URL.self, forKey: .url)

        email = try container.decodeIfPresent(String.self, forKey: .email)
    }
}

extension OpenAPI.Document.Info.Contact {
    enum CodingKeys: String, CodingKey {
        case name
        case url
        case email
    }
}

extension OpenAPI.Document.Info: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        try termsOfService.encodeIfNotNil(to: &container, forKey: .termsOfService)

        try contact.encodeIfNotNil(to: &container, forKey: .contact)

        try license.encodeIfNotNil(to: &container, forKey: .license)

        try container.encode(version, forKey: .version)
    }
}

extension OpenAPI.Document.Info: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        termsOfService = try container.decodeIfPresent(URL.self, forKey: .termsOfService)

        contact = try container.decodeIfPresent(Contact.self, forKey: .contact)

        license = try container.decodeIfPresent(License.self, forKey: .license)

        version = try container.decode(String.self, forKey: .version)
    }
}

extension OpenAPI.Document.Info {
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case termsOfService
        case contact
        case license
        case version
    }
}
