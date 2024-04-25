//
//  JSONReferenceTests.swift
//  
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import XCTest
import OpenAPIKit

// MARK: - JSONReference
final class JSONReferenceTests: XCTestCase {
    func test_initialization() {
        let t1 = JSONReference<JSONSchema>.internal(path: "/hello")
        let t2 = JSONReference<JSONSchema>.internal(.path("/hello"))
        XCTAssertEqual(t1, t2)
        XCTAssertTrue(t1.isInternal)
        XCTAssertFalse(t1.isExternal)
        XCTAssertEqual(t1.internalValue, .init(rawValue: "/hello"))
        XCTAssertNil(t1.externalValue)

        let t3 = JSONReference<JSONSchema>.component(named: "hello")
        let t4 = JSONReference<JSONSchema>.internal(.component(name: "hello"))
        XCTAssertEqual(t3, t4)
        XCTAssertTrue(t3.isInternal)
        XCTAssertFalse(t3.isExternal)

        let externalTest = JSONReference<JSONSchema>.external(URL(string: "hello.json")!)
        XCTAssertFalse(externalTest.isInternal)
        XCTAssertTrue(externalTest.isExternal)
        XCTAssertNil(externalTest.internalValue)
        XCTAssertEqual(externalTest.externalValue, URL(string: "hello.json"))

        let t5 = JSONReference<JSONSchema>.InternalReference("#/hello/world")
        let t6 = JSONReference<JSONSchema>.InternalReference(rawValue: "#/hello/world")
        XCTAssertEqual(t5, t6)

        let t18 = JSONReference<JSONSchema>.InternalReference("#/components/schemas/hello")
        let t19 = JSONReference<JSONSchema>.InternalReference.component(name: "hello")
        XCTAssertEqual(t18, t19)

        let t7: JSONReference<JSONSchema>.Path = [
            "hello",
            "world"
        ]
        let t8 = JSONReference<JSONSchema>.Path("/hello/world")
        let t9 = JSONReference<JSONSchema>.Path(rawValue: "/hello/world")
        let t10: JSONReference<JSONSchema>.Path = "/hello/world"
        XCTAssertEqual(t7, t8)
        XCTAssertEqual(t8, t9)
        XCTAssertEqual(t9, t10)

        let t11 = JSONReference<JSONSchema>.PathComponent("hello")
        let t12: JSONReference<JSONSchema>.PathComponent = "hello"
        let t13 = JSONReference<JSONSchema>.PathComponent(rawValue: "hello")
        let t14 = JSONReference<JSONSchema>.PathComponent(stringValue: "hello")
        let t15 = JSONReference<JSONSchema>.PathComponent.property(named: "hello")
        XCTAssertEqual(t11, t12)
        XCTAssertEqual(t12, t13)
        XCTAssertEqual(t13, t14)
        XCTAssertEqual(t14, t15)

        let t16 = JSONReference<JSONSchema>.PathComponent(intValue: 10)
        let t17 = JSONReference<JSONSchema>.PathComponent.index(10)
        XCTAssertEqual(t16, t17)

        // Reference missing '#'
        XCTAssertNil(JSONReference<JSONSchema>.InternalReference("/hello/world"))
        // Reference for components but mismatched component type
        XCTAssertNil(JSONReference<JSONSchema>.InternalReference("#/components/responses"))
        // Reference that incorrectly puts something nested too deeply
        XCTAssertNil(JSONReference<JSONSchema>.InternalReference("#/components/schemas/hello/world"))
    }

    func test_stringValues() {
        let t1 = JSONReference<JSONSchema>.internal(.component(name: "hello"))
        XCTAssertEqual(t1.name, "hello")
        XCTAssertEqual(t1.absoluteString, "#/components/schemas/hello")

        let t2 = JSONReference<JSONSchema>.external(URL(string: "hello.json#/hello/world")!)
        XCTAssertEqual(t2.name, "world")
        XCTAssertEqual(t2.absoluteString, "hello.json#/hello/world")

        let t3 = JSONReference<JSONSchema>.internal(.path("/hello/there"))
        XCTAssertEqual(t3.name, "there")
        XCTAssertEqual(t3.absoluteString, "#/hello/there")

        let t4 = JSONReference<JSONSchema>.InternalReference.component(name: "hello")
        XCTAssertEqual(t4.name, "hello")
        XCTAssertEqual(t4.rawValue, "#/components/schemas/hello")
        XCTAssertEqual(t4.description, "#/components/schemas/hello")

        let t5 = JSONReference<JSONSchema>.InternalReference.path("/hello/there")
        XCTAssertEqual(t5.name, "there")
        XCTAssertEqual(t5.rawValue, "#/hello/there")
        XCTAssertEqual(t5.description, "#/hello/there")

        let t6 = JSONReference<JSONSchema>.Path("/hello/there")
        XCTAssertEqual(t6.components, ["hello", "there"])
        XCTAssertEqual(t6.rawValue, "/hello/there")
        XCTAssertEqual(t6.description, "/hello/there")

        let t7 = JSONReference<JSONSchema>.PathComponent.property(named: "hi")
        XCTAssertEqual(t7.rawValue, "hi")
        XCTAssertEqual(t7.description, "hi")
        XCTAssertEqual(t7.stringValue, "hi")
        XCTAssertNil(t7.intValue)

        let t8 = JSONReference<JSONSchema>.PathComponent.index(2)
        XCTAssertEqual(t8.rawValue, "2")
        XCTAssertEqual(t8.description, "2")
        XCTAssertEqual(t8.stringValue, "2")
        XCTAssertEqual(t8.intValue, 2)
    }

    func test_specialCharacterEscapes() {
        let t1 = JSONReference<JSONSchema>.PathComponent("~0hello~1world")
        XCTAssertEqual(t1.description, "~hello/world")
        XCTAssertEqual(t1.stringValue, "~hello/world")
        XCTAssertEqual(t1.rawValue, "~0hello~1world")
    }

    func test_componentPaths() {
        XCTAssertEqual(JSONReference<JSONSchema>.component(named: "hello").absoluteString, "#/components/schemas/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Response>.component(named: "hello").absoluteString, "#/components/responses/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Parameter>.component(named: "hello").absoluteString, "#/components/parameters/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Example>.component(named: "hello").absoluteString, "#/components/examples/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Request>.component(named: "hello").absoluteString, "#/components/requestBodies/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Header>.component(named: "hello").absoluteString, "#/components/headers/hello")
        XCTAssertEqual(JSONReference<OpenAPI.SecurityScheme>.component(named: "hello").absoluteString, "#/components/securitySchemes/hello")
        XCTAssertEqual(JSONReference<OpenAPI.Callbacks>.component(named: "hello").absoluteString, "#/components/callbacks/hello")
        XCTAssertEqual(JSONReference<OpenAPI.PathItem>.component(named: "hello").absoluteString, "#/components/pathItems/hello")
    }

    func test_toOpenAPIReference() {
        let t1 = JSONReference<JSONSchema>.component(named: "hello")
        let t2 = JSONReference<OpenAPI.Response>.component(named: "hello")
        let t3 = JSONReference<OpenAPI.Parameter>.component(named: "hello")
        let t4 = JSONReference<OpenAPI.Example>.component(named: "hello")
        let t5 = JSONReference<OpenAPI.Request>.component(named: "hello")
        let t6 = JSONReference<OpenAPI.Header>.component(named: "hello")
        let t7 = JSONReference<OpenAPI.SecurityScheme>.component(named: "hello")
        let t8 = JSONReference<OpenAPI.Callbacks>.component(named: "hello")
        let t9 = JSONReference<OpenAPI.PathItem>.component(named: "hello")

        XCTAssertEqual(t1.openAPIReference().jsonReference, t1)
        XCTAssertEqual(t2.openAPIReference().jsonReference, t2)
        XCTAssertEqual(t3.openAPIReference().jsonReference, t3)
        XCTAssertEqual(t4.openAPIReference().jsonReference, t4)
        XCTAssertEqual(t5.openAPIReference().jsonReference, t5)
        XCTAssertEqual(t6.openAPIReference().jsonReference, t6)
        XCTAssertEqual(t7.openAPIReference().jsonReference, t7)
        XCTAssertEqual(t8.openAPIReference().jsonReference, t8)
        XCTAssertEqual(t9.openAPIReference().jsonReference, t9)

        XCTAssertNil(t1.openAPIReference().description)
        XCTAssertNil(t2.openAPIReference().description)
        XCTAssertNil(t3.openAPIReference().description)
        XCTAssertNil(t4.openAPIReference().description)
        XCTAssertNil(t5.openAPIReference().description)
        XCTAssertNil(t6.openAPIReference().description)
        XCTAssertNil(t7.openAPIReference().description)
        XCTAssertNil(t8.openAPIReference().description)
        XCTAssertNil(t9.openAPIReference().description)

        XCTAssertEqual(t1.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t2.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t3.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t4.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t5.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t6.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t7.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t8.openAPIReference(withDescription: "hi").description, "hi")
        XCTAssertEqual(t9.openAPIReference(withDescription: "hi").description, "hi")

        // test dynamic member lookup:
        XCTAssertEqual(t1.openAPIReference().internalValue, .component(name: "hello"))

    }
}

// MARK: Codable
extension JSONReferenceTests {
    func test_externalFileOnly_encode() throws {
        let test = ReferenceWrapper(reference: .external(URL(string: "hello.json")!))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "hello.json"
              }
            }
            """
        )
    }

    func test_externalFileOnly_decode() throws {
        let test =
        """
        {
            "reference" : {
                "$ref": "hello.json"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .external(URL(string: "hello.json")!))
        )
    }

    func test_external_encode() throws {
        let test = ReferenceWrapper(reference: .external(URL(string: "hello.json#/hello/world")!))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "hello.json#\\/hello\\/world"
              }
            }
            """
        )
    }

    func test_external_decode() throws {
        let test =
        """
        {
            "reference" : {
                "$ref": "hello.json#/schemas/hello"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .external(URL(string: "hello.json#/schemas/hello")!))
        )
    }

    func test_validComponent_encode() throws {
        let test = ReferenceWrapper(reference: .component(named: "hello"))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "#\\/components\\/schemas\\/hello"
              }
            }
            """
        )
    }

    func test_validComponent_decode() throws {
        let test =
        """
        {
            "reference" : {
                "$ref": "#/components/schemas/hello"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .component(named: "hello"))
        )
    }

    func test_nonComponentLocal_encode() throws {
        let test = ReferenceWrapper(reference: .internal(path: "/hello/world"))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "#\\/hello\\/world"
              }
            }
            """
        )
    }

    func test_nonComponentLocal_decode() throws {
        let test =
        """
        {
            "reference" : {
                "$ref": "#/hello/world"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .internal(path: "/hello/world"))
        )
    }

    func test_nonComponentSpecialCharacterLocal_encode() throws {
        let test = ReferenceWrapper(reference: .internal(path: "/hello~1to/the~0~1world"))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "#\\/hello~1to\\/the~0~1world"
              }
            }
            """
        )
    }

    func test_nonComponentSpecialCharacterLocal_decode() throws {
        let test =
        """
        {
            "reference" : {
                "$ref": "#/hello~1to/the~0~1world"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .internal(path: "/hello~1to/the~0~1world"))
        )
        XCTAssertEqual(decoded.reference.name, "the~/world")
    }

    func test_invalidComponentFailure_decode() {
        let test =
        """
        {
            "reference" : {
                "$ref": "#/components/wrongType/hello"
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(ReferenceWrapper.self, from: test))
    }

    func test_emptyStringFailure_decode() {
        let test =
        """
        {
            "reference" : {
                "$ref": ""
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(ReferenceWrapper.self, from: test))
    }
}

// MARK: - External Dereferencing
extension JSONReferenceTests {
    func test_externalDerefNoFragment() async throws {
        let reference: JSONReference<JSONSchema> = .external(.init(string: "./schema.json")!)

        let (newReference, components, messages) = try await reference.externallyDereferenced(with: SchemaLoader.self)
        
        XCTAssertEqual(newReference, .component(named: "__schema_json"))
        XCTAssertEqual(components, .init(schemas: ["__schema_json": .string]))
        XCTAssertEqual(messages, ["./schema.json"])
    }

    func test_externalDerefFragment() async throws {
        let reference: JSONReference<JSONSchema> = .external(.init(string: "./schema.json#/test")!)

        let (newReference, components, messages) = try await reference.externallyDereferenced(with: SchemaLoader.self)
        
        XCTAssertEqual(newReference, .component(named: "__schema_json__test"))
        XCTAssertEqual(components, .init(schemas: ["__schema_json__test": .string]))
        XCTAssertEqual(messages, ["./schema.json#/test"])
    }

    func test_externalDerefExternalComponents() async throws {
        let reference: JSONReference<JSONSchema> = .external(.init(string: "./schema.json#/components/schemas/test")!)

        let (newReference, components, messages) = try await reference.externallyDereferenced(with: SchemaLoader.self)
        
        XCTAssertEqual(newReference, .component(named: "__schema_json__components_schemas_test"))
        XCTAssertEqual(components, .init(schemas: ["__schema_json__components_schemas_test": .string]))
        XCTAssertEqual(messages, ["./schema.json#/components/schemas/test"])
    }
}

// MARK: - Test Types
extension JSONReferenceTests {
    struct ReferenceWrapper: Codable, Equatable {
        let reference: JSONReference<JSONSchema>
    }

    struct SchemaLoader: ExternalLoader {
        static func load<T: Decodable>(_ url: URL) -> (T, [String]) {
            return (JSONSchema.string as! T, [url.absoluteString])
        }

        static func componentKey<T>(type: T.Type, at url: URL) throws -> OpenAPI.ComponentKey {
            return try .forceInit(rawValue: url.absoluteString
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "#", with: "_")
                .replacingOccurrences(of: ".", with: "_"))
        }
    }
}
