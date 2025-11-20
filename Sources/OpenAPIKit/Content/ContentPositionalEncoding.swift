//
//  ContentPositionalEncoding.swift
//
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore

extension OpenAPI.Content {
    /// OpenAPI Spec `itemEncoding` and `prefixEncoding` on the "Media Type Object"
    ///
    /// See [OpenAPI Media Type Object](https://spec.openapis.org/oas/v3.2.0.html#media-type-object).
    public struct PositionalEncoding: Equatable, Sendable {

        /// An array of positional encoding information, as defined under
        /// [Encoding By Position](https://spec.openapis.org/oas/v3.2.0.html#encoding-by-position).
        /// The `prefixEncoding` field **SHALL** only apply when the media type is
        /// `multipart`. If no Encoding Object is provided for a property, the
        /// behavior is determined by the default values documented for the
        /// Encoding Object.
        public var prefixEncoding: [OpenAPI.Content.Encoding]

        /// A single Encoding Object that provides encoding information for
        /// multiple array items, as defined under [Encoding By Position](https://spec.openapis.org/oas/v3.2.0.html#encoding-by-position).
        /// The `itemEncoding` field **SHALL** only apply when the media type
        /// is multipart. If no Encoding Object is provided for a property, the
        /// behavior is determined by the default values documented for the
        /// Encoding Object.
        public var itemEncoding: OpenAPI.Content.Encoding?

        public init(
            prefixEncoding: [OpenAPI.Content.Encoding] = [],
            itemEncoding: OpenAPI.Content.Encoding? = nil
        ) {
            self.prefixEncoding = prefixEncoding
            self.itemEncoding = itemEncoding
        }
    }
}

