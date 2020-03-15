//
//  JSONReference.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import OrderedDictionary

/// Used as a quick check internally in this library to determine if a type is
/// a reference (which only `JSONReference` should be).
internal protocol Reference {}

/// A JSON Reference which represents something like
///
///     $ref: filename.yml#/path/to/something
///
/// The filename is omitted for internal references and the path
/// is not required for external references.
///
/// The intention, as prescribed by the OpenAPI specification, is
/// for this type to conform to the logic in
/// https://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03
public enum JSONReference<ReferenceType: ComponentDictionaryLocatable>: Equatable, Hashable, Reference {
    /// The reference is internal to the file.
    case `internal`(InternalReference)
    /// The reference refers to another file.
    case external(URL)

    /// Reference a component of type `ReferenceType` in the
    /// Components Object.
    ///
    /// Example:
    ///
    ///     JSONReference<JSONSchema>.component(named: "greetings")
    ///     // encoded string: "#/components/schemas/greetings"
    ///     // Swift: `document.components.schemas["greetings"]`
    public static func component(named name: String) -> Self {
        return .internal(.component(name: name))
    }

    /// Reference a path internal to this file but not within the Components Object
    /// This is likely not what you are looking for. It is advisable to store reusable components
    /// in the Components Object.
    ///
    /// - Important: The path does not contain a leading '#'. Start with the root '/'.
    public static func `internal`(path: Path) -> Self {
        return .internal(.path(path))
    }

    /// Get the name of the referenced object. This method returns optional
    /// because a reference to an external file might not have any path if the
    /// file itself is the referenced component.
    public var name: String? {
        switch self {
        case .internal(let reference):
            return reference.name
        case .external(uri: let url):
            return url.fragment?.split(separator: "/").last.map(String.init)
        }
    }

    public var absoluteString: String {
        switch self {
        case .internal(let reference):
            return reference.rawValue
        case .external(let url):
            return url.absoluteString
        }
    }

    public enum InternalReference: LosslessStringConvertible, RawRepresentable, Equatable, Hashable {
        /// The reference refers to a component (i.e. `#/components/...`).
        case component(name: String)
        /// The reference refers to some path outside the Components Object.
        case path(Path)

        /// Get the name of the referenced object. Note that if the
        /// last path component is an integer, its string representation
        /// will be returned. JSON References do not have a way to
        /// determine whether that is the name of a property or an index
        /// within an array without crawling the JSON path to determine if
        /// its parent is an array or an object.
        public var name: String? {
            switch self {
            case .component(name: let name):
                return name
            case .path(let path):
                return path.components.last?.stringValue
            }
        }

        public init?(_ description: String) {
            self.init(rawValue: description)
        }

        /// Create a Reference from a path fragment as defined in the URI spec found here:
        /// https://tools.ietf.org/html/rfc3986
        ///
        /// - Important: The string must begin with the '#' that denotes
        ///     a URI "fragment" is to follow.
        public init?(rawValue: String) {
            guard rawValue.first == "#" else {
                return nil
            }
            let fragment = rawValue.dropFirst()
            guard fragment.starts(with: "/components") else {
                self = .path(Path(rawValue: String(fragment)))
                return
            }
            guard fragment.starts(with: "/components/\(ReferenceType.openAPIComponentsKey)") else {
                return nil
            }
            let pathComponents = fragment.split(separator: "/")
            guard pathComponents.count == 3 else {
                return nil
            }
            let componentName = String(pathComponents[2])
            self = .component(name: componentName)
        }

        public var description: String { rawValue }

        public var rawValue: String {
            switch self {
            case .component(name: let name):
                return "#/components/\(ReferenceType.openAPIComponentsKey)/\(name)"
            case .path(let path):
                return "#\(path.rawValue)"
            }
        }
    }

    /// A JSON Reference path.
    ///
    /// As described by the JSON pointer specification
    /// at https://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04
    ///
    /// and following the URI specification for a "fragment" found here:
    /// https://tools.ietf.org/html/rfc3986
    public struct Path: ExpressibleByArrayLiteral, ExpressibleByStringLiteral, LosslessStringConvertible, RawRepresentable, Equatable, Hashable {

        /// The Path's components. In the `rawValue`, these components are joined
        /// with forward slashes '/' per the JSON Reference specification.
        public var components: [PathComponent]

        public var description: String { rawValue }

        public var rawValue: String {
            return "/" + components
                .map { $0.rawValue }
                .joined(separator: "/")
        }

        public init(arrayLiteral elements: PathComponent...) {
            components = elements
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }

        public init(_ description: String) {
            self.init(rawValue: description)
        }

        public init(rawValue: String) {
            // Takes what `Foundation.URL` calls the "fragment".

            let pathComponents = rawValue
                .split(separator: "/")
                .map(String.init)
                .map(PathComponent.init(stringValue:))

            components = pathComponents
        }
    }

    /// A JSON Reference path component, as described by the JSON pointer specification
    /// at https://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04
    ///
    /// - Important: The special characters `'~'` and `'/'` are handled as `"~0"` and `"~1"`,
    ///     respectively.
    public struct PathComponent: CodingKey, LosslessStringConvertible, RawRepresentable, ExpressibleByStringLiteral, Equatable, Hashable {
        private let decodedStringValue: String

        public var rawValue: String {
            return decodedStringValue
                .replacingOccurrences(of: "~", with: "~0")
                .replacingOccurrences(of: "/", with: "~1")
        }

        /// The string value produces the human-readable path component but
        /// not the proper string encoding of the path component per the
        /// specification. Use the `rawValue` for a proper spec encoding.
        public var stringValue: String { decodedStringValue }

        /// The description produces the human-readable path component but
        /// not the proper string encoding of the path component per the
        /// specification. Use the `rawValue` for a proper spec encoding.
        public var description: String { decodedStringValue }

        public static func property(named name: String) -> Self {
            return .init(stringValue: name)
        }

        public static func index(_ index: Int) -> Self {
            return .init(stringValue: "\(index)")
        }

        public init(stringLiteral value: String) {
            self.init(value)
        }

        public init(_ description: String) {
            self.init(stringValue: description)
        }

        public init(rawValue: String) {
            self.init(stringValue: rawValue)
        }

        public init(stringValue: String) {
            self.decodedStringValue = stringValue
                .replacingOccurrences(of: "~1", with: "/")
                .replacingOccurrences(of: "~0", with: "~")
        }

        public var intValue: Int? {
            guard let index = Int(stringValue) else {
                return nil
            }
            return index
        }

        /// Creates a PathComponent that represents the
        /// index in a JSON Array.
        public init(intValue: Int) {
            self = .index(intValue)
        }
    }
}

// MARK: - Codable

extension JSONReference {
    private enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

extension JSONReference: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .internal(let reference):
            try container.encode(reference.rawValue, forKey: .ref)
        case .external(uri: let url):
            try container.encode(url.absoluteString, forKey: .ref)
        }
    }
}

extension JSONReference: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let referenceString = try container.decode(String.self, forKey: .ref)

        guard referenceString.count > 0 else {
            throw DecodingError.dataCorruptedError(forKey: .ref, in: container, debugDescription: "Expected a reference string, but found an empty string instead.")
        }

        if referenceString.first == "#" {
            guard let internalReference = InternalReference(rawValue: referenceString) else {
                throw InconsistencyError(
                    subjectName: "JSON Reference",
                    details: "Failed to parse a JSON Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .internal(internalReference)
        } else {
            guard let externalReference = URL(string: referenceString) else {
                throw InconsistencyError(
                    subjectName: "JSON Reference",
                    details: "Failed to parse a valid URI for a JSON Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .external(externalReference)
        }
    }
}
