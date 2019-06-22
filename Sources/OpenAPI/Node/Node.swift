//
//  Node.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import AnyCodable
import Sampleable

/// Anything conforming to `OpenAPINodeType` can provide an
/// OpenAPI schema representing itself.
public protocol OpenAPINodeType {
    static func openAPINode() throws -> JSONNode
}

/// Anything conforming to `OpenAPIEncodedNodeType` can provide an
/// OpenAPI schema representing itself but it may need an Encoder
/// to do its job.
public protocol OpenAPIEncodedNodeType {
    static func openAPINode(using encoder: JSONEncoder) throws -> JSONNode
}

extension OpenAPIEncodedNodeType where Self: Sampleable, Self: Encodable {
    public static func openAPINodeWithExample(using encoder: JSONEncoder = JSONEncoder()) throws -> JSONNode {
        return try openAPINode(using: encoder).with(example: Self.successSample ?? Self.sample, using: encoder)
    }
}

/// Anything conforming to `RawOpenAPINodeType` can provide an
/// OpenAPI schema representing itself. This second protocol is
/// necessary so that one type can conditionally provide a
/// schema and then (under different conditions) provide a
/// different schema. The "different" conditions have to do
/// with Raw Representability, hence the name of this protocol.
public protocol RawOpenAPINodeType {
    static func rawOpenAPINode() throws -> JSONNode
}

/// Anything conforming to `RawOpenAPINodeType` can provide an
/// OpenAPI schema representing itself. This third protocol is
/// necessary so that one type can conditionally provide a
/// schema and then (under different conditions) provide a
/// different schema. The "different" conditions have to do
/// with Optionality, hence the name of this protocol.
public protocol WrappedRawOpenAPIType {
    static func wrappedOpenAPINode() throws -> JSONNode
}

/// Anything conforming to `RawOpenAPINodeType` can provide an
/// OpenAPI schema representing itself. This third protocol is
/// necessary so that one type can conditionally provide a
/// schema and then (under different conditions) provide a
/// different schema. The "different" conditions have to do
/// with Optionality, hence the name of this protocol.
public protocol DoubleWrappedRawOpenAPIType {
    // NOTE: This is definitely a rabbit hole... hopefully I
    // will realize I've been missing something obvious
    // and dig my way back out at some point...
    static func wrappedOpenAPINode() throws -> JSONNode
}

/// A GenericOpenAPINodeType can take a stab at
/// determining its OpenAPINode because it is sampleable.
public protocol GenericOpenAPINodeType {
    static func genericOpenAPINode(using encoder: JSONEncoder) throws -> JSONNode
}

/// Anything conforming to `DateOpenAPINodeType` is
/// able to attempt to represent itself as a date OpenAPINode
public protocol DateOpenAPINodeType {
    static func dateOpenAPINodeGuess(using encoder: JSONEncoder) -> JSONNode?
}
