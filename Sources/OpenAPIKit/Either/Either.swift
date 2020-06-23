//
//  Either.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 11/22/18.
//

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
