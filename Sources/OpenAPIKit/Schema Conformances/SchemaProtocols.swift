//
//  SchemaProtocols.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//
//  "Schema" protocols allow different Swift types to
//  declare themselves able to represent themselves
//  as an Open API Schema Object.

import Foundation
import AnyCodable
import Sampleable

/// Anything conforming to `OpenAPINodeType` can provide an
/// OpenAPI schema representing itself.
public protocol OpenAPISchemaType {
    static func openAPISchema() throws -> JSONSchema
}

/// Anything conforming to `OpenAPIEncodedSchemaType` can provide an
/// OpenAPI schema representing itself but it may need an Encoder
/// to do its job.
public protocol OpenAPIEncodedSchemaType {
    static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema
}

extension OpenAPIEncodedSchemaType where Self: Sampleable, Self: Encodable {
    public static func openAPINodeWithExample(using encoder: JSONEncoder = JSONEncoder()) throws -> JSONSchema {
        return try openAPISchema(using: encoder).with(example: Self.successSample ?? Self.sample, using: encoder)
    }
}

/// Anything conforming to `RawOpenAPISchemaType` can provide an
/// OpenAPI schema representing itself. This second protocol is
/// necessary so that one type can conditionally provide a
/// schema and then (under different conditions) provide a
/// different schema. The "different" conditions have to do
/// with Raw Representability, hence the name of this protocol.
public protocol RawOpenAPISchemaType {
    static func rawOpenAPISchema() throws -> JSONSchema
}

extension RawOpenAPISchemaType where Self: RawRepresentable, RawValue: OpenAPISchemaType {
    public static func rawOpenAPISchema() throws -> JSONSchema {
        return try RawValue.openAPISchema()
    }
}

/// A `GenericOpenAPISchemaType` can take a stab at
/// determining its `JSONSchema` but results are not
/// as certain as with `OpenAPINodeType`.
public protocol GenericOpenAPISchemaType {
    static func genericOpenAPISchemaGuess(using encoder: JSONEncoder) throws -> JSONSchema
}

/// Anything conforming to `DateOpenAPISchemaType` is
/// able to attempt to represent itself as a date `JSONSchema`
public protocol DateOpenAPISchemaType {
    static func dateOpenAPISchemaGuess(using encoder: JSONEncoder) -> JSONSchema?
}
