//
//  XML.swift
//  

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "XML Object"
    ///
    /// See [OpenAPI XML Object](https://spec.openapis.org/oas/v3.2.0.html#xml-object).
    public struct XML: HasConditionalWarnings, Sendable {
        public let name: String?
        public let namespace: URL?
        public let prefix: String?

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        /// The `OpenAPI.XML` "Structure" stores the following OpenAPI Spec fields:
        /// - `nodeType`
        /// - `attribute`
        /// - `wrapped`
        ///
        /// Note that per the specication, `nodeType` is mutually exclusive
        /// with either of `attribute` or `wrapped`. Prior to OAS 3.2.0 the
        /// `nodeType` field is not supported. Starting with OAS 3.2.0 the
        /// `attribute` and `wrapped` fields are deprecated in favor of the
        /// `nodeType` field.
        public let structure: Structure?

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
            self.structure = .legacy(attribute: attribute, wrapped: wrapped)

            self.conditionalWarnings = [
                nodeTypeVersionWarning(value: self.structure)
            ].compactMap { $0 }
        }

        public init(
            name: String? = nil,
            namespace: URL? = nil,
            prefix: String? = nil,
            nodeType: NodeType? = nil
        ) {
            self.name = name
            self.namespace = namespace
            self.prefix = prefix
            self.structure = nodeType.map(Structure.nodeType)

            self.conditionalWarnings = [
                nodeTypeVersionWarning(value: self.structure)
            ].compactMap { $0 }
        }
    }
}

fileprivate func nodeTypeVersionWarning(value: OpenAPI.XML.Structure?) -> (any Condition, OpenAPI.Warning)? {
    switch value {
        case nil: return nil
        case .legacy: return nil
        case .nodeType: return OpenAPI.Document.ConditionalWarnings.version(
                lessThan: .v3_2_0,
                doesNotSupport: "The XML Object nodeType field"
            )
    }
}

extension OpenAPI.XML {
    public enum Structure: Equatable, Sendable {
        case nodeType(NodeType)
        /// The defaults are `attribute: false, wrapped: false`.
        /// The recommended way to represent these legacy attributes for
        /// OpenAPI Spec 3.2.0 and above are:
        ///  - `attribute: true` -> `nodeType(.attribute)`
        ///  - `wrapped: true` -> `nodeType(.element)`
        case legacy(attribute: Bool, wrapped: Bool)
    }

    public enum NodeType: String, Codable, Equatable, Sendable {
        case element
        case attribute
        case text
        case cdata
        case none
    }
}

extension OpenAPI.XML: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
        && lhs.namespace == rhs.namespace
        && lhs.prefix == rhs.prefix
        && lhs.structure == rhs.structure
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
        case nodeType
    }
}

extension OpenAPI.XML: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(namespace?.absoluteString, forKey: .namespace)
        try container.encodeIfPresent(prefix, forKey: .prefix)
        switch structure {
        case nil:
            break
        case .nodeType(let nodeType):
            try container.encode(nodeType, forKey: .nodeType)

        case .legacy(attribute: let attribute, wrapped: let wrapped):
            if attribute {
                try container.encode(true, forKey: .attribute)
            }
            if wrapped {
                try container.encode(true, forKey: .wrapped)
            }
        }
    }
}

extension OpenAPI.XML: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name)
        namespace = try container.decodeURLAsStringIfPresent(forKey: .namespace)
        prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
        let attribute = try container.decodeIfPresent(Bool.self, forKey: .attribute) ?? false
        let wrapped = try container.decodeIfPresent(Bool.self, forKey: .wrapped) ?? false
        let nodeType = try container.decodeIfPresent(NodeType.self, forKey: .nodeType)

        switch (attribute, wrapped, nodeType) {
        case (true, _, _):
            fallthrough
        case (_, true, _):
            guard nodeType == nil else {
                throw GenericError(
                    subjectName: "nodeType",
                    details: "`nodeType` cannot be used at the same time as `attribute` or `wrapped`",
                    codingPath: container.codingPath
                )
            }
            self.structure = .legacy(attribute: attribute, wrapped: wrapped)
        case (false, false, nil):
            self.structure = nil
        case (false, false, .some(let node)):
            self.structure = .nodeType(node)
        }

        self.conditionalWarnings = [
            nodeTypeVersionWarning(value: self.structure)
        ].compactMap { $0 }
    }
}

extension OpenAPI.XML: Validatable {}
