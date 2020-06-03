//
//  ValidityEncoder+Convenience.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

import Foundation

public func ==<T: Encodable, U: Equatable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context[keyPath: lhs] == rhs
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context[keyPath: lhs] != rhs
    }
}

public func ><T: Encodable, U: Comparable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context[keyPath: lhs] > rhs
    }
}

public func <<T: Encodable, U: Comparable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context[keyPath: lhs] < rhs
    }
}

public func ==<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context.subject[keyPath: lhs] == rhs
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context.subject[keyPath: lhs] != rhs
    }
}

public func ><T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context.subject[keyPath: lhs] > rhs
    }
}

public func <<T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Bool {
    return { context, _ in
        return context.subject[keyPath: lhs] < rhs
    }
}

public func ==<T: Encodable, U: Equatable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context[keyPath: lhs]
        return lhsValue == rhs ? .valid : .invalid(because: "\(String(describing:U.self)) value was \(lhs) but it needs to be equal to \(rhs).", at: codingPath)
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context[keyPath: lhs]
        return lhsValue != rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value must not be \(lhsValue).", at: codingPath)
    }
}

public func ><T: Encodable, U: Comparable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context[keyPath: lhs]
        return lhsValue > rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value was \(lhsValue) but it needs to be greater than \(rhs).", at: codingPath)
    }
}

public func <<T: Encodable, U: Comparable>(lhs: ValidityEncoder.KeyPathPredicate<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context[keyPath: lhs]
        return lhsValue < rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value was \(lhsValue) but it needs to be less than \(rhs).", at: codingPath)
    }
}

public func ==<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context.subject[keyPath: lhs]
        return lhsValue == rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value was \(lhsValue) but it needs to be equal to \(rhs).", at: codingPath)
    }
}

public func !=<T: Encodable, U: Equatable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context.subject[keyPath: lhs]
        return lhsValue != rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value must not be \(lhsValue).", at: codingPath)
    }
}

public func ><T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context.subject[keyPath: lhs]
        return lhsValue > rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value was \(lhsValue) but it needs be greater than \(rhs).", at: codingPath)
    }
}

public func <<T: Encodable, U: Comparable>(lhs: KeyPath<T, U>, rhs: U) -> (ValidationContext<T>, [CodingKey]) -> Validity {
    return { context, codingPath in
        let lhsValue = context.subject[keyPath: lhs]
        return lhsValue < rhs ? .valid : .invalid(because: "\(String(describing: U.self)) value was \(lhsValue) but it needs to be less than \(rhs).", at: codingPath)
    }
}

extension ValidityEncoder {
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
        _ validate: @escaping (T, [CodingKey]) -> Validity,
        if predicate: @escaping (ValidationContext<T>, [CodingKey]) -> Bool = { _, _ in true }
    ) -> Self {
        return validating(Validator(if: predicate, validate: { context, codingPath in validate(context.subject, codingPath) }))
    }

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
        _ validate: @escaping (ValidationContext<T>, [CodingKey]) -> Validity,
        if predicate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        return validating(Validator(if: { context, _ in predicate(context) } , validate: validate))
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function that can be passed to a `ValidityEncoder`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    public func validating<T: Encodable>(_ description: String, asserting validate: @escaping (ValidationContext<T>) -> Bool) -> Self {
        return validating({ context, codingPath in
            return validate(context) ? .valid : .invalid(because: "Failed to satisfy: '\(description)'.", at: codingPath)
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
        asserting validate: @escaping (ValidationContext<T>) -> Bool,
        if predicate: @escaping (ValidationContext<T>, [CodingKey]) -> Bool) -> Self {
        return validating(
            { context, codingPath in
            return validate(context) ? .valid : .invalid(because: "Failed to satisfy: '\(description)'.", at: codingPath)
            },
            if: predicate
        )
    }
}
