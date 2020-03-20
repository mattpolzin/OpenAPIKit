//
//  Either+CustomStringConvertible.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/12/19.
//

extension Either: CustomStringConvertible {
	public var description: String {
		let str: String
		switch self {
		case .a(let a):
			str = String(describing: a)
		case .b(let b):
			str = String(describing: b)
		}
		return "Either(\(str))"
	}
}
