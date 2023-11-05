//
//  Discriminator.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

extension Shared {
    /// OpenAPI Spec "Disciminator Object"
    ///
    /// See [OpenAPI Discriminator Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#discriminator-object).
    public struct Discriminator: Equatable {
        public let propertyName: String
        public let mapping: OrderedDictionary<String, String>?

        public init(propertyName: String,
                    mapping: OrderedDictionary<String, String>? = nil) {
            self.propertyName = propertyName
            self.mapping = mapping
        }
    }
}

// MARK: - Codable

extension Shared.Discriminator: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(propertyName, forKey: .propertyName)
        try container.encodeIfPresent(mapping, forKey: .mapping)
    }
}

extension Shared.Discriminator: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        propertyName = try container.decode(String.self, forKey: .propertyName)
        mapping = try container.decodeIfPresent(OrderedDictionary<String, String>.self, forKey: .mapping)
    }
}

extension Shared.Discriminator {
    private enum CodingKeys: String, CodingKey {
        case propertyName
        case mapping
    }
}

extension Shared.Discriminator: Validatable {}
