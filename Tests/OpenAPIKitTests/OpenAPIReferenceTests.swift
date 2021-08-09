//
//  JSONReferenceTests.swift
//  
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import XCTest
import OpenAPIKit

// MARK: - OpenAPI.Reference
final class OpenAPIReferenceTests: XCTestCase {
    func test_initialization() {
        let t1 = OpenAPI.Reference<JSONSchema>.internal(path: "/hello")
        let t2 = OpenAPI.Reference<JSONSchema>.init(.internal(.path("/hello")))
        XCTAssertEqual(t1, t2)
        XCTAssertTrue(t1.isInternal)
        XCTAssertFalse(t1.isExternal)

        let t3 = OpenAPI.Reference<JSONSchema>.component(named: "hello")
        let t4 = OpenAPI.Reference<JSONSchema>.init(.internal(.component(name: "hello")))
        XCTAssertEqual(t3, t4)
        XCTAssertTrue(t3.isInternal)
        XCTAssertFalse(t3.isExternal)

        let externalTest = OpenAPI.Reference<JSONSchema>.external(URL(string: "hello.json")!)
        XCTAssertFalse(externalTest.isInternal)
        XCTAssertTrue(externalTest.isExternal)

        let withOtherProps = OpenAPI.Reference<JSONSchema>.init(.component(named: "hello"), summary: "summary", description: "description")
        XCTAssertTrue(withOtherProps.isInternal)
        XCTAssertEqual(withOtherProps.jsonReference, t4.jsonReference)
        XCTAssertEqual(withOtherProps.summary, "summary")
        XCTAssertEqual(withOtherProps.description, "description")
    }

    func test_stringValues() {
        #warning("TODO: rewrite as OpenAPI.Reference")
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
        #warning("TODO: rewrite as OpenAPI.Reference")
        let t1 = JSONReference<JSONSchema>.PathComponent("~0hello~1world")
        XCTAssertEqual(t1.description, "~hello/world")
        XCTAssertEqual(t1.stringValue, "~hello/world")
        XCTAssertEqual(t1.rawValue, "~0hello~1world")
    }

    func test_componentPaths() {
        #warning("TODO: rewrite as OpenAPI.Reference")
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
}

// MARK: Codable
extension OpenAPIReferenceTests {
    #warning("TODO: rewrite as OpenAPI.Reference")
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

    func test_overwriteDescription_encode() throws {
        let test = ReferenceWrapper(reference: .init(.component(named: "hello"), description: "hello world"))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "#\\/components\\/schemas\\/hello",
                "description" : "hello world"
              }
            }
            """
        )
    }

    func test_overwiteDescription_decode() throws {
        let test =
            """
        {
            "reference" : {
                "$ref": "#/components/schemas/hello",
                "description": "hello world"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .init(.component(named: "hello"), description: "hello world"))
        )
    }

    func test_overwriteSummary_encode() throws {
        let test = ReferenceWrapper(reference: .init(.component(named: "hello"), summary: "hello world"))

        let encoded = try orderUnstableTestStringFromEncoding(of: test)

        assertJSONEquivalent(
            encoded,
            """
            {
              "reference" : {
                "$ref" : "#\\/components\\/schemas\\/hello",
                "summary" : "hello world"
              }
            }
            """
        )
    }

    func test_overwiteSummary_decode() throws {
        let test =
            """
        {
            "reference" : {
                "$ref": "#/components/schemas/hello",
                "summary": "hello world"
            }
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .init(.component(named: "hello"), summary: "hello world"))
        )
    }
    
}

// MARK: - Test Types
extension OpenAPIReferenceTests {
    struct ReferenceWrapper: Codable, Equatable {
        let reference: OpenAPI.Reference<JSONSchema>
    }
}
