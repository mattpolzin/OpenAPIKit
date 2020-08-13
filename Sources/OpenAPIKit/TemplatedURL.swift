//
//  TemplatedURL.swift
//  
//
//  Created by Mathew Polzin on 8/13/20.
//

import Foundation

/// A URL that may contain variable placeholders.
///
/// Variable placeholders are enclosed with curly
/// braces. They can exist anywhere within the URL.
///
/// **Examples:**
///
///     // no variables
///     "https://website.com/a/path?query=value"
///
///     // scheme
///     "{scheme}://website.com/a/path?query=value"
///
///     // host
///     "https://{host}/a/path?query=value"
///
///     // just the domain
///     "https://{domain}.com/a/path?query=value"
///
///     // the whole url
///     "{server}"
///
///     // etc.
///
public struct TemplatedURL: Hashable, RawRepresentable {

    /// The string value of the URL.
    ///
    /// This is equivalent to the `absoluteString`
    /// (i.e. the entire URL).
    public let rawValue: String

    /// The entire URL as a string.
    ///
    /// This is equivalent to the `absoluteString` provided
    /// by the Foundation `URL` type except that a
    /// `TemplatedURL`'s `absoluteString` can contain
    /// variable placeholders.
    public var absoluteString: String {
        rawValue
    }

    /// Get a URL from this templated URL if it is a valid URL already.
    ///
    /// Templated URLS with variables in them will not be valid URLs
    /// and are therefore guaranteed to return `nil`.
    public var url: URL? {
        return URL(string: rawValue)
    }

    /// Create a TemplatedURL from the string if possible.
    public init?(rawValue: String) {
        // currently this is guaranteed to succeed but
        // in the future it will fail if variable placeholders
        // cannot be successfully parsed (i.e. curly braces
        // are mismatched, dangling, nested, etc.).
        self.rawValue = rawValue
    }

    public init(url: URL) {
        rawValue = url.absoluteString
    }
}

extension TemplatedURL: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension TemplatedURL: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        rawValue = try container.decode(String.self)

        // in the future the plan is to tokenize upon
        // decoding (and other initialization above) and offer
        // easy variable replacement.
    }
}

extension TemplatedURL: Validatable {}
