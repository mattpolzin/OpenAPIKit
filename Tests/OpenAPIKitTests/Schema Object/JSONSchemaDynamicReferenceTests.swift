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

    // MARK: - Dereferencing (dynamic-scope resolution)

    func test_dereference_genericsInline() throws {
        // The JSON Schema "generics" pattern: a `$dynamicAnchor` lives in `$defs`
        // and the `$dynamicRef` target is a leaf (non-recursive) schema.
        // Dereferencing inlines the concrete target.
        let jsonString = """
        {
          "$defs": {
            "itemType": {
              "$dynamicAnchor": "T",
              "type": "string"
            },
            "other": { "type": "number" }
          },
          "type": "object",
          "properties": {
            "items": {
              "type": "array",
              "items": { "$dynamicRef": "#T" }
            }
          }
        }
        """

        let box = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)
        let dereferenced = try box.dereferenced(in: .noComponents)

        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        let items = try XCTUnwrap(objectContext.properties["items"])
        let itemsItems: DereferencedJSONSchema = try XCTUnwrap(items.arrayContext?.items)

        // The leaf `$defs.itemType` (`string`) was inlined through the dynamic ref.
        guard case .string = itemsItems else {
            XCTFail("expected dynamic ref to inline to .string, got \(itemsItems)")
            return
        }
    }

    func test_dereference_recursiveThrows() throws {
        // A self-referential schema: `Node` declares `$dynamicAnchor: node` and
        // its `next` points back at `#node`. Inlining would not terminate, so
        // dereferencing must throw (consistent with recursive static `$ref`).
        let jsonString = """
        {
          "$dynamicAnchor": "node",
          "type": "object",
          "properties": {
            "value": { "type": "string" },
            "next": { "$dynamicRef": "#node" }
          }
        }
        """

        let node = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)

        XCTAssertThrowsError(try node.dereferenced(in: .noComponents))
    }

    func test_dereference_unresolvableThrows() throws {
        // A `$dynamicRef` whose anchor is not declared anywhere in scope cannot
        // be resolved and must throw (rather than degrade to `any`/`unknown`).
        let jsonString = """
        {
          "type": "object",
          "properties": {
            "item": { "$dynamicRef": "#unmatched" }
          }
        }
        """

        let schema = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)

        XCTAssertThrowsError(try schema.dereferenced(in: .noComponents)) { error in
            let description = String(describing: error)
            XCTAssertTrue(description.contains("$dynamicRef"), "expected error to mention `$dynamicRef`, got: \(description)")
        }
    }

    func test_dereference_scopePropagatesAcrossRefBoundary() throws {
        // `Outer` references `Inner`. The dynamic anchor "leaf" lives in `Outer`'s
        // `$defs`; `Inner` contains the `$dynamicRef`. The dynamic scope must
        // travel across the `$ref` boundary so Inner's `$dynamicRef` resolves to
        // Outer's concrete leaf type (outermost anchor wins).
        let components = OpenAPI.Components(
            schemas: [
                "Outer": .reference(
                    .component(named: "Inner"),
                    .init(
                        defs: [
                            "L": .boolean(.init(dynamicAnchor: "leaf"))
                        ]
                    )
                ),
                "Inner": .object(
                    .init(),
                    .init(properties: [
                        "flag": .dynamicReference(.anchor("leaf"))
                    ])
                )
            ]
        )

        let outer = try XCTUnwrap(components.schemas["Outer"])
        let dereferenced = try outer.dereferenced(in: components)

        // Outer is a reference to Inner, so after dereferencing we see Inner's
        // object shape with `flag` resolved through the dynamic scope.
        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        let flag: DereferencedJSONSchema = try XCTUnwrap(objectContext.properties["flag"])

        // The dynamic ref resolved to Outer's `$defs.L` (.boolean) across the $ref.
        guard case .boolean = flag else {
            XCTFail("expected flag to resolve to Outer's `$defs.L` (.boolean) across the $ref, got \(flag)")
            return
        }
    }

    func test_dereference_optionalDescribedDynamicRef() throws {
        // A `$dynamicRef` that is optional (required: false) and carries a
        // description: both propagate to the inlined result, mirroring `$ref`.
        let item = JSONSchema.dynamicReference(.anchor("T"), required: false, description: "the item")
        let box = JSONSchema.object(
            .init(defs: ["T": .string(.init(dynamicAnchor: "T"), .init())]),
            .init(properties: ["item": item])
        )

        let dereferenced = try box.dereferenced(in: .noComponents)

        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        let resolved = try XCTUnwrap(objectContext.properties["item"])

        // Inlined to the leaf `.string`, with optionality and description preserved.
        guard case .string = resolved else {
            XCTFail("expected dynamic ref to inline to .string, got \(resolved)")
            return
        }
        XCTAssertFalse(resolved.required)
        XCTAssertEqual(resolved.description, "the item")
    }

    func test_dereference_nonAnchorDynamicRefThrows() throws {
        // A `$dynamicRef` whose target is a component path (not a plain anchor)
        // is not resolved via a dynamic anchor and throws.
        let jsonString = """
        {
          "type": "object",
          "properties": {
            "item": { "$dynamicRef": "#/components/schemas/Foo" }
          }
        }
        """

        let schema = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)

        XCTAssertThrowsError(try schema.dereferenced(in: .noComponents))
    }

    func test_dereference_siblingDynamicRefsResolveIndependently() throws {
        // Two sibling properties each holding `$dynamicRef "#T"` resolve
        // independently -- the cycle guard inserted for one must not leak to
        // the other (both inline to the same leaf type).
        let jsonString = """
        {
          "$defs": { "T": { "$dynamicAnchor": "T", "type": "string" } },
          "type": "object",
          "properties": {
            "a": { "$dynamicRef": "#T" },
            "b": { "$dynamicRef": "#T" }
          }
        }
        """

        let schema = try orderUnstableDecode(JSONSchema.self, from: jsonString.data(using: .utf8)!)
        let dereferenced = try schema.dereferenced(in: .noComponents)

        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        for key in ["a", "b"] {
            let resolved: DereferencedJSONSchema = try XCTUnwrap(objectContext.properties[key])
            guard case .string = resolved else {
                XCTFail("expected sibling `\(key)` to inline to .string, got \(resolved)")
                return
            }
        }
    }

    func test_dereference_optionalReferenceProperty() throws {
        // Covers the `.reference` optional (required: false) path threaded by
        // the scope-aware dereferencer: an optional `$ref` property dereferences
        // to an optional result.
        let components = OpenAPI.Components(schemas: [
            "Foo": .string,
            "Holder": .object(
                .init(),
                .init(properties: [
                    "opt": .reference(.component(named: "Foo"), .init(required: false))
                ])
            )
        ])

        let holder = try XCTUnwrap(components.schemas["Holder"])
        let dereferenced = try holder.dereferenced(in: components)

        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        let opt: DereferencedJSONSchema = try XCTUnwrap(objectContext.properties["opt"])
        XCTAssertFalse(opt.required)
    }

    func test_dereference_dynamicRefReachedViaRef() throws {
        // A `$ref` to a component that is itself a `$dynamicRef`: the component
        // name propagates (dereferencedFromComponentNamed) and the dynamicRef
        // resolves against the referencing schema's dynamic scope.
        let components = OpenAPI.Components(
            schemas: [
                "Wrapper": .object(
                    .init(defs: ["T": .string(.init(dynamicAnchor: "T"), .init())]),
                    .init(properties: [
                        "item": .reference(.component(named: "DynRef"))
                    ])
                ),
                "DynRef": .dynamicReference(.anchor("T"))
            ]
        )

        let wrapper = try XCTUnwrap(components.schemas["Wrapper"])
        let dereferenced = try wrapper.dereferenced(in: components)

        guard case .object(_, let objectContext) = dereferenced else {
            XCTFail("expected .object, got \(dereferenced)")
            return
        }
        let item: DereferencedJSONSchema = try XCTUnwrap(objectContext.properties["item"])

        // $ref DynRef -> DynRef is $dynamicRef #T -> resolves to Wrapper's $defs.T (.string).
        guard case .string = item else {
            XCTFail("expected item to resolve to .string via $ref -> $dynamicRef, got \(item)")
            return
        }
    }
}

#if ExternalLoading
extension JSONSchemaDynamicReferenceTests {
    func test_externalDeref_dynamicReference_external() async throws {
        // An external `$dynamicRef` is dereferenced through its underlying
        // `JSONReference` -- same path as `$ref`: fetch + convert to an
        // internal component reference.
        let schema = JSONSchema.dynamicReference(
            JSONDynamicReference(.external(.init(string: "./schema.json")!))
        )

        let (newSchema, components, messages) = try await schema.externallyDereferenced(with: JSONReferenceTests.SchemaLoader.self)

        XCTAssertTrue(newSchema.isDynamicReference)
        XCTAssertEqual(newSchema.dynamicReference?.name, "__schema_json")
        XCTAssertEqual(components, .init(schemas: ["__schema_json": .string]))
        XCTAssertEqual(messages, ["./schema.json"])
    }

    func test_externalDeref_dynamicReference_internal_noop() async throws {
        // An internal `$dynamicRef` (anchor) is not external; external
        // dereferencing leaves it unchanged.
        let schema = JSONSchema.dynamicReference(.anchor("node"))

        let (newSchema, components, messages) = try await schema.externallyDereferenced(with: JSONReferenceTests.SchemaLoader.self)

        XCTAssertTrue(newSchema.isDynamicReference)
        XCTAssertEqual(newSchema.dynamicReference?.absoluteString, "#node")
        XCTAssertTrue(components.schemas.isEmpty)
        XCTAssertEqual(messages, [])
    }
}
#endif
