//
//  Validatable.swift
//  
//
//  Created by Mathew Polzin on 8/8/20.
//

/// A Marker protocol that indicates a type can be used
/// as the **subject** of a `Validation`.
///
/// Another way to say that is that these are the types that
/// can be used to specialize `ValidationContext<Subject>`.
///
/// As a general rule, you can assume that almost all types under
/// the `OpenAPI` namespace are validatable; Other types provided
/// by this library, like the various `Dereferenced` types are generally
/// _not_ validatable.
///
/// **Example**:
///
///     // In this call to `validating()`,
///     // `OpenAPI.Document` is Validatable.
///     Validator().validating(
///         "Using OpenAPI v 3.0.0",
///         check: \OpenAPI.Document.openAPIVersion == .v3_0_0
///     )
///
/// **Example**:
///
///     // In this Validation construction,
///     //  `OpenAPI.Content.Map` is Validatable
///     let allRoutesOfferJSON = Validation(
///         description: "All content maps have JSON members.",
///         check: \OpenAPI.Content.Map[.json] != nil
///     )
///
public protocol Validatable {}

// most types conform to Validatable where they are defined.
// types not belonging to this library gain their conformance here.
extension String: Validatable {}
extension Int: Validatable {}
extension UInt: Validatable {}
extension Double: Validatable {}
extension Float: Validatable {}
extension Bool: Validatable {}
extension Array: Validatable where Element: Validatable {}
extension Dictionary: Validatable where Value: Validatable {}
extension Optional: Validatable where Wrapped: Validatable {}
