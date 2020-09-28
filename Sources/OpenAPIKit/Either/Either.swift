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

	public var a: A? {
		guard case let .a(ret) = self else { return nil }
		return ret
	}

	public init(_ a: A) {
		self = .a(a)
	}

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

// MARK: - LocallyDereferenceable
extension Either: LocallyDereferenceable where A: LocallyDereferenceable, B: LocallyDereferenceable, A.DereferencedSelf == B.DereferencedSelf {
    public func dereferenced(in components: OpenAPI.Components) throws -> A.DereferencedSelf {
        switch self {
        case .a(let value):
            return try value.dereferenced(in: components)
        case .b(let value):
            return try value.dereferenced(in: components)
        }
    }
}

extension Either: Validatable where A: Validatable, B: Validatable {}
