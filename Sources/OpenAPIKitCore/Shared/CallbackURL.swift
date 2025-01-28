//
//  CallbackURL.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

import Foundation

extension Shared {
    /// A URL template where the placeholders are OpenAPI **Runtime Expressions** instead
    /// of named variables.
    ///
    /// See [OpenAPI Callback Object](https://spec.openapis.org/oas/v3.0.4.html#callback-object) and [OpenAPI Runtime Expression](https://spec.openapis.org/oas/v3.0.4.html#runtime-expressions) for more.
    ///
    public struct CallbackURL: Hashable, RawRepresentable, Sendable {
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
}

extension Shared.CallbackURL: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension Shared.CallbackURL: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        template = try container.decode(URLTemplate.self)
    }
}
