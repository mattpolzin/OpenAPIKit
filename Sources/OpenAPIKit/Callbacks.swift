//
//  Callback.swift
//  
//
//  Created by Mathew Polzin on 11/1/20.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {

    /// A URL template where the placeholders are OpenAPI **Runtime Expressions** instead
    /// of named variables.
    ///
    /// See [OpenAPI Callback Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#callback-object) and [OpenAPI Runtime Expression](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#runtime-expressions) for more.
    ///
    public struct CallbackURL: Hashable, RawRepresentable {
        public let template: URLTemplate

        /// The string value of the URL without variable replacement.
        ///
        /// Variables cannot be replaced based on other information in the
        /// OpenAPI document; they are only available at "runtime" which is
        /// where the name of the OpenAPI structure `CallbackURL`
        /// represents comes from.
        public var rawValue: String {
            template.rawValue
        }

        /// Get a URL from the runtime expression if it is a valid URL without
        /// variable replacement.
        ///
        /// Callback URLs with variables in them will not be valid URLs
        /// and are therefore guaranteed to return `nil`.
        public var url: URL? {
            template.url
        }

        /// Create a CallbackURL from the string if possible.
        public init?(rawValue: String) {
            guard let template = URLTemplate(rawValue: rawValue) else {
                return nil
            }
            self.template = template
        }

        public init(url: URL) {
            template = .init(url: url)
        }
    }

    /// A map from runtime expressions to path items to be used as
    /// callbacks for the API. The OpenAPI Spec "Callback Object."
    ///
    /// See [OpenAPI Callback Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#callback-object).
    ///
    public typealias Callbacks = OrderedDictionary<CallbackURL, Either<JSONReference<PathItem>, PathItem>>

    /// A map of named collections of Callback Objects (`OpenAPI.Callbacks`).
    public typealias CallbacksMap = OrderedDictionary<String, Either<JSONReference<Callbacks>, Callbacks>>
}

extension OpenAPI.CallbackURL: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension OpenAPI.CallbackURL: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        template = try container.decode(URLTemplate.self)
    }
}
