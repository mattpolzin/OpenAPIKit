//
//  TagTests.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

import XCTest
import OpenAPIKit

final class TagTests: XCTestCase {
    func test_init() {
        let t1 = OpenAPI.Tag(name: "hello")
        XCTAssertNil(t1.description)
        XCTAssertNil(t1.externalDocs)

        let t2 = OpenAPI.Tag(name: "hello", description: "world")
        XCTAssertEqual(t2.description, "world")
        XCTAssertNil(t2.externalDocs)

        let t3 = OpenAPI.Tag(name: "hello",
                             description: "world",
                             externalDocs: .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(t3.description, "world")
        XCTAssertEqual(t3.externalDocs, .init(url: URL(string: "http://google.com")!))
    }
}

// MARK: - Codable
extension TagTests {
    func test_onlyName_encode() {
        let tag = OpenAPI.Tag(name: "hello")
        let encodedTag = try! testStringFromEncoding(of: tag)

        assertJSONEquivalent(encodedTag,
"""
{
  "name" : "hello"
}
"""
        )
    }

    func test_onlyName_decode() {
        let tagData =
"""
{
    "name": "hello"
}
""".data(using: .utf8)!
        let tag = try! testDecoder.decode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello"))
    }

    func test_nameAndDescription_encode() {
        let tag = OpenAPI.Tag(name: "hello",
                              description: "world")
        let encodedTag = try! testStringFromEncoding(of: tag)

        assertJSONEquivalent(encodedTag,
"""
{
  "description" : "world",
  "name" : "hello"
}
"""
        )
    }

    func test_nameAndDescription_decode() {
        let tagData =
"""
{
    "name": "hello",
    "description": "world"
}
""".data(using: .utf8)!
        let tag = try! testDecoder.decode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello", description: "world"))
    }

    func test_allFields_encode() {
        let tag = OpenAPI.Tag(name: "hello",
                              description: "world",
                              externalDocs: .init(url: URL(string: "http://google.com")!))
        let encodedTag = try! testStringFromEncoding(of: tag)

        assertJSONEquivalent(encodedTag,
"""
{
  "description" : "world",
  "externalDocs" : {
    "url" : "http:\\/\\/google.com"
  },
  "name" : "hello"
}
"""
        )
    }

    func test_allFields_decode() {
        let tagData =
"""
{
    "name": "hello",
    "description": "world",
    "externalDocs": {
        "url": "http://google.com"
    }
}
""".data(using: .utf8)!
        let tag = try! testDecoder.decode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello",
                                        description: "world",
                                        externalDocs: .init(url: URL(string: "http://google.com")!)))
    }
}
