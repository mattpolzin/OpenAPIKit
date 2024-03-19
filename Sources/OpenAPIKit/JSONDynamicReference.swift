//
//  JSONDynamicReference.swift
//  
//
//  Created by Mathew Polzin.
//

import OpenAPIKitCore

@dynamicMemberLookup
public struct JSONDynamicReference: Equatable, Hashable {
    public let jsonReference: JSONReference<JSONSchema>

    public init(
        _ reference: JSONReference<JSONSchema>
    ) {
        self.jsonReference = reference
    }

    public subscript<T>(dynamicMember path: KeyPath<JSONReference<JSONSchema>, T>) -> T {
      return jsonReference[keyPath: path]
    }

    /// Reference a component of type `ReferenceType` in the
    /// Components Object.
    ///
    /// Example:
    ///
    ///     JSONDynamicReference.component(named: "greetings")
    ///     // encoded string: "#/components/schemas/greetings"
    ///     // Swift: `document.components.schemas["greetings"]`
    public static func component(named name: String) -> Self {
      return .init(.internal(.component(name: name)), summary: summary, description: description)
    }

    /// Reference a path internal to this file but not within the Components Object
    /// This is likely not what you are looking for. It is advisable to store reusable components
    /// in the Components Object.
    ///
    /// - Important: The path does not contain a leading '#'. Start with the root '/'.
    public static func `internal`(path: JSONReference<JSONSchema>.Path, summary: String? = nil, description: String? = nil) -> Self {
      return .init(.internal(.path(path)), summary: summary, description: description)
    }

    /// Reference an external URL.
    public static func external(_ url: URL) -> Self {
      return .init(.external(url))
    }

    /// `true` for internal references, `false` for
    /// external references (i.e. to another file).
    public var isInternal: Bool {
      return jsonReference.isInternal
    }

    /// `true` for external references, `false` for
    /// internal references.
    public var isExternal: Bool {
      return jsonReference.isExternal
    }

    /// Get the name of the referenced object. This method returns optional
    /// because a reference to an external file might not have any path if the
    /// file itself is the referenced component.
    public var name: String? {
      return jsonReference.name
    }

    /// The absolute value of an external reference's
    /// URL or the path fragment string for a local
    /// reference as defined in [RFC 3986](https://tools.ietf.org/html/rfc3986).
    public var absoluteString: String {
      return jsonReference.absoluteString
    }
}

extension JSONDynamicReference {
    private enum CodingKeys: String, CodingKey {
        case dynamicRef = "$dynamicRef"
    }
}

extension JSONDynamicReference: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self.jsonReference {
        case .internal(let reference):
            try container.encode(reference.rawValue, forKey: .dynamicRef)
        case .external(uri: let url):
            try container.encode(url.absoluteString, forKey: .dynamicRef)
        }
    }
}

extension JSONDynamicReference: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let referenceString = try container.decode(String.self, forKey: .dynamicRef)

        guard referenceString.count > 0 else {
            throw DecodingError.dataCorruptedError(forKey: .dynamicRef, in: container, debugDescription: "Expected a reference string, but found an empty string instead.")
        }

        if referenceString.first == "#" {
            guard let internalReference = InternalReference(rawValue: referenceString) else {
                throw InconsistencyError(
                    subjectName: "JSON Dynamic Reference",
                    details: "Failed to parse a JSON Dynamic Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .internal(internalReference)
        } else {
            guard let externalReference = URL(string: referenceString) else {
                throw InconsistencyError(
                    subjectName: "JSON Dynamic Reference",
                    details: "Failed to parse a valid URI for a JSON Dynamic Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .external(externalReference)
        }
    }
}
