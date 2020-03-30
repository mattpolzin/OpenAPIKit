//
//  Either+CustomStringConvertible.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/12/19.
//

extension Either: CustomStringConvertible {
	public var description: String {
		let string: String
		switch self {
		case .a(let a):
			string = String(describing: a)
		case .b(let b):
			string = String(describing: b)
		}
		return "Either(\(string))"
	}
}
