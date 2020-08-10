//
//  ServerURL.swift
//  
//
//  Created by Mathew Polzin on 8/9/20.
//

import Foundation

extension OpenAPI {
    public struct ServerURL: Hashable {
        /// The scheme for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask
        /// for `schemaString`.
        ///
        /// URLs can be relative and will not have a scheme
        /// in that case.
        ///
        /// This array contains both constant and variable
        /// components; the concatenation of all components
        /// produces the host.
        public var scheme: [Component]

        /// The `String` value of the scheme.
        public var schemeString: String? {
            guard scheme.count > 0 else { return nil }
            return scheme.map { $0.rawValue }.joined()
        }

        /// The username for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask
        /// for `usernameString`.
        ///
        /// This array contains both constant and variable
        /// components; the concatenation of all components
        /// produces the username.
        public var username: [Component]

        /// The `String` value of the username, if one is specified.
        public var usernameString: String? {
            guard username.count > 0 else { return nil }
            return username.map { $0.rawValue }.joined()
        }

        /// The password for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask
        /// for `passwordString`.
        ///
        /// This array contains both constant and variable
        /// components; the concatenation of all components
        /// produces the password.
        public var password: [Component]

        /// The `String` value of the password, if one is specified.
        public var passwordString: String? {
            guard password.count > 0 else { return nil }
            return password.map { $0.rawValue }.joined()
        }

        /// The host for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask
        /// for `hostString`.
        ///
        /// URLs can be relative and will not have a host in
        /// that case.
        ///
        /// This array contains separator, constant, and variable
        /// components; the concatenation of all components
        /// produces the host.
        public var host: [SegmentedComponent<HostSeparator>]

        /// The `String` value of the host, if one is specified.
        public var hostString: String? {
            guard host.count > 0 else { return nil }
            return host.map { $0.rawValue }.joined()
        }

        /// The port for the URL, if one is specified.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask for
        /// its `rawValue`. If you want to get its
        /// integer value, ask for `portInteger`.
        public var port: Component?

        /// The port for the URL, if one is specified and
        /// it is a constant value.
        public var portInteger: Int? {
            switch port {
            case nil, .variable:
                return nil
            case .constant(let value):
                return Int(value)
            }
        }

        /// The path for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask for
        /// `pathString`.
        ///
        /// This array contains separator, constant, and variable
        /// components; the concatenation of all components
        /// produces the path.
        public var path: [SegmentedComponent<PathSeparator>]

        /// The path for the URL, if one is specified.
        public var pathString: String? {
            guard path.count > 0 else { return nil }
            return path.map { $0.rawValue }.joined()
        }

        /// The query for the URL.
        ///
        /// This property supports templating. If you
        /// want to get its `String` value, ask for
        /// `queryString`.
        ///
        /// This array contains separator, constant, and variable
        /// components; the concatenation of all components
        /// produces the query.
        public var query: [SegmentedComponent<QuerySeparator>]

        /// The `String` value for the query, if one is specified.
        public var queryString: String? {
            guard query.count > 0 else { return nil }
            return query.map { $0.rawValue }.joined()
        }

        /// The `String` value representing the entire
        /// templated URL.
        public var stringValue: String {
            let scheme = schemeString.map { $0 + "://" }

            let credentials = [usernameString, passwordString].compactMap { $0 }.joined(separator: ":")

            let credentialsAndHost: String
            if !credentials.isEmpty {
                credentialsAndHost = credentials + "@" + (hostString ?? "")
            } else {
                credentialsAndHost = hostString ?? ""
            }

            let port = self.port.map { ":" + $0.rawValue }

            let path = pathString.map { "/" + $0 }

            let query = queryString.map { "?" + $0 }

            let fullUrl = [
                scheme,
                credentialsAndHost,
                port,
                path,
                query
            ].compactMap { $0 }.joined()

            if fullUrl == path {
                // if the path is the full URL, we are looking at
                // a server URL that is entirely a variable. Omit
                // the leading slash in this case to not assume the
                // variable doesn't contain the whole URL instead
                // of just the path.
                return pathString ?? ""
            }

            return fullUrl
        }

        /// Get the Foundation `URL` representation
        /// of this `ServerURL` if possible. The reason
        /// it is not always possible to represent `ServerURLs`
        /// as Foundation `URLs` is that Foundation `URLs`
        /// do not support templating (variable placeholders).
        public var foundationUrl: URL? {
            return URL(string: stringValue)
        }
    }
}

public protocol ComponentSeparator: RawRepresentable where RawValue == String {}



extension OpenAPI.ServerURL {
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

    public enum SegmentedComponent<Separator: ComponentSeparator>: Hashable, RawRepresentable {
        case variable(name: String)
        case constant(String)
        case separator(Separator)

        public var rawValue: String {
            switch self {
            case .variable(name: let name):
                return "{\(name)}"
            case .constant(let value):
                return value
            case .separator(let separator):
                return separator.rawValue
            }
        }

        public init?(rawValue: String) {
            if let separator = Separator(rawValue: rawValue) {
                self = .separator(separator)
                return
            }

            let first = rawValue.first
            let last = rawValue.last
            guard first == "{" && last == "}" else {
                self = .constant(rawValue)
                return
            }
            self = .variable(name: String(rawValue.dropFirst().dropLast()))
        }
    }

    public enum HostSeparator: String, ComponentSeparator {
        case period = "."
    }

    public enum PathSeparator: String, ComponentSeparator {
        case slash = "/"
    }

    public enum QuerySeparator: String, ComponentSeparator {
        case slash = "&"
    }
}

//extension OpenAPI.ServerURL.Scheme: Encodable {
//
//}
//
//extension OpenAPI.ServerURL.Scheme: Decodable {
//
//}
//
//extension OpenAPI.ServerURL: Encodable {
//
//}
//
//extension OpenAPI.ServerURL: Decodable {
//
//}

extension OpenAPI.ServerURL {

    internal static func scan(
        _ string: String,
        partialToken: PartialToken?,
        from remainder: Substring,
        addingTo tokens: [Token]
    ) throws -> [Token] {
        guard let next = remainder.first else {
            guard partialToken == nil || partialToken?.type == .constant else {
                throw ParsingError.unterminatedVariable(name: String(partialToken?.string ?? ""))
            }
            return tokens + tokenArray(from: partialToken)
        }
        let nextFirstIndex = remainder.index(remainder.startIndex, offsetBy: 1, limitedBy: remainder.endIndex)

        switch (partialToken?.type, next) {
        case (nil, "{"),
             (.constant, "{"):
            guard let newFirstIndex = nextFirstIndex else {
                throw ParsingError.unterminatedVariable(name: "")
            }
            return try scan(string, partialToken: .init(type: .variable, string: remainder[newFirstIndex...newFirstIndex]), from: remainder.dropFirst(), addingTo: tokens)

        case (.variable, "}"):
            let newTokens = tokens + tokenArray(from: partialToken)
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, "}"),
             (.constant, "}"):
            throw ParsingError.variableEndedWithoutStarting(name: partialToken.map { String($0.string) } ?? "")

        case (.variable, "{"):
            throw ParsingError.variableStartedWithinVariable(name: partialToken.map { String($0.string) } ?? "")

        case (nil, Token.Separator.colon.rawValue.first),
             (.constant, Token.Separator.colon.rawValue.first):
            if let nextFirstIndex = nextFirstIndex, remainder[nextFirstIndex] == "/" {
                let lookaheadTwoIndex = remainder.index(after: nextFirstIndex)
                guard lookaheadTwoIndex < remainder.endIndex, remainder[lookaheadTwoIndex] == "/" else {
                    throw ParsingError.failedToParseSeparator(expectedSeparator: Token.Separator.scheme.rawValue)
                }
                let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.scheme)]
                return try scan(string, partialToken: nil, from: remainder[remainder.index(after: lookaheadTwoIndex)...], addingTo: newTokens)
            }
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.colon)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, Token.Separator.at.rawValue.first),
             (.constant, Token.Separator.at.rawValue.first):
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.at)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, Token.Separator.slash.rawValue.first),
             (.constant, Token.Separator.slash.rawValue.first):
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.slash)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, Token.Separator.period.rawValue.first),
             (.constant, Token.Separator.period.rawValue.first):
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.period)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, Token.Separator.question.rawValue.first),
             (.constant, Token.Separator.question.rawValue.first):
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.question)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (nil, Token.Separator.ampersand.rawValue.first),
             (.constant, Token.Separator.ampersand.rawValue.first):
            let newTokens = tokens + tokenArray(from: partialToken) + [.separator(.ampersand)]
            return try scan(string, partialToken: nil, from: remainder.dropFirst(), addingTo: newTokens)

        case (.variable, Token.Separator.colon.rawValue.first),
             (.variable, Token.Separator.at.rawValue.first),
             (.variable, Token.Separator.slash.rawValue.first),
             (.variable, Token.Separator.period.rawValue.first),
             (.variable, Token.Separator.question.rawValue.first),
             (.variable, Token.Separator.ampersand.rawValue.first):
            throw ParsingError.unterminatedVariable(name: String(partialToken?.string ?? ""))

        case (nil, _):
            return try scan(string, partialToken: .init(type: .constant, string: remainder[remainder.startIndex...remainder.startIndex]), from: remainder.dropFirst(), addingTo: tokens)

        case (.constant, _),
             (.variable, _):
            guard nextFirstIndex != nil, let reifiedPartialToken = partialToken else {
                return tokens + tokenArray(from: partialToken)
            }
            return try scan(string, partialToken: reifiedPartialToken.advancingStringByOne(within: string), from: remainder.dropFirst(), addingTo: tokens)
        }
    }

    internal static func tokenArray(from partial: PartialToken?) -> [Token] {
        partial.flatMap { $0.token }.map { [$0] } ?? []
    }

    internal enum TokenType {
        case constant
        case variable
    }

    internal struct PartialToken {
        let type: TokenType
        let string: Substring

        func advancingStringByOne(within string: String) -> PartialToken {
            return .init(type: type, string: string[self.string.startIndex...self.string.endIndex])
        }

        var token: Token? {
            guard !string.isEmpty else { return nil }
            switch type {
            case .constant:
                return .constant(String(string))
            case .variable:
                return .variable(name: String(string))
            }
        }
    }

    internal enum Token: Equatable {
        case constant(String)
        case variable(name: String)
        case separator(Separator)

        enum Separator: String, Equatable {
            case scheme = "://"
            case colon = ":"
            case at = "@"
            case slash = "/"
            case period = "."
            case question = "?"
            case ampersand = "&"
        }
    }

//    internal struct Parser {
//        let urlString: String
//        var serverUrl: OpenAPI.ServerURL
//
//        static func parseNextSeparator
//
//        static func parseNextToken(
//            latestContext: Context?,
//            tokenType: TokenType?,
//            partialToken: Substring,
//            from remainder: Substring,
//            into url: OpenAPI.ServerURL
//        ) throws -> OpenAPI.ServerURL {
//            guard let next = remainder.first else {
//                guard tokenType == .constant || tokenType == nil else {
//                    throw ParsingError.unterminatedVariable(name: String(partialToken))
//                }
//                return url
//            }
//            var partialToken = partialToken
//            var remainder = remainder.dropFirst()
//            var url = url
//
//            // switch contexts if needed
//            let nextContext: Context?
//            switch (latestContext, next) {
//            case (nil, ":"):
//                guard tokenType != .variable else {
//                    throw ParsingError.unterminatedVariable(name: String(partialToken))
//                }
//                if remainder.first == "/" {
//                    remainder = remainder.dropFirst()
//                    guard remainder.first == "/" else {
//                        throw ParsingError.failedToParseSeparator(after: nil, expectedSeparator: "://", found: String(describing: remainder.first))
//                    }
//                    url.scheme.append(.constant(String(partialToken)))
//                }
//                nextContext
//            }
//
//            // store a new token if needed
//            let nextTokenType: TokenType?
//            switch (next, tokenType) {
//            case ("{", nil),
//                 ("{", .constant):
//                nextTokenType = .variable
//            case ("{", .variable):
//                throw ParsingError.variableStartedWithinVariable(name: String(partialToken))
//            case ("}", .variable):
//                nextTokenType = nil
//            case ("}", nil),
//                 ("}", .constant):
//                throw ParsingError.variableEndedWithoutStarting(name: String(partialToken))
//            case (_, nil):
//                nextTokenType = .constant
//                partialToken = partialToken[partialToken.startIndex...partialToken.index(after: partialToken.endIndex)]
//            case (_, .constant),
//                 (_, .variable):
//                nextTokenType = tokenType
//                partialToken = partialToken[partialToken.startIndex...partialToken.index(after: partialToken.endIndex)]
//            }
//
//            // TODO: split host, path, and query constants based on separators
//        }

        /// `Context`'s raw values in the parsing context are
        /// the `Strings` that indicate a transition out of
//        internal enum Context: CaseIterable {
//            case scheme
//            case username
//            case password
//            case host
//            case port
//            case path
//            case query

//            var startingSequence: String? {
//                switch self {
//                case .scheme:
//                    return nil
//                case .username:
//                    return "://"
//                case .password:
//                    return ":"
//                case .host:
//                    return "@"
//                case .port:
//                    return ":"
//                case .path:
//                    return "/"
//                case .query:
//                    return "?"
//                }
//            }
//
//            var endingSequence: String? {
//                switch self {
//                case .scheme:
//                    return "://"
//                case .username:
//                    return ":"
//                case .password:
//                    return "A"
//                case .host:
//                    return ":"
//                case .port:
//                    return "/"
//                case .path:
//                    return "?"
//                case .query:
//                    return nil
//                }
//            }
//        }

//        internal enum TokenType {
//            case variable
//            case constant
//        }
//    }

    internal enum ParsingError: Swift.Error {
        case unterminatedVariable(name: String)
        case variableStartedWithinVariable(name: String)
        case variableEndedWithoutStarting(name: String)
        case failedToParseSeparator(expectedSeparator: String)
    }
}

extension OpenAPI.ServerURL: Validatable {}
