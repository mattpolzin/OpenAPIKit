//
//  Optional+ZipWith.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/19/19.
//

/// Zip two optionals together with the given operation performed on
/// the unwrapped contents. If either optional is nil, the zip
/// yields nil.
internal func zip<X, Y, Z>(_ left: X?, _ right: Y?, with fn: (X, Y) -> Z) -> Z? {
    return left.flatMap { lft in right.map { rght in fn(lft, rght) }}
}
