//
//  StringConvertibleHintProvider.swift
//  
//
//  Created by Mathew Polzin on 3/29/20.
//

public protocol StringConvertibleHintProvider {
    /// Get a `String` describing why the given value cannot
    /// be used to create this type. Returns `nil` if there are no
    /// problems with the provided value.
    ///
    /// The idea is for this function to augment the use of `init?(rawValue:)`
    /// or `init?(_ description:)` by providing a hint as to why initialization
    /// from a `String` value will fail.
    static func problem(with proposedString: String) -> String?
}
