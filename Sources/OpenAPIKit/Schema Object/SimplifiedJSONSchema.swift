//
//  SimplifiedJSONSchema.swift
//  
//
//  Created by Mathew Polzin on 9/4/20.
//

import Foundation

extension JSONSchema {
    /// Get a  simplified `DereferencedJSONSchema`.
    ///
    /// A fully simplified JSON Schema is both dereferenced and also
    /// reduced to a more normal form where possible.
    ///
    /// As an example, many compound schemas can be simplified.
    ///
    ///     {
    ///         "allOf": [
    ///             { "type": "object", "description": "Hello World" },
    ///             {
    ///                 "properties": [
    ///                     "name": { "type": "string" }
    ///                 ]
    ///             }
    ///         ]
    ///     }
    ///
    ///     simplifies to ->
    ///
    ///     {
    ///         "type": "object",
    ///         "description": "Hello World",
    ///         "properties": [
    ///             "name": { "type": "string" }
    ///         ]
    ///     }
    ///
    /// You can create simplified schemas from the `DereferencedJSONSchema`
    /// type with the `simplified()` method or you can create simplified schemas from
    /// the `JSONSchema` type with the `simplified(given:)` method (which
    /// combines dereferencing and resolving by taking the `OpenAPI.Components` as
    /// input).
    public func simplified(given components: OpenAPI.Components) throws -> DereferencedJSONSchema {
        return try self.dereferenced(in: components).simplified()
    }
}

extension DereferencedJSONSchema {
    /// Get a  simplified `DereferencedJSONSchema`.
    ///
    /// A fully simplified JSON Schema is both dereferenced and also
    /// reduced to a more normal form where possible.
    ///
    /// As an example, many compound schemas can be simplified.
    ///
    ///     {
    ///         "allOf": [
    ///             { "type": "object", "description": "Hello World" },
    ///             {
    ///                 "properties": [
    ///                     "name": { "type": "string" }
    ///                 ]
    ///             }
    ///         ]
    ///     }
    ///
    ///     simplifies to ->
    ///
    ///     {
    ///         "type": "object",
    ///         "description": "Hello World",
    ///         "properties": [
    ///             "name": { "type": "string" }
    ///         ]
    ///     }
    ///
    /// You can create simplified schemas from the `DereferencedJSONSchema`
    /// type with the `simplified()` method or you can create simplified schemas from
    /// the `JSONSchema` type with the `simplified(given:)` method (which
    /// combines dereferencing and resolving by taking the `OpenAPI.Components` as
    /// input).
    public func simplified() throws -> DereferencedJSONSchema {
        let dereferencedSchema: DereferencedJSONSchema
        switch self {
        case .all:
            var resolver = FragmentCombiner(components: .noComponents)
            try resolver.combine(self.jsonSchema)
            dereferencedSchema = try resolver.dereferencedSchema()

        // we don't currently have any schema resolution steps other than
        // combining allOf schemas. We do need to dig into any other compound
        // schemas to attempt to resolve them, though.

        case .object(let core, let object):
            let additionalProperties: Either<Bool, DereferencedJSONSchema>? = try object.additionalProperties.map {
                switch $0 {
                case .a(let bool):
                    return .a(bool)
                case .b(let schema):
                    return .b(try schema.simplified())
                }
            }
            dereferencedSchema = .object(
                core,
                .init(
                    properties: try object.properties.mapValues { try $0.simplified() },
                    additionalProperties: additionalProperties,
                    maxProperties: object.maxProperties,
                    minProperties: object._minProperties
                )
            )

        case .array(let core, let array):
            dereferencedSchema = .array(
                core,
                .init(
                    items: try array.items.map { try $0.simplified() },
                    maxItems: array.maxItems,
                    minItems: array._minItems,
                    uniqueItems: array._uniqueItems
                )
            )

        case .any(of: let schemas, core: let core):
            dereferencedSchema = .any(of: try schemas.map { try $0.simplified() }, core: core)

        case .one(of: let schemas, core: let core):
            dereferencedSchema = .one(of: try schemas.map { try $0.simplified() }, core: core)

        case .not(let schema, core: let core):
            dereferencedSchema =  .not(try schema.simplified(), core: core)

        default:
            dereferencedSchema = self
        }

        return dereferencedSchema
    }
}
