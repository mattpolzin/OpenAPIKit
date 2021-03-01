//
//  Either+LocallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

// MARK: - LocallyDereferenceable
extension Either: LocallyDereferenceable where A: LocallyDereferenceable, B: LocallyDereferenceable, A.DereferencedSelf == B.DereferencedSelf {
    public func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> A.DereferencedSelf {
        switch self {
        case .a(let value):
            return try value._dereferenced(in: components, following: references)
        case .b(let value):
            return try value._dereferenced(in: components, following: references)
        }
    }
}
