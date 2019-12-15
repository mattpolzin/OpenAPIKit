//
//  Sampleable+OpenAPI.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 1/24/19.
//

import Foundation
import AnyCodable
import Sampleable

public typealias SampleableOpenAPIType = Sampleable & GenericOpenAPINodeType

extension Sampleable where Self: Encodable {
    public static func genericOpenAPINode(using encoder: JSONEncoder) throws -> JSONSchema {
        // short circuit for dates
        if let dateType = self as? Date.Type,
            let node = try dateType.dateOpenAPINodeGuess(using: encoder) ?? primitiveGuess(for: Self.sample, using: encoder) {
            return node
        }

        return try OpenAPIKit.genericOpenAPINode(for: Self.sample, using: encoder)
    }
}

public func genericOpenAPINode<T: Encodable>(for value: T, using encoder: JSONEncoder) throws -> JSONSchema {

    let mirror = Mirror(reflecting: value)
    let properties: [(String, JSONSchema)] = try mirror.children.compactMap { child in

        // see if we can enumerate the possible values
        let maybeAllCases: [AnyCodable]? = {
            switch type(of: child.value) {
            case let valType as AnyJSONCaseIterable.Type:
                return valType.allCases(using: encoder)
            case let valType as AnyWrappedJSONCaseIterable.Type:
                return valType.wrappedAllCases(using: encoder)
            default:
                return nil
            }
        }()

        // try to snag an OpenAPI Node
        guard let openAPINode: JSONSchema = try openAPINodeGuess(for: child.value, using: encoder) else {
            throw OpenAPITypeError.unknownNodeType(type(of: value))
        }

        // put it all together
        let newNode: JSONSchema
        if let allCases = maybeAllCases {
            newNode = openAPINode.with(allowedValues: allCases)
        } else {
            newNode = openAPINode
        }

        return zip(child.label, newNode) { ($0, $1) }
    }

    // if there are no properties, let's see if we are dealing
    // with a primitive.
    if properties.count == 0,
        let primitive = try primitiveGuess(for: value, using: encoder) {
        return primitive
    }

    // There should not be any duplication of keys since these are
    // property names, but rather than risk runtime exception, we just
    // fail to the newer value arbitrarily
    let propertiesDict = Dictionary(properties) { _, value2 in value2 }

    return .object(.init(format: .generic,
                         required: true),
                   .init(properties: propertiesDict))
}

fileprivate func primitiveGuess<T: Encodable>(for value: T, using encoder: JSONEncoder) throws -> JSONSchema? {
    let data = try encoder.encode(PrimitiveWrapper(primitive: value))
    let wrappedValue = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])

    guard let wrapperDict = wrappedValue as? [String: Any],
        wrapperDict.contains(where: { $0.key == "primitive" }) else {
            throw OpenAPICodableError.primitiveGuessFailed
    }

    let value = (wrappedValue as! [String: Any])["primitive"]!

    return try openAPINodeGuess(for: value, using: encoder)
}

internal func openAPINodeGuess(for value: Any, using encoder: JSONEncoder) throws -> JSONSchema? {
    // ideally the type specifies how to get an OpenAPI node from itself.
    let nodeGuess: JSONSchema? = try {
        switch type(of: value) {
        case let valType as OpenAPINodeType.Type:
            return try valType.openAPINode()

        case let valType as RawOpenAPINodeType.Type:
            return try valType.rawOpenAPINode()

        case let valType as WrappedRawOpenAPIType.Type:
            return try valType.wrappedOpenAPINode()

        case let valType as DoubleWrappedRawOpenAPIType.Type:
            return try valType.doubleWrappedOpenAPINode()

        case let valType as DateOpenAPINodeType.Type:
            return valType.dateOpenAPINodeGuess(using: encoder)

        case let valType as GenericOpenAPINodeType.Type:
            return try valType.genericOpenAPINode(using: encoder)

        case let valType as OpenAPIEncodedNodeType.Type:
            return try valType.openAPINode(using: encoder)

        default:
            return nil
        }
    }()

    if nodeGuess != nil {
        return nodeGuess
    }

    // second we can try for a few primitive types
    let primitiveGuess: JSONSchema? = try {
        switch value {
        case is String:
            return .string(.init(format: .generic,
                                 required: true),
                           .init())

        case is Int:
            return .integer(.init(format: .generic,
                                  required: true),
                            .init())

        case is Double:
            return .number(.init(format: .double,
                                 required: true),
                           .init())

        case is Bool:
            return .boolean(.init(format: .generic,
                                  required: true))

        case is Data:
            return .string(.init(format: .binary,
                                 required: true),
                           .init())

        case is Date:
            // we don't know what Date will end up looking like without
            // trying it out. Most likely a `.string` or `.number(format: .double)`
            return try OpenAPIKit.primitiveGuess(for: Date(), using: encoder)

        default:
            return nil
        }
    }()

    if primitiveGuess != nil {
        return primitiveGuess
    }

    // lastly, try for a type that has a primitive raw representation.
    guard case let valueWithRawType = value as? AnyRawRepresentable,
        let rawType = valueWithRawType.map({ type(of: $0).rawValueType }) else {
            return nil
    }

    let rawTypeGuess: JSONSchema? = {
        switch rawType {
        case is String.Type:
            return .string(.init(format: .generic,
                                 required: true),
                           .init())

        case is Int.Type:
            return .integer(.init(format: .generic,
                                  required: true),
                            .init())

        case is Double.Type:
            return .number(.init(format: .double,
                                 required: true),
                           .init())

        case is Bool.Type:
            return .boolean(.init(format: .generic,
                                  required: true))
        default:
            return nil
        }
    }()

    return rawTypeGuess
}

// The following wrapper is only needed because JSONEncoder cannot yet encode
// JSON fragments. It is a very unfortunate limitation that requires silly
// workarounds in edge cases like this.
private struct PrimitiveWrapper<Wrapped: Encodable>: Encodable {
    let primitive: Wrapped
}
