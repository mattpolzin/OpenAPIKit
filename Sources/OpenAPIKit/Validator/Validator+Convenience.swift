//
//  Validator+Convenience.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

import Foundation

public func &&<T>(
    lhs: @escaping (ValidationContext<T>) -> Bool,
    rhs: @escaping (ValidationContext<T>) -> Bool
) -> (ValidationContext<T>) -> Bool {
    return { context in lhs(context) && rhs(context) }
}

public func ||<T>(
    lhs: @escaping (ValidationContext<T>) -> Bool,
    rhs: @escaping (ValidationContext<T>) -> Bool
) -> (ValidationContext<T>) -> Bool {
    return { context in lhs(context) || rhs(context) }
}

public func ==<T, U: Equatable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] == rhs
    }
}

public func !=<T, U: Equatable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] != rhs
    }
}

public func ><T, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] > rhs
    }
}

public func >=<T, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] >= rhs
    }
}

public func <<T, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] < rhs
    }
}

public func <=<T, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] <= rhs
    }
}

public func ==<T, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] == rhs
    }
}

public func !=<T, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] != rhs
    }
}

public func ><T, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] > rhs
    }
}

public func >=<T, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] >= rhs
    }
}

public func <<T, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] < rhs
    }
}

public func <=<T, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] <= rhs
    }
}

/// Create a validation or predicate function from a KeyPath
/// and a function operating on that value.
public func take<T, U>(_ path: KeyPath<T, U>, check: @escaping (U) -> Bool) -> (ValidationContext<T>) -> Bool {
    return { context in check(context.subject[keyPath: path]) }
}

/// Create a validation or predicate function from a KeyPath
/// and a function operating on that value.
public func take<T, U>(_ path: KeyPath<ValidationContext<T>, U>, check: @escaping (U) -> Bool) -> (ValidationContext<T>) -> Bool {
    return { context in check(context[keyPath: path]) }
}

/// Lift the value the KeyPath points to into any number of validations
/// on that value producing a new validation function that operates on the type of
/// the root of the KeyPath and results in all the given validations being run.
///
/// This can be used to perform logic such as:
/// *"When type A has property b of type String with value 'hello',*
/// *run validations alpha and beta (both of which are Validations on type String"*
///
/// **Example**
///
///     let alpha = Validator<String>(...)
///     let beta = Validator<String>(...)
///
///     let validator = Validator<A>(
///         check: lift(\.a, into: alpha, beta),
///         when: \.a == "hello"
///     )
///
public func lift<T, U>(_ path: KeyPath<ValidationContext<T>, U>, into validations: Validation<U>...) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        return validations.flatMap { $0.apply(to: context[keyPath: path], at: context.codingPath, in: context.document) }
    }
}

/// Lift the value the KeyPath points to into any number of validations
/// on that value producing a new validation function that operates on the type of
/// the root of the KeyPath and results in all the given validations being run.
///
/// This can be used to perform logic such as:
/// *"When type A has property b of type String with value 'hello',*
/// *run validations alpha and beta (both of which are Validations on type String"*
///
/// **Example**
///
///     let alpha = Validator<String>(...)
///     let beta = Validator<String>(...)
///
///     let validator = Validator<A>(
///         check: lift(\.a, into: alpha, beta),
///         when: \.a == "hello"
///     )
///
public func lift<T, U>(_ path: KeyPath<T, U>, into validations: Validation<U>...) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        return validations.flatMap { $0.apply(to: context.subject[keyPath: path], at: context.codingPath, in: context.document) }
    }
}

/// Unwrap the value pointed to by the KeyPath. Fail
/// with a `ValidationError` if the value is `nil` or
/// pass onto each validation provided otherwise.
///
/// See `lift<T, U>(_:,into:)` for more information
/// on what this function does when the value pointed to
/// is non-nil.
///
public func unwrap<T, U>(_ path: KeyPath<ValidationContext<T>, U?>, into validations: Validation<U>...) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        guard let subject = context[keyPath: path] else {
            return [ ValidationError(reason: "Tried to unwrap an optional for path \(String(describing: path)) and found `nil`", at: context.codingPath) ]
        }
        return validations.flatMap { $0.apply(to: subject, at: context.codingPath, in: context.document) }
    }
}

/// Unwrap the value pointed to by the KeyPath. Fail
/// with a `ValidationError` if the value is `nil` or
/// pass onto each validation provided otherwise.
///
/// See `lift<T, U>(_:,into:)` for more information
/// on what this function does when the value pointed to
/// is non-nil.
///
public func unwrap<T, U>(_ path: KeyPath<T, U?>, into validations: Validation<U>...) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        guard let subject = context.subject[keyPath: path] else {
            return [ ValidationError(reason: "Tried to unwrap an optional for path \(String(describing: path)) and found `nil`", at: context.codingPath) ]
        }
        return validations.flatMap { $0.apply(to: subject, at: context.codingPath, in: context.document) }
    }
}

extension Validator {
    public typealias KeyPathPredicate<T: Encodable, U: Equatable> = KeyPath<ValidationContext<T>, U>

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function and add it to the `Validator`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    public func validating<T: Encodable>(
        _ description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        return validating({ context in
            return validate(context)
                ? []
                : [ ValidationError(reason: "Failed to satisfy: \(description)", at: context.codingPath) ]
        })
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function and add it to the `Validator`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    ///     - predicate: A condition that must be met for this validation to be applied.
    public func validating<T: Encodable>(
        _ description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool,
        when predicate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        let validity: (ValidationContext<T>) -> [ValidationError] = { context in
            return validate(context)
                ? []
                : [ ValidationError(reason: "Failed to satisfy: \(description)", at: context.codingPath) ]
        }

        return validating(validity, when: predicate)
    }
}
