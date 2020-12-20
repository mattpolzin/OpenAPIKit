//
//  URLTemplate.swift
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
public struct URLTemplate: Hashable, RawRepresentable {

    /// The string value of the URL.
    ///
    /// This is equivalent to the `absoluteString`
    /// (i.e. the entire URL).
    public let rawValue: String

    /// The variable and constant components of teh URL.
    ///
    /// Variables are enclosed in curly braces (`{variable}`)
    /// and everything between variables is "constant."
    ///
    /// In the URL `{scheme}://website.com/{path}`
    /// there are two variables (`scheme` and `path`) separated
    /// by the "://website.com/" portion which is a constant.
    public let components: [Component]

    /// The entire URL as a string.
    ///
    /// This is equivalent to the `absoluteString` provided
    /// by the Foundation `URL` type except that a
    /// `URLTemplate`'s `absoluteString` can contain
    /// variable placeholders.
    public var absoluteString: String {
        rawValue
    }

    /// Get a URL from this templated URL if it is a valid URL already.
    ///
    /// Templated URLs with variables in them will not be valid URLs
    /// and are therefore guaranteed to return `nil`.
    public var url: URL? {
        return URL(string: rawValue)
    }

    /// Create a URLTemplate from the string if possible.
    ///
    /// A non-throwing version of `init(templateString:)`.
    public init?(rawValue: String) {
        do {
            try self.init(templateString: rawValue)
        } catch {
            return nil
        }
    }

    /// Create a URLTemplate from the string if possible.
    ///
    /// A throwing version of `init?(rawValue:)`.
    public init(templateString: String) throws {
        rawValue = templateString
        components = try URLTemplate.scan(
            templateString,
            partialToken: nil,
            from: templateString[...],
            addingTo: []
        )
    }

    /// Create a constant (no variables) URLTemplate from the given URL.
    public init(url: URL) {
        rawValue = url.absoluteString
        components = [.constant(rawValue)]
    }
}

extension URLTemplate {
    public enum Component: Hashable, RawRepresentable {
        case variable(name: String)
        case constant(String)

        public var rawValue: String {
            switch self {
            case .variable(name: let name):
                return "{\(name)}"
            case .constant(let value):
                return value
            }
        }

        public init?(rawValue: String) {
            let first = rawValue.first
            let last = rawValue.last
            guard first == "{" && last == "}" else {
                self = .constant(rawValue)
                return
            }
            self = .variable(name: String(rawValue.dropFirst().dropLast()))
        }
    }
}

extension URLTemplate: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension URLTemplate: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let rawValue = try container.decode(String.self)

        let template = try URLTemplate(templateString: rawValue)

        self = template
    }
}

extension URLTemplate: Validatable {}
