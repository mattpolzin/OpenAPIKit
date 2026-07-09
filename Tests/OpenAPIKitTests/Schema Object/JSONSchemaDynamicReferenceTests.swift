//
//  JSONSchemaDynamicReferenceTests.swift
//
//  Tests for `$dynamicRef` / `$dynamicAnchor` support (JSON Schema 2020-12, [§7.7]
//  https://json-schema.org/draft/2020-12/json-schema-core#section-7.7).
//

import Foundation
import XCTest
import OpenAPIKit

final class JSONSchemaDynamicReferenceTests: XCTestCase {

    // MARK: - Decoding

    func test_decodeDynamicReference_anchor() throws {
        let data = #"""
        {
            "$dynamicRef": "#category"
        }
        """#.data(using: .utf8)!

        let schema = try orderUnstableDecode(JSONSchema.self, from: data)

        XCTAssertTrue(schema.isDynamicReference)
        XCTAssertFalse(schema.isReference)
        XCTAssertEqual(schema.dynamicReference?.absoluteString, "#category")
        // No "unsupported attributes" warning -- this is the core regression
        // being fixed (previously `$dynamicRef`-only schemas warned and decoded
        // as empty fragments).
        XCTAssertTrue(schema.warnings.isEmpty, "expected no warnings, got: \(schema.warnings)")
    }

    func test_decodeDynamicReference_component() throws {
        let data = #"""
        {
            "$dynamicRef": "#/components/schemas/Foo"
        }
        """#.data(using: .utf8)!

        let schema = try orderUnstableDecode(JSONSchema.self, from: data)

        XCTAssertTrue(schema.isDynamicReference)
        XCTAssertEqual(schema.dynamicReference?.name, "Foo")
        XCTAssertTrue(schema.warnings.isEmpty)
    }

    func test_decodeDynamicRef_doesNotEmitUnsupportedAttributesWarning() throws {
        // Previously a `$dynamicRef` whose only attribute was the dynamic
        // reference decoded as an empty fragment with the warning
        // "Found nothing but unsupported attributes."
        let data = "{\"$dynamicRef\":\"#node\"}".data(using: .utf8)!

        let schema = try orderUnstableDecode(JSONSchema.self, from: data)

        XCTAssertTrue(schema.isDynamicReference)
        XCTAssertEqual(schema.dynamicReference?.absoluteString, "#node")
        let hasUnsupportedWarning = schema.warnings.contains { warning in
            String(describing: warning).contains("unsupported attributes")
        }
        XCTAssertFalse(hasUnsupportedWarning)
    }

    // MARK: - Encoding / round-trip

    func test_encodeDynamicReference_anchor() throws {
        let schema = JSONSchema.dynamicReference(.anchor("category"))

        let encoded = try orderUnstableEncode(schema)

        XCTAssertEqual(
            try orderUnstableDecode(JSONSchema.self, from: encoded),
            schema
        )
        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        XCTAssertTrue(encodedString.contains("$dynamicRef"))
        XCTAssertTrue(encodedString.contains("#category"))
    }

    func test_refWithPlainFragmentRoundTripsAsAnchor() throws {
        // A `$ref` whose fragment has no leading '/' (e.g. "#foo") is a plain
        // anchor reference. It must round-trip verbatim rather than being
        // rewritten with a slash.
        let data = "{\"$ref\":\"#foo\"}".data(using: .utf8)!

        let schema = try orderUnstableDecode(JSONSchema.self, from: data)
        XCTAssertTrue(schema.isReference)
        XCTAssertEqual(schema.reference?.absoluteString, "#foo")

        let encoded = try orderUnstableEncode(schema)
        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        XCTAssertTrue(encodedString.contains("$ref"))
        XCTAssertTrue(encodedString.contains("#foo"))
        XCTAssertFalse(encodedString.contains("#/foo"))
    }

    func test_dynamicReference_roundTripThroughDocument() throws {
        // A realistic recursive schema: BaseCategory is extended by
        // LocalizedCategory via `allOf` + `$dynamicAnchor`. Children point
        // back at the active category through `$dynamicRef`.
        let jsonString = """
        {
          "openapi": "3.1.0",
          "info": { "title": "test", "version": "1.0.0" },
          "paths": {},
          "components": {
            "schemas": {
              "BaseCategory": {
                "$dynamicAnchor": "category",
                "type": "object",
                "properties": {
                  "name": { "type": "string" },
                  "children": {
                    "type": "array",
                    "items": { "$dynamicRef": "#category" }
                  }
                }
              },
              "LocalizedCategory": {
                "$dynamicAnchor": "category",
                "allOf": [
                  { "$ref": "#/components/schemas/BaseCategory" },
                  {
                    "type": "object",
                    "properties": {
                      "displayName": { "type": "string" },
                      "locale": { "type": "string" }
                    }
                  }
                ]
              }
            }
          }
        }
        """

        let doc = try orderUnstableDecode(OpenAPI.Document.self, from: jsonString.data(using: .utf8)!)

        // The `$dynamicRef` keyword survives the decode intact.
        let base = doc.components.schemas["BaseCategory"]!
        let childrenItems = base.objectContext!.properties["children"]!.arrayContext!.items!
        XCTAssertTrue(childrenItems.isDynamicReference)
        XCTAssertEqual(childrenItems.dynamicReference?.absoluteString, "#category")

        // Round-trips back out.
        let reencoded = try orderUnstableEncode(doc)
        let redecoded = try orderUnstableDecode(OpenAPI.Document.self, from: reencoded)
        let redecodedItems = redecoded.components.schemas["BaseCategory"]!
            .objectContext!.properties["children"]!.arrayContext!.items!
        XCTAssertTrue(redecodedItems.isDynamicReference)
        XCTAssertEqual(redecodedItems.dynamicReference?.absoluteString, "#category")
    }

    // MARK: - Accessors / transformations

    func test_isDynamicReference_accessor() {
        let dyn = JSONSchema.dynamicReference(.anchor("x"))
        let ref = JSONSchema.reference(.component(named: "x"))
        let str = JSONSchema.string

        XCTAssertTrue(dyn.isDynamicReference)
        XCTAssertFalse(ref.isDynamicReference)
        XCTAssertFalse(str.isDynamicReference)

        XCTAssertNotNil(dyn.dynamicReference)
        XCTAssertNil(ref.dynamicReference)
        XCTAssertNil(str.dynamicReference)
    }

    func test_dynamicReference_optionalRequired() {
        let required = JSONSchema.dynamicReference(.anchor("x"))
        XCTAssertTrue(required.required)

        let optional = required.optionalSchemaObject()
        XCTAssertFalse(optional.required)
        XCTAssertTrue(optional.isDynamicReference)
    }

    func test_dynamicReference_withDescription() {
        let schema = JSONSchema.dynamicReference(.anchor("x"))
            .with(description: "a recursive node")

        XCTAssertEqual(schema.description, "a recursive node")
        XCTAssertTrue(schema.isDynamicReference)
    }

    // MARK: - Dereferencing

    func test_dereference_throwsOnDynamicReference() throws {
        // A `DereferencedJSONSchema` must not contain references. Until
        // dynamic-scope resolution lands (follow-up to #359), a `$dynamicRef`
        // cannot be inlined, so local dereferencing fails rather than
        // retaining the reference.
        let jsonString = """
        {
          "type": "object",
          "properties": {
            "item": { "$dynamicRef": "#category" }
          }
        }
        """

        let schema = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)

        XCTAssertThrowsError(try schema.dereferenced(in: .noComponents)) { error in
            let description = String(describing: error)
            XCTAssertTrue(description.contains("$dynamicRef"), "expected error to mention `$dynamicRef`, got: \(description)")
        }
    }
}
