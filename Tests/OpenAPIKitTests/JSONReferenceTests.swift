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

        let t3 = JSONReference<JSONSchema>.component(named: "hello")
        let t4 = JSONReference<JSONSchema>.internal(.component(name: "hello"))
        XCTAssertEqual(t3, t4)

        let _ = JSONReference<JSONSchema>.external(URL(string: "hello.json")!)

        let t5 = JSONReference<JSONSchema>.Reference("#/hello/world")
        let t6 = JSONReference<JSONSchema>.Reference(rawValue: "#/hello/world")
        XCTAssertEqual(t5, t6)

        let t18 = JSONReference<JSONSchema>.Reference("#/components/schemas/hello")
        let t19 = JSONReference<JSONSchema>.Reference.component(name: "hello")
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
        XCTAssertNil(JSONReference<JSONSchema>.Reference("/hello/world"))
        // Reference for components but mismatched component type
        XCTAssertNil(JSONReference<JSONSchema>.Reference("#/components/responses"))
        // Reference that incorrectly puts something nested too deeply
        XCTAssertNil(JSONReference<JSONSchema>.Reference("#/components/schemas/hello/world"))
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

        let t4 = JSONReference<JSONSchema>.Reference.component(name: "hello")
        XCTAssertEqual(t4.name, "hello")
        XCTAssertEqual(t4.rawValue, "#/components/schemas/hello")
        XCTAssertEqual(t4.description, "#/components/schemas/hello")

        let t5 = JSONReference<JSONSchema>.Reference.path("/hello/there")
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
        XCTAssertEqual(t1.stringValue, "~0hello~1world")
        XCTAssertEqual(t1.rawValue, "~0hello~1world")
    }
}

// MARK: Codable
extension JSONReferenceTests {
    func test_externalFileOnly_encode() throws {
        let test = ReferenceWrapper(reference: .external(URL(string: "hello.json")!))

        let encoded = try testStringFromEncoding(of: test)

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

        let decoded = try testDecoder.decode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .external(URL(string: "hello.json")!))
        )
    }

    func test_external_encode() throws {
        let test = ReferenceWrapper(reference: .external(URL(string: "hello.json#/hello/world")!))

        let encoded = try testStringFromEncoding(of: test)

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

        let decoded = try testDecoder.decode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .external(URL(string: "hello.json#/schemas/hello")!))
        )
    }

    func test_validComponent_encode() throws {
        let test = ReferenceWrapper(reference: .component(named: "hello"))

        let encoded = try testStringFromEncoding(of: test)

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

        let decoded = try testDecoder.decode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .component(named: "hello"))
        )
    }

    func test_nonComponentLocal_encode() throws {
        let test = ReferenceWrapper(reference: .internal(path: "/hello/world"))

        let encoded = try testStringFromEncoding(of: test)

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

        let decoded = try testDecoder.decode(ReferenceWrapper.self, from: test)

        XCTAssertEqual(
            decoded,
            ReferenceWrapper(reference: .internal(path: "/hello/world"))
        )
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

        XCTAssertThrowsError(try testDecoder.decode(ReferenceWrapper.self, from: test))
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

        XCTAssertThrowsError(try testDecoder.decode(ReferenceWrapper.self, from: test))
    }
}

// MARK: - Test Types
extension JSONReferenceTests {
    struct ReferenceWrapper: Codable, Equatable {
        let reference: JSONReference<JSONSchema>
    }
}
