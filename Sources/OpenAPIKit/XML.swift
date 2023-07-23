//
//  XML.swift
//  
//
//  Created by Mathew Polzin on 1/15/20.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "XML Object"
    ///
    /// See [OpenAPI XML Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#xml-object).
    public struct XML: Equatable {
        public let name: String?
        public let namespace: URL?
        public let prefix: String?
        public let attribute: Bool // default is false
        public let wrapped: Bool // default is false

        public init(
            name: String? = nil,
            namespace: URL? = nil,
            prefix: String? = nil,
            attribute: Bool = false,
            wrapped: Bool = false
        ) {
            self.name = name
            self.namespace = namespace
            self.prefix = prefix
            self.attribute = attribute
            self.wrapped = wrapped
        }
    }
}

// MARK: - Codable
extension OpenAPI.XML {
    private enum CodingKeys: String, CodingKey {
        case name
        case namespace
        case prefix
        case attribute
        case wrapped
    }
}

extension OpenAPI.XML: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(namespace?.absoluteString, forKey: .namespace)
        try container.encodeIfPresent(prefix, forKey: .prefix)
        if attribute {
            try container.encode(true, forKey: .attribute)
        }
        if wrapped {
            try container.encode(true, forKey: .wrapped)
        }
    }
}

extension OpenAPI.XML: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)
        namespace = try container.decodeURLAsStringIfPresent(forKey: .namespace)
        prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
        attribute = try container.decodeIfPresent(Bool.self, forKey: .attribute) ?? false
        wrapped = try container.decodeIfPresent(Bool.self, forKey: .wrapped) ?? false
    }
}
