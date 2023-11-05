//
//  Path.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//

extension Shared {
        /// OpenAPI Spec "Paths Object" path field pattern support.
        ///
        /// See [OpenAPI Paths Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#paths-object)
        /// and [OpenAPI Patterned Fields](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#patterned-fields).
    public struct Path: RawRepresentable, Equatable, Hashable {
        public let components: [String]
        public let trailingSlash: Bool

        public init(_ components: [String], trailingSlash: Bool = false) {
            self.components = components
            self.trailingSlash = trailingSlash
        }

        public init(rawValue: String) {
            let pathComponents = rawValue.split(separator: "/").map(String.init)
            components = pathComponents.count > 0 && pathComponents[0].isEmpty
                ? Array(pathComponents.dropFirst())
                : pathComponents
            trailingSlash = rawValue.hasSuffix("/")
        }

        public var rawValue: String {
            let path =
                "/\(components.joined(separator: "/"))"

            let suffix = trailingSlash ? "/" : ""

            return path + suffix
        }
    }
}

extension Shared.Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
