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
public struct ValidationContext<T> {
    public let document: OpenAPI.Document
    public let subject: T
    public let codingPath: [CodingKey]
}

/// Holds a function to determine if a validation
/// applies (`predicate`) and a function that applies
/// a validation (`validate`).
public struct Validation<T> {
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

    /// Apply the validation to the given value if the predicate
    /// returns `true`.
    public func apply(to subject: T, at codingPath: [CodingKey], in document: OpenAPI.Document) -> [ValidationError] {

        let context = ValidationContext(document: document, subject: subject, codingPath: codingPath)
        guard predicate(context) else {
            return []
        }

        return validate(context)
    }

    /// Create a Validation that appllies to values of type `T`.
    ///
    /// You can return any number of errors from your `validate`
    /// function, each with its own description of a problem. Add an
    /// optional `predicate` to apply your validation to a subset of
    /// all values of the type your `validate` method operates on.
    ///
    /// - Parameters:
    ///     - validate: A function taking validation contexts containing
    ///         subjects of type `T` and validating them. This function must
    ///         return an array of errors. If validation succeeds, return an empty
    ///         array.
    ///     - predicate: A function returning `true` if this validator
    ///         should run against the given value.
    ///
    public init(
        check validate: @escaping (ValidationContext<T>) -> [ValidationError],
        when predicate: @escaping (ValidationContext<T>) -> Bool = { _ in true }
    ) {
        self.validate = validate
        self.predicate = predicate
    }

    /// Create a Validation with a single error that applies to values of type `T`.
    ///
    /// This version of the initializer assumes only one error can occur for this
    /// validation and in exchange you can frontload the description of the validation
    /// and simplify the body of the `validate` method to just return `false`
    /// if the value is invalid.
    ///
    /// - Parameters:
    ///     - description: A description of the correct state described by the
    ///         `validate` function. Upon failure, the error will read "Failed to satisfy: <description>".
    ///     - validate: A function taking validation contexts containing
    ///         subjects of type `T` and validating them. This function returns
    ///         `true` if validation succeeds and `false` if it fails.
    ///     - predicate: A function returning `true` if this validator
    ///         should run against the given value.
    ///
    public init(
        description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool,
        when predicate: @escaping (ValidationContext<T>) -> Bool = { _ in true }
    ) {
        let validity: (ValidationContext<T>) -> [ValidationError] = { context in
            return validate(context)
                ? []
                : [ ValidationError(reason: "Failed to satisfy: \(description)", at: context.codingPath) ]
        }
        self.init(check: validity, when: predicate)
    }
}

/// Validation errors are just a textual reason for validation failure and
/// a coding path where the validation error occurred.
public struct ValidationError: Swift.Error, CustomStringConvertible {
    /// The reason for the validation failure.
    public let reason: String
    /// The location where the failure occurred.
    public let codingPath: [CodingKey]
    /// A string representation of the whole coding
    /// path.
    public var codingPathString: String { codingPath.stringValue }

    /// Create a new `ValidationError` with the given
    /// reason and location (coding path).
    public init(reason: String, at path: [CodingKey]) {
        self.reason = reason
        self.codingPath = path
    }

    public var description: String {
        "\(reason) at path: \(codingPath.stringValue)"
    }
}

/// Collects `ValidationErrors`.
public struct ValidationErrors: Swift.Error {
    public let values: [ValidationError]
}

/// Erases the type on which a `Validator` is specialized and combines
/// the predicate and validation logic into one `apply` function.
internal struct AnyValidation {
    // The only reason apply is private is because `apply()` gets us back
    // our argument labels but are otherwise just straight-forward calls
    // to `_apply()`
    private let _apply: (Any, [CodingKey], OpenAPI.Document) -> [ValidationError]

    func apply(to value: Any, at codingPath: [CodingKey], in document: OpenAPI.Document) -> [ValidationError] {
        return _apply(value, codingPath, document)
    }

    init<T>(_ validation: Validation<T>) {
        self._apply = { input, codingPath, document in

            guard let subject = input as? T else {
                return []
            }
            guard type(of: subject) == type(of: input) else {
                // we need to guard against `T?` being
                // coerced to `T` above.
                return []
            }

            return validation.apply(to: subject, at: codingPath, in: document)
        }
    }
}
