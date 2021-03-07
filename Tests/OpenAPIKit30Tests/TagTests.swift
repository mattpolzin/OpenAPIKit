//
//  TagTests.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

import XCTest
import OpenAPIKit30

final class TagTests: XCTestCase {
    func test_init() {
        let t1 = OpenAPI.Tag(name: "hello")
        XCTAssertNil(t1.description)
        XCTAssertNil(t1.externalDocs)

        let t2 = OpenAPI.Tag(name: "hello", description: "world")
        XCTAssertEqual(t2.description, "world")
        XCTAssertNil(t2.externalDocs)

        let t3 = OpenAPI.Tag(
            name: "hello",
            description: "world",
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        XCTAssertEqual(t3.description, "world")
        XCTAssertEqual(t3.externalDocs, .init(url: URL(string: "http://google.com")!))
    }
}

// MARK: - Codable
extension TagTests {
    func test_onlyName_encode() throws {
        let tag = OpenAPI.Tag(name: "hello")
        let encodedTag = try orderUnstableTestStringFromEncoding(of: tag)

        assertJSONEquivalent(
            encodedTag,
            """
            {
              "name" : "hello"
            }
            """
        )
    }

    func test_onlyName_decode() throws {
        let tagData =
        """
        {
            "name": "hello"
        }
        """.data(using: .utf8)!

        let tag = try orderUnstableDecode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello"))
    }

    func test_nameAndDescription_encode() throws {
        let tag = OpenAPI.Tag(
            name: "hello",
            description: "world"
        )
        let encodedTag = try orderUnstableTestStringFromEncoding(of: tag)

        assertJSONEquivalent(
            encodedTag,
            """
            {
              "description" : "world",
              "name" : "hello"
            }
            """
        )
    }

    func test_nameAndDescription_decode() throws {
        let tagData =
        """
        {
            "name": "hello",
            "description": "world"
        }
        """.data(using: .utf8)!

        let tag = try orderUnstableDecode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello", description: "world"))
    }

    func test_allFields_encode() throws {
        let tag = OpenAPI.Tag(
            name: "hello",
            description: "world",
            externalDocs: .init(
                url: URL(string: "http://google.com")!
            ),
            vendorExtensions: ["x-specialFeature": false]
        )
        let encodedTag = try orderUnstableTestStringFromEncoding(of: tag)

        assertJSONEquivalent(
            encodedTag,
            """
            {
              "description" : "world",
              "externalDocs" : {
                "url" : "http:\\/\\/google.com"
              },
              "name" : "hello",
              "x-specialFeature" : false
            }
            """
        )
    }

    func test_allFields_decode() throws {
        let tagData =
        """
        {
            "name": "hello",
            "description": "world",
            "externalDocs": {
                "url": "http://google.com"
            },
            "x-specialFeature" : false
        }
        """.data(using: .utf8)!

        let tag = try orderUnstableDecode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(
            tag,
            OpenAPI.Tag(
                name: "hello",
                description: "world",
                externalDocs: .init(url: URL(string: "http://google.com")!),
                vendorExtensions: ["x-specialFeature": false]
            )
        )
    }
}
