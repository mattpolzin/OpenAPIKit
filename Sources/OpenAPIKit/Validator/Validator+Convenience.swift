//
//  Validator+Convenience.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

// MARK: - Operators

// MARK: Context -> Error Array
public func &&<T>(
    lhs: @escaping (ValidationContext<T>) -> [ValidationError],
    rhs: @escaping (ValidationContext<T>) -> [ValidationError]
) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        lhs(context) + rhs(context)
    }
}

public func ||<T>(
    lhs: @escaping (ValidationContext<T>) -> [ValidationError],
    rhs: @escaping (ValidationContext<T>) -> [ValidationError]
) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        let leftHandCheck = lhs(context)
        if leftHandCheck.isEmpty {
            return []
        }
        let rightHandCheck = rhs(context)
        if rightHandCheck.isEmpty {
            return []
        }
        return leftHandCheck + rightHandCheck
    }
}

// MARK: Context -> Bool
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

// MARK: Context KeyPath -> Bool
public func ==<T, U: Equatable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] == rhs
    }
}

public func !=<T, U: Equatable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] != rhs
    }
}

public func ><T, U: Comparable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] > rhs
    }
}

public func >=<T, U: Comparable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] >= rhs
    }
}

public func <<T, U: Comparable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] < rhs
    }
}

public func <=<T, U: Comparable>(lhs: KeyPath<ValidationContext<T>, U>, rhs: U) -> (ValidationContext<T>) -> Bool {
    return { context in
        return context[keyPath: lhs] <= rhs
    }
}

// MARK: Subject KeyPath -> Bool
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

// MARK: - Methods

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
/// - Parameters:
///         - path: The path to lift into the given validations.
///         - validations: One or more validations to perform on the value
///             the KeyPath points to.
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
/// - Parameters:
///         - path: The path to unwrap.
///         - validations: One or more validations to perform on the value
///             the KeyPath points to.
///         - description: (Optionally) describe the unwrap operation so that
///             the failure error is more useful to you.
///
/// See `lift<T, U>(_:,into:)` for more information
/// on what this function does when the value pointed to
/// is non-nil.
///
public func unwrap<T, U>(_ path: KeyPath<ValidationContext<T>, U?>, into validations: Validation<U>..., description: String? = nil) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        guard let subject = context[keyPath: path] else {
            let error = description.map { "Tried to unwrap but found nil: \($0)" }
                ?? "Tried to unwrap an optional for path \(String(describing: path)) and found `nil`"
            return [ ValidationError(reason: error, at: context.codingPath) ]
        }
        return validations.flatMap { $0.apply(to: subject, at: context.codingPath, in: context.document) }
    }
}

/// Unwrap the value pointed to by the KeyPath. Fail
/// with a `ValidationError` if the value is `nil` or
/// pass onto each validation provided otherwise.
///
/// - Parameters:
///         - path: The path to unwrap.
///         - validations: One or more validations to perform on the value
///             the KeyPath points to.
///         - description: (Optionally) describe the unwrap operation so that
///             the failure error is more useful to you.
///
/// See `lift<T, U>(_:,into:)` for more information
/// on what this function does when the value pointed to
/// is non-nil.
///
public func unwrap<T, U>(_ path: KeyPath<T, U?>, into validations: Validation<U>..., description: String? = nil) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        guard let subject = context.subject[keyPath: path] else {
            let error = description.map { "Tried to unwrap but found nil: \($0)" }
                ?? "Tried to unwrap an optional for path \(String(describing: path)) and found `nil`"
            return [ ValidationError(reason: error, at: context.codingPath) ]
        }
        return validations.flatMap { $0.apply(to: subject, at: context.codingPath, in: context.document) }
    }
}

/// Apply all of the given validations to the current context.
///
/// This is equivalent to calling `lift` with the keypath `\.self`
/// or inlining each of the individual validations with the `&&`
/// operator to apply them all. The benefit to this approach is
/// being able to create reusable separate components that
/// add up to the validation being written.
///
/// **Example**
///
///     let isLongerThanThreeChars = Validator<String>(...)
///     let hasSpecialChars = Validator<String>(...)
///
///     let validator = Validator<String>(
///         check: all(isLongerThanThreeChars, hasSpecialChars)
///     )
///
public func all<T>(_ validations: Validation<T>...) -> (ValidationContext<T>) -> [ValidationError] {
    return { context in
        return validations.flatMap { $0.apply(to: context.subject, at: context.codingPath, in: context.document) }
    }
}
