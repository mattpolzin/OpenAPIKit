//
//  Either.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 11/22/18.
//

/// Can contain a value of either type `A` or type `B`.
///
/// If it contains a value of type `A`, then the value can
/// be accessed with the `.a` property and similarly for
/// type `B` and the `.b` property.
///
/// A type-erased value can be retrieved with the `.value`
/// property.
///
public enum Either<A, B> {
	case a(A)
	case b(B)

    /// Get the first of the possible values of the `Either` (if it is
    /// set).
    ///
    /// This is sometimes known as the `Left` or error case of some
    /// `Either` types, but `OpenAPIKit` makes regular use of
    /// this type in situations where neither of the possible values could
    /// be considered an error. In fact, `OpenAPIKit` sticks to using
    /// the Swift `Result` type where such semantics are needed.
	public var a: A? {
		guard case let .a(ret) = self else { return nil }
		return ret
	}

	public init(_ a: A) {
		self = .a(a)
	}

    /// Get the second of the possible values of the `Either` (if
    /// it is set).
	public var b: B? {
		guard case let .b(ret) = self else { return nil }
		return ret
	}

	public init(_ b: B) {
		self = .b(b)
	}

    public var value: Any {
        switch self {
        case .a(let ret): return ret
        case .b(let ret): return ret
        }
    }
}

extension Either: Equatable where A: Equatable, B: Equatable {}

extension Either {
    public func mapFirst<T>(_ transform: (A) -> T) -> Either<T,B> {
        switch self {
        case .a(let a):
            return .a(transform(a))
        case .b(let b):
            return .b(b)
        }
    }

    public func mapSecond<T>(_ transform: (B) -> T) -> Either<A,T> {
        switch self {
        case .a(let a):
            return .a(a)
        case .b(let b):
            return .b(transform(b))
        }
    }
}
