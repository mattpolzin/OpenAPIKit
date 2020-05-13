//
//  Request.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Request Body Object"
    ///
    /// See [OpenAPI Request Body Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#request-body-object).
    public struct Request: Equatable {
        public let description: String?
        public let content: Content.Map
        public let required: Bool

        public init(description: String? = nil,
                    content: Content.Map,
                    required: Bool = false) {
            self.description = description
            self.content = content
            self.required = required
        }
    }
}

// MARK: - Codable

extension OpenAPI.Request {
    private enum CodingKeys: String, CodingKey {
        case description
        case content
        case required
    }
}

extension OpenAPI.Request: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(content, forKey: .content)

        if required {
            try container.encode(required, forKey: .required)
        }
    }
}

extension OpenAPI.Request: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            description = try container.decodeIfPresent(String.self, forKey: .description)
            content = try container.decode(OpenAPI.Content.Map.self, forKey: .content)
            required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        } catch let error as InconsistencyError {

            throw OpenAPI.Error.Decoding.Request(error)
        } catch let error as Swift.DecodingError {

            throw OpenAPI.Error.Decoding.Request(error)
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Request(error)
        }
    }
}
