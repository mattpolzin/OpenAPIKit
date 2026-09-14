import OpenAPIKitCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A `JSONDynamicReference` represents a JSON Schema `$dynamicRef`
/// (JSON Schema 2020-12, [§7.7](https://json-schema.org/draft/2020-12/json-schema-core#section-7.7)).
///
/// Like `JSONReference`, a dynamic reference can point either to a component
/// in the Components Object, to another location within the same document
/// (including a `$dynamicAnchor`), or to another file.
///
/// OpenAPIKit parses and round-trips `$dynamicRef`. Dynamic-scope *evaluation*
/// is a runtime concern belonging to JSON Schema validators; local
/// dereferencing (`locallyDereferenced()`) does not resolve `$dynamicRef` and
/// fails if it encounters one that cannot be inlined.
@dynamicMemberLookup
public struct JSONDynamicReference: Equatable, Hashable, Sendable {
    public let jsonReference: JSONReference<JSONSchema>

    public init(_ reference: JSONReference<JSONSchema>) {
        self.jsonReference = reference
    }

    public subscript<T>(dynamicMember path: KeyPath<JSONReference<JSONSchema>, T>) -> T {
        return jsonReference[keyPath: path]
    }

    /// Reference a `$dynamicAnchor` (or `$anchor`) local to this document.
    ///
    /// - Important: `anchor` does not contain a leading '#'.
    public static func anchor(_ anchor: String) -> Self {
        return .init(.internal(.anchor(anchor)))
    }
}

// MARK: - Codable

extension JSONDynamicReference {
    private enum CodingKeys: String, CodingKey {
        case dynamicRef = "$dynamicRef"
    }
}

extension JSONDynamicReference: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch jsonReference {
        case .internal(let reference):
            try container.encode(reference.rawValue, forKey: .dynamicRef)
        case .external(let url):
            try container.encode(url.absoluteString, forKey: .dynamicRef)
        }
    }
}

extension JSONDynamicReference: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let referenceString = try container.decode(String.self, forKey: .dynamicRef)

        guard !referenceString.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .dynamicRef, in: container, debugDescription: "Expected a reference string, but found an empty string instead.")
        }

        if referenceString.first == "#" {
            guard let internalReference = JSONReference<JSONSchema>.InternalReference(rawValue: referenceString) else {
                throw GenericError(
                    subjectName: "JSON Dynamic Reference",
                    details: "Failed to parse a JSON Dynamic Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .init(.internal(internalReference))
        } else {
            let externalReference: URL?
            #if canImport(FoundationEssentials)
            externalReference = URL(string: referenceString, encodingInvalidCharacters: false)
            #elseif os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
                externalReference = URL(string: referenceString, encodingInvalidCharacters: false)
            } else {
                externalReference = URL(string: referenceString)
            }
            #else
            externalReference = URL(string: referenceString)
            #endif
            guard let externalReference else {
                throw GenericError(
                    subjectName: "JSON Dynamic Reference",
                    details: "Failed to parse a valid URI for a JSON Dynamic Reference from '\(referenceString)'",
                    codingPath: container.codingPath
                )
            }
            self = .init(.external(externalReference))
        }
    }
}

// Conforms for parity with JSONReference; lets downstream code key
// Validations on dynamic references (a `Validation`'s `Subject` must be `Validatable`).
extension JSONDynamicReference: Validatable {}
