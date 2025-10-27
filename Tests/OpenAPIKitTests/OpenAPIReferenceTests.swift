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
        let t1 = OpenAPI.Reference<JSONSchema>.component(named: "hello")
        XCTAssertEqual(t1.name, "hello")
        XCTAssertEqual(t1.absoluteString, "#/components/schemas/hello")
        XCTAssertNil(t1.summary)
        XCTAssertNil(t1.description)
        XCTAssertEqual(t1.jsonReference.absoluteString, "#/components/schemas/hello")

        let t2 = OpenAPI.Reference<JSONSchema>.external(URL(string: "hello.json#/hello/world")!)
        XCTAssertEqual(t2.name, "world")
        XCTAssertEqual(t2.absoluteString, "hello.json#/hello/world")
        XCTAssertNil(t2.summary)
        XCTAssertNil(t2.description)
        XCTAssertEqual(t2.jsonReference.absoluteString, "hello.json#/hello/world")

        let t3 = OpenAPI.Reference<JSONSchema>.internal(path: "/hello/there")
        XCTAssertEqual(t3.name, "there")
        XCTAssertEqual(t3.absoluteString, "#/hello/there")
        XCTAssertNil(t3.summary)
        XCTAssertNil(t3.description)
        XCTAssertEqual(t3.jsonReference.absoluteString, "#/hello/there")
    }

    func test_specialCharacterEscapes() {
        let t1 = OpenAPI.Reference<JSONSchema>.internal(path: "/~0hello~1world")
        XCTAssertEqual(t1.absoluteString, "#/~0hello~1world")
    }

    func test_componentPaths() {
        XCTAssertEqual(OpenAPI.Reference<JSONSchema>.component(named: "hello").absoluteString, "#/components/schemas/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Response>.component(named: "hello").absoluteString, "#/components/responses/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Parameter>.component(named: "hello").absoluteString, "#/components/parameters/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Example>.component(named: "hello").absoluteString, "#/components/examples/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Request>.component(named: "hello").absoluteString, "#/components/requestBodies/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Header>.component(named: "hello").absoluteString, "#/components/headers/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.SecurityScheme>.component(named: "hello").absoluteString, "#/components/securitySchemes/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.Callbacks>.component(named: "hello").absoluteString, "#/components/callbacks/hello")
        XCTAssertEqual(OpenAPI.Reference<OpenAPI.PathItem>.component(named: "hello").absoluteString, "#/components/pathItems/hello")
    }

    func test_summaryAndDescriptionOverrides() throws {
        let components = OpenAPI.Components(
            schemas: [
                "hello": .string(description: "description")
            ],
            responses: [
                "hello": .init(description: "description")
            ],
            parameters: [
                "hello": .path(name: "name", content: [:], description: "description")
            ],
            examples: [
                "hello": .init(summary: "summary", description: "description", value: .b(""))
            ],
            requestBodies: [
                "hello": .init(description: "description", content: [:])
            ],
            headers: [
                "hello": .init(schemaOrContent: .content([:]), description: "description")
            ],
            securitySchemes: [
                "hello": .init(type: .mutualTLS, description: "description")
            ],
            callbacks: [
                "hello": [.init(url: URL(string: "http://website.com")!): .pathItem(.init())]
            ],
            pathItems: [
                "hello": .init(summary: "summary", description: "description")
            ]
        )

        XCTAssertEqual(try OpenAPI.Reference<JSONSchema>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<JSONSchema>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Response>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Response>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Parameter>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Parameter>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Example>.component(named: "hello").dereferenced(in: components).summary, "summary")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Example>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Example>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).summary, "new sum")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Example>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Request>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Request>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Header>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.Header>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.SecurityScheme>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.SecurityScheme>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")

        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.PathItem>.component(named: "hello").dereferenced(in: components).summary, "summary")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.PathItem>.component(named: "hello").dereferenced(in: components).description, "description")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.PathItem>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).summary, "new sum")
        XCTAssertEqual(try OpenAPI.Reference<OpenAPI.PathItem>.component(named: "hello", summary: "new sum", description: "new desc").dereferenced(in: components).description, "new desc")
    }
}

// MARK: Codable
extension OpenAPIReferenceTests {
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
