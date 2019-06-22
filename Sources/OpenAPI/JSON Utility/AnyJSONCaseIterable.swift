//
//  AnyJSONCaseIterable.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import AnyCodable

/// Anything conforming to `AnyJSONCaseIterable` can provide a
/// list of its possible values.
public protocol AnyJSONCaseIterable {
    static func allCases(using encoder: JSONEncoder) -> [AnyCodable]
}

extension AnyJSONCaseIterable {
    /// Given an array of Codable values, retrieve an array of AnyCodables.
    static func allCases<T: Codable>(from input: [T], using encoder: JSONEncoder) throws -> [AnyCodable] {
        if let alreadyGoodToGo = input as? [AnyCodable] {
            return alreadyGoodToGo
        }

        // The following is messy, but it does get us the intended result:
        // Given any array of things that can be encoded, we want
        // to map to an array of AnyCodable so we can store later. We need to
        // muck with JSONSerialization because something like an `enum` may
        // very well be encoded as a string, and therefore representable
        // by AnyCodable, but AnyCodable wants it to actually BE a String
        // upon initialization.

        guard let arrayOfCodables = try JSONSerialization.jsonObject(with: encoder.encode(input), options: []) as? [Any] else {
            throw OpenAPICodableError.allCasesArrayNotCodable
        }
        return arrayOfCodables.map(AnyCodable.init)
    }
}

/// Anything conforming to `AnyJSONCaseIterable` can provide a
/// list of its possible values. This second protocol is
/// necessary so that one type can conditionally provide a
/// list of possible values and then (under different conditions)
/// provide a different list of possible values.
/// The "different" conditions have to do
/// with Optionality, hence the name of this protocol.
public protocol AnyWrappedJSONCaseIterable {
    static func allCases(using encoder: JSONEncoder) -> [AnyCodable]
}
