//
//  DocumentInfo.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import Foundation

extension OpenAPI.Document {
    public struct Info: Codable {
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

        public struct Contact: Codable {
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

// TODO: Contacts codable

// TODO: Info codable
