//
//  ValidityEncoder+Convenience.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

import Foundation

public func &&<T: Encodable>(lhs: @escaping (ValidationContext<T>) -> Bool, rhs: @escaping (ValidationContext<T>) -> Bool) -> (ValidationContext<T>) -> Bool {
    return { context in lhs(context) && rhs(context) }
}

public func ||<T: Encodable>(lhs: @escaping (ValidationContext<T>) -> Bool, rhs: @escaping (ValidationContext<T>) -> Bool) -> (ValidationContext<T>) -> Bool {
    return { context in lhs(context) || rhs(context) }
}

public func ==<T: Encodable, U: Equatable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] == rhs
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] != rhs
    }
}

public func ><T: Encodable, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] > rhs
    }
}

public func >=<T: Encodable, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] >= rhs
    }
}

public func <<T: Encodable, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] < rhs
    }
}

public func <=<T: Encodable, U: Comparable>(lhs: Validator.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] <= rhs
    }
}

public func ==<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] == rhs
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] != rhs
    }
}

public func ><T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] > rhs
    }
}

public func >=<T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] >= rhs
    }
}

public func <<T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] < rhs
    }
}

public func <=<T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context.subject[keyPath: lhs] <= rhs
    }
}

public func given<T: Encodable, U>(_ path: KeyPath<T, U>, _ check: @escaping (U) -> Bool) -> (ValidationContext<T>) -> Bool {
    return { context in check(context.subject[keyPath: path]) }
}

extension Validator {
    public typealias KeyPathPredicate<T: Encodable, U: Equatable> = KeyPath<ValidationContext<T>, U>

    /// Add a validation to be performed.
    ///
    /// - Parameters:
    ///     - validate: A function taking values of type `T` and validating
    ///         them. This function should return an array of all validation failures.
    ///         `ValidationError` is a good general purpose error for this use-case.
    ///     - predicate: A function returning `true` if this validator
    ///         should run against the given value.
    ///
    public func validating<T: Encodable>(
        _ validate: @escaping (T, [CodingKey]) -> [ValidationError],
        where predicate: @escaping (ValidationContext<T>) -> Bool = { _ in true }
    ) -> Self {
        return validating(Validation(if: predicate, validate: { context in validate(context.subject, context.codingPath) }))
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function that can be passed to a `ValidityEncoder`.
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
            return validate(context) ? [] : [ ValidationError(reason: "Failed to satisfy: '\(description)'.", at: context.codingPath) ]
        })
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function that can be passed to a `ValidityEncoder`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    ///     - predicate: A condition that must be met for this validation to be applied.
    public func validating<T: Encodable>(
        _ description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool,
        where predicate: @escaping (ValidationContext<T>) -> Bool) -> Self {
        let validity: (ValidationContext<T>) -> [ValidationError] = { context in
            return validate(context) ? [] : [ ValidationError(reason: "Failed to satisfy: '\(description)'.", at: context.codingPath) ]
        }

        return validating(validity, where: predicate)
    }
}
