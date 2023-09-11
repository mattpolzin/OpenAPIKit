//
//  OrderedDictionry+LocallyDereferenceable.swift
//  
//
//  Created by Alberto Lagos on 11-09-23.
//

import OpenAPIKitCore
import Foundation

/// A Swift extension for dereferencing an `OrderedDictionary` conforming to the `LocallyDereferenceable` protocol.
///
/// - Parameters:
///   - components: The OpenAPI components containing definitions.
///   - references: A set of references to track dereferenced items.
///   - name: The name of the component from which the dereferencing is initiated.
///
/// - Returns: A dereferenced `OrderedDictionary` containing keys and values of dereferenced types.
///
/// - Throws: An error if dereferencing fails for any element.
extension OrderedDictionary: LocallyDereferenceable where Key: LocallyDereferenceable, Key.DereferencedSelf: Hashable, Value: LocallyDereferenceable {

    public func _dereferenced(in components: OpenAPI.Components,
                              following references: Set<AnyHashable>,
                              dereferencedFromComponentNamed name: String?) throws -> OpenAPIKitCore.OrderedDictionary<Key.DereferencedSelf, Value.DereferencedSelf> {

        try reduce(into: OrderedDictionary<Key.DereferencedSelf, Value.DereferencedSelf>()) { result, element in
            let key = try element.key._dereferenced(in: components, following: references, dereferencedFromComponentNamed: name)

            let value = try element.value._dereferenced(in: components, following: references, dereferencedFromComponentNamed: name)
            result[key] = value
        }

    }
}
