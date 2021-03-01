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
/// A `URLTemplate` that does not contain any variables can be turned into
/// a Foundation `URL` (assuming it is an otherwise valid URL) which you can
/// access with the `url` property.
///
/// A `URLTemplate` that contains variables can be turned into a template
/// with no variables (and subsequently a Foundation `URL`) with the
/// `replacing(_:)` function that takes a dictionary of variable values to insert
/// into the template. You can also choose to only replace some of the variables this
/// way.
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

    /// Get the names of all variables in the URL Template.
    public var variables: [String] {
        return components.compactMap { $0.variableName }
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
    /// URL Template components are either variables that can take on
    /// different values depending on the context or they are constant
    /// unchanging parts of the URL.
    public enum Component: Hashable, RawRepresentable {
        case variable(name: String)
        case constant(String)

        /// Get a component's raw value.
        ///
        /// A constant's raw value is just the constant part of the URL.
        ///
        /// A variable's raw value is the name of the variable enclosed in
        /// curly braces.
        public var rawValue: String {
            switch self {
            case .variable(name: let name):
                return "{\(name)}"
            case .constant(let value):
                return value
            }
        }

        /// Always `nil` for constants, but for variables, this will
        /// return the variable name without the surrounding curly
        /// braces that are just OpenAPI syntax. By contrast, the
        /// `rawValue` of a variable _will_ contain the curly braces.
        public var variableName: String? {
            guard case .variable(name: let name) = self else { return nil }
            return name
        }

        /// Create a component from its raw value.
        ///
        /// A constant's raw value is just the constant part of the URL.
        ///
        /// A variable's raw value is the name of the variable enclosed in
        /// curly braces.
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

extension URLTemplate {
    /// Construct a URL template from the given components. Neighboring `.constant`
    /// components in the array will be combined.
    public init(reducingComponents components: [Component]) {
        let finalComponents = components.reduce([]) { (reducedComponents, component) -> [Component] in
            if case let .constant(newConstant) = component,
               case let .constant(existingConstant) = reducedComponents.last {
                return reducedComponents.dropLast() + [.constant(existingConstant + newConstant)]
            }
            return reducedComponents + [component]
        }
        self.components = finalComponents
        rawValue = finalComponents.map { $0.rawValue }.joined()
    }

    /// For all variables in this template that have keys in the given dictionary,
    /// replace the variable with the value under the given key.
    ///
    /// This results in a new `URLTemplate` with a constant value in place of all
    /// variables that were replaced. The `URLTemplate` gets reformed, so any
    /// constants formed by such a replacement that neighbor other constants
    /// become one constant (there will never be two constants next to each other,
    /// even after variable replacement occurs).
    ///
    /// If you have replaced all variables in the template, you can attempt to create a
    /// well-formed Foundation `URL` by accessing the `url` property of the resulting
    /// `URLTemplate`.
    ///
    /// **Example**
    ///
    ///     "{scheme}://{website}.com/{path}"
    ///     [
    ///         .variable(name: "scheme"),
    ///         .constant("://"),
    ///         .variable(name: "website"),
    ///         .constant(".com/")
    ///         .variable(name: "path")
    ///     ]
    ///
    ///     -> replacing(["scheme": "https", "path": "welcome"])
    ///
    ///     "https://{website}.com/welcome"
    ///     [
    ///         .constant("https://"),
    ///         .variable(name: "website"),
    ///         .constant(".com/welcome")
    ///     ]
    ///
    /// If you want to create a valid `URL` from the template, all variables must be
    /// replaced. Picking up with the above example, we could replace the last variable
    /// and then request the `URLTemplate` `url` property.
    ///
    /// **Example**
    ///
    ///         -> replacing(["website": "mysite"])
    ///
    ///         "https://mysite.com/welcome"
    ///         [
    ///             .constant("https://mysite.com/welcome")
    ///         ]
    ///
    public func replacing(_ variableDictionary: [String : String]) -> URLTemplate {
        let newComponents = components.map { component -> Component in
            guard case .variable(name: let name) = component,
                  let replacement = variableDictionary[name] else {
                return component
            }
            return .constant(replacement)
        }

        return URLTemplate(reducingComponents: newComponents)
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
