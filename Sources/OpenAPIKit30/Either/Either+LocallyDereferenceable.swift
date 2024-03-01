//
//  Either+LocallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

// MARK: - LocallyDereferenceable
extension Either: LocallyDereferenceable where A: LocallyDereferenceable, B: LocallyDereferenceable, A.DereferencedSelf == B.DereferencedSelf {
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> A.DereferencedSelf {
        switch self {
        case .a(let value):
            return try value._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        case .b(let value):
            return try value._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        }
    }
}
