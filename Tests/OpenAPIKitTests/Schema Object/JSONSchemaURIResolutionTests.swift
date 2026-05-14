#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import OpenAPIKit
import XCTest

final class JSONSchemaURIResolutionTests: XCTestCase {
    private func jsonData(_ string: String) -> Data {
        string.data(using: .utf8)!
    }

    func test_schemaBaseURIResolvesIDAgainstParentBaseURI() {
        let schema = JSONSchema.string(
            .init(id: URL(string: "schemas/user.yaml")),
            .init()
        )

        XCTAssertEqual(schema.id, URL(string: "schemas/user.yaml"))
        XCTAssertEqual(
            schema.baseURI(relativeTo: URL(string: "https://example.com/root/openapi.yaml")!),
            URL(string: "https://example.com/root/schemas/user.yaml")!
        )
    }

    func test_schemaBaseURIFallsBackToParentBaseURIWithoutIdentifier() {
        let schema = JSONSchema.string

        XCTAssertEqual(
            schema.baseURI(relativeTo: URL(string: "https://example.com/root/openapi.yaml")!),
            URL(string: "https://example.com/root/openapi.yaml")!
        )
    }

    func test_schemaWithIDAssignsIdentifierToSchema() {
        let schema = JSONSchema.string.with(id: URL(string: "schemas/user.yaml")!)

        XCTAssertEqual(schema.id, URL(string: "schemas/user.yaml"))
    }

    func test_schemaWithIDSupportsAllSchemaKinds() {
        let identifier = URL(string: "schemas/shared.yaml")!
        let nestedString = JSONSchema.string(.init(), .init())
        let schemas: [JSONSchema] = [
            .null(),
            .boolean(.init()),
            .number(.init(), .init()),
            .integer(.init(), .init()),
            .string(.init(), .init()),
            .object(.init(), .init(properties: [:])),
            .array(.init(), .init(items: nestedString)),
            .all(of: [nestedString]),
            .one(of: [nestedString]),
            .any(of: [nestedString]),
            .not(nestedString),
            .reference(.component(named: "User")),
            .fragment(.init())
        ]

        for schema in schemas {
            XCTAssertEqual(schema.with(id: identifier).id, identifier)
        }
    }

    func test_schemaIDDecodesForReferenceSchema() throws {
        let decoded = try orderUnstableDecode(
            JSONSchema.self,
            from: jsonData(
                """
            {
              "$id" : "schemas/user.yaml",
              "$ref" : "#/components/schemas/User"
            }
            """
            )
        )

        XCTAssertEqual(decoded.id, URL(string: "schemas/user.yaml"))
    }

    func test_schemaIDDecodesForTypedSchema() throws {
        let decoded = try orderUnstableDecode(
            JSONSchema.self,
            from: jsonData(
                """
            {
              "$id" : "schemas/user.yaml",
              "type" : "string"
            }
            """
            )
        )

        XCTAssertEqual(decoded.id, URL(string: "schemas/user.yaml"))
    }

    func test_schemaIDDecodesForComposedSchemas() throws {
        let payloads = [
            """
            {
              "$id" : "schemas/all.yaml",
              "allOf" : [
                { "type" : "string" }
              ]
            }
            """,
            """
            {
              "$id" : "schemas/any.yaml",
              "anyOf" : [
                { "type" : "string" }
              ]
            }
            """,
            """
            {
              "$id" : "schemas/one.yaml",
              "oneOf" : [
                { "type" : "string" }
              ]
            }
            """,
            """
            {
              "$id" : "schemas/not.yaml",
              "not" : {
                "type" : "string"
              }
            }
            """
        ]

        let expectedIDs = [
            URL(string: "schemas/all.yaml"),
            URL(string: "schemas/any.yaml"),
            URL(string: "schemas/one.yaml"),
            URL(string: "schemas/not.yaml")
        ]

        for (payload, expectedID) in zip(payloads, expectedIDs) {
            let decoded = try orderUnstableDecode(JSONSchema.self, from: jsonData(payload))
            XCTAssertEqual(decoded.id, expectedID)
        }
    }

    func test_schemaIDRoundTripsThroughEncoding() throws {
        let schema = JSONSchema.string(
            .init(id: URL(string: "schemas/user.yaml")),
            .init()
        )

        let encoded = try orderUnstableTestStringFromEncoding(of: schema)

        assertJSONEquivalent(
            encoded,
            """
            {
              "$id" : "schemas\\/user.yaml",
              "type" : "string"
            }
            """
        )
    }
}
