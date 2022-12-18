//
//  Path.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//

/// OpenAPI Spec "Paths Object" path field pattern support.
///
/// See [OpenAPI Paths Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#paths-object)
/// and [OpenAPI Patterned Fields](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#patterned-fields).
public struct Path: RawRepresentable, Equatable, Hashable {
    public let components: [String]

    public init(_ components: [String]) {
        self.components = components
    }

    public init(rawValue: String) {
        let pathComponents = rawValue.split(separator: "/").map(String.init)
        components = pathComponents.count > 0 && pathComponents[0].isEmpty
        ? Array(pathComponents.dropFirst())
        : pathComponents
    }

    public var rawValue: String {
        return "/\(components.joined(separator: "/"))"
    }
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
