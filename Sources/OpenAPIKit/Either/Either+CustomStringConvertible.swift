//
//  Either+CustomStringConvertible.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/12/19.
//

extension Either: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
        switch self {
        case .a(let a):
            return String(describing: a)
        case .b(let b):
            return String(describing: b)
        }
	}

    public var debugDescription: String {
        let string: String
        switch self {
        case .a(let a):
            string = (a as? CustomDebugStringConvertible)?.debugDescription ?? String(describing: a)
        case .b(let b):
            string = (b as? CustomDebugStringConvertible)?.debugDescription ?? String(describing: b)
        }
        return "Either(\(string))"
    }
}
