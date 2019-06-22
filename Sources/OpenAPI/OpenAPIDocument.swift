//
//  OpenAPITypes.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/13/19.
//

import AnyCodable
import Foundation
import Poly
import Sampleable

public enum OpenAPICodableError: Swift.Error, Equatable {
	case allCasesArrayNotCodable
	case exampleNotCodable
	case primitiveGuessFailed
}

public enum OpenAPITypeError: Swift.Error {
	case invalidNode
	case unknownNodeType(Any.Type)
}

/// The root of an OpenAPI 3.0 document.
public struct OpenAPIDocument {
	public let openAPIVersion: Version
	public let info: Info
//	public let servers:
	public let paths: [PathComponents: OpenAPIPathItem]
	public let components: OpenAPIComponents
//	public let security:
//	public let tags:
//	public let externalDocs:

	public init(openAPIVersion: Version = .v3_0_0,
				info: Info,
				paths: [PathComponents: OpenAPIPathItem],
				components: OpenAPIComponents) {
		self.openAPIVersion = openAPIVersion
		self.info = info
		self.paths = paths
		self.components = components
	}

	public enum Version: String, Encodable {
		case v3_0_0 = "3.0.0"
	}

	public struct Info: Encodable {
		public let title: String
		public let description: String?
		public let termsOfService: URL?
//		public let contact:
//		public let license:
		public let version: String

		public init(title: String,
					description: String? = nil,
					termsOfService: URL? = nil,
					version: String) {
			self.title = title
			self.description = description
			self.termsOfService = termsOfService
			self.version = version
		}
	}

	public struct PathComponents: RawRepresentable, Encodable, Equatable, Hashable {
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

		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()

			try container.encode(rawValue)
		}
	}
}

// MARK: - Codable

extension OpenAPIDocument: Encodable {
    private enum CodingKeys: String, CodingKey {
        case openAPIVersion = "openapi"
        case info
        case servers
        case paths
        case components
        case security
        case tags
        case externalDocs
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(openAPIVersion, forKey: .openAPIVersion)

        try container.encode(info, forKey: .info)

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            paths.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .paths)

        try container.encode(components, forKey: .components)
    }
}
