//
//  Validation.swift
//  
//
//  Created by Mathew Polzin on 1/26/20.
//

/// The context in which a validation can be applied.
///
/// It may or may not be important for a particular validation
/// to know what the whole `OpenAPI.Document` looks like
/// or the coding path where the validation is being applied,
/// but it always has access to these two pieces of information
/// in addition to the subject (a value of the type on which the
/// validation is specialized).
public struct ValidationContext<T: Encodable> {
    public let document: OpenAPI.Document
    public let subject: T
    public let codingPath: [CodingKey]
}

/// Holds a function to determine if a validation
/// applies (`predicate`) and a function that applies
/// a validation (`validate`).
public struct Validation<T: Encodable> {
    /// Applies validation on type `T`. Throws if validation fails.
    ///
    /// The context includes
    /// - The entire `OpenAPI.Document`
    /// - A value of the type in which this validator specializes.
    /// - The coding path where the validation is occurring.
    public let validate: (ValidationContext<T>) -> [ValidationError]

    /// Returns `true` if this validator should apply to
    /// the given value of type `T`.
    ///
    /// The context includes
    /// - The entire `OpenAPI.Document`
    /// - A value of the type in which this validator specializes.
    /// - The coding path where the validation is occurring.
    public let predicate: (ValidationContext<T>) -> Bool

    /// Create a Validation that by default appllies to all
    /// values of type `T`.
    ///
    /// - Parameters:
    ///     - validate: A function taking values of type `T` and validating
    ///         them. This function should throw if a validation error occurs.
    ///     - predicate: A function returning `true` if this validator
    ///         should run against the given value.
    ///
    public init(
        check validate: @escaping (ValidationContext<T>) -> [ValidationError],
        where predicate: @escaping (ValidationContext<T>) -> Bool = { _ in true }
    ) {
        self.validate = validate
        self.predicate = predicate
    }
}

/// Validation errors are just a textual reason for validation failure and
/// a coding path where the validation error occurred.
public struct ValidationError: Swift.Error, CustomStringConvertible {
    /// The reason for the validation failure.
    public let reason: String
    /// The location where the failure occurred.
    public let codingPath: [CodingKey]

    /// Create a new `ValidationError` with the given
    /// reason and location (coding path).
    public init(reason: String, at path: [CodingKey]) {
        self.reason = reason
        self.codingPath = path
    }

    public var description: String {
        "\(reason) at path: \(codingPath.map { $0.intValue.map { "[\($0)]" } ?? "/\($0.stringValue)" }.joined())"
    }
}

/// Collects `ValidationErrors`.
public struct ValidationErrors: Swift.Error {
    public let values: [ValidationError]
}

/// Erases the type on which a `Validator` is specialized and combines
/// the predicate and validation logic into one `apply` function.
internal struct AnyValidation {
    // The only reason apply is private is because `attempt()` and `callAsFunction()`
    // get us back our argument labels but are otherwise just straight-forward calls
    // to `apply()`
    private let apply: (OpenAPI.Document, Encodable, [CodingKey]) -> [ValidationError]

    #if swift(>=5.2)
    func callAsFunction(_ value: Encodable, in document: OpenAPI.Document, at codingPath: [CodingKey]) -> [ValidationError] {
        return apply(document, value, codingPath)
    }
    #else
    func attempt(on value: Encodable, in document: OpenAPI.Document, at codingPath: [CodingKey]) -> [ValidationError] {
        return apply(document, value, codingPath)
    }
    #endif

    init<T: Encodable>(_ validator: Validation<T>) {
        self.apply = { document, input, codingPath in
            
            guard let subject = input as? T else {
                return []
            }
            guard type(of: subject) == type(of: input) else {
                // apparently we need to guard against T? being
                // coerced to T above.
                return []
            }
            let context = ValidationContext(document: document, subject: subject, codingPath: codingPath)
            guard validator.predicate(context) else {
                return []
            }

            return validator.validate(context)
        }
    }
}
