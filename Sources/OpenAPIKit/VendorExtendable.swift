//
//  VendorExtendable.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation
import AnyCodable

protocol ExtendableCodingKey: CodingKey, Equatable {
    /// An array of all keys that are not vendor extensions.
    static var allBuiltinKeys: [Self] { get }

    /// Given a String key, return the vendor extension key representation
    /// of that key.
    ///
    /// For example, an `enum` type might represent `"x-extensionExample"`
    /// as `.extended("x-extensionExample")`
    ///
    static func extendedKey(for value: String) -> Self
}

extension ExtendableCodingKey {
    /// Returns a builtin key if possible, but assumes any other
    /// key is an extended key.
    public static func key(for value: String) -> Self {
        return Self(stringValue: value) ?? .extendedKey(for: value)
    }
}

protocol VendorExtendable {
    associatedtype CodingKeys: ExtendableCodingKey

    typealias VendorExtensions = [String: AnyCodable]

    /// Dictionary of vendor extensions.
    ///
    /// These should be of the form:
    /// `[ "x-extensionKey": <anything>]`
    /// where the values are anything codable.
    var vendorExtensions: VendorExtensions { get }
}

enum VendorExtensionDecodingError: Swift.Error {
    case foundNonStringKeys
}

extension VendorExtendable {

    public static func extensions(from decoder: Decoder) throws -> VendorExtensions {
        guard let decodedAny = (try AnyCodable(from: decoder)).value as? [String: Any] else {
            throw VendorExtensionDecodingError.foundNonStringKeys
        }

        return decodedAny.filter {
            let key = CodingKeys.key(for: $0.key)

            return !CodingKeys.allBuiltinKeys.contains(key)
        }.mapValues(AnyCodable.init)
    }

    public func encodeExtensions<T: KeyedEncodingContainerProtocol>(to container: inout T) throws where T.Key == Self.CodingKeys {
        for (key, value) in vendorExtensions {
            let xKey = key.starts(with: "x-") ? key : "x-\(key)"
            try container.encode(value, forKey: .extendedKey(for: xKey))
        }
    }
}
