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
        XCTAssertNil(t1.summary)
        XCTAssertNil(t1.description)
        XCTAssertNil(t1.externalDocs)
        XCTAssertEqual(t1.conditionalWarnings.count, 0)

        let t2 = OpenAPI.Tag(name: "hello", summary: "hi", description: "world")
        XCTAssertEqual(t2.summary, "hi")
        XCTAssertEqual(t2.description, "world")
        XCTAssertNil(t2.externalDocs)
        XCTAssertEqual(t2.conditionalWarnings.count, 1)

        let t3 = OpenAPI.Tag(
            name: "hello",
            description: "world",
            externalDocs: .init(url: URL(string: "http://google.com")!)
        )
        XCTAssertEqual(t3.description, "world")
        XCTAssertEqual(t3.externalDocs, .init(url: URL(string: "http://google.com")!))

        let t4 = OpenAPI.Tag(
            name: "tag",
            summary: "first",
            description: "orig"
        ).overriddenNonNil(description: "new")
            .overriddenNonNil(summary: "cool")
            .overriddenNonNil(description: nil) // no effect
        XCTAssertEqual(t4.summary, "cool")
        XCTAssertEqual(t4.description, "new")
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
        XCTAssertEqual(tag.conditionalWarnings.count, 0)
    }

    func test_nameAndSummary_encode() throws {
        let tag = OpenAPI.Tag(
            name: "hello",
            summary: "world"
        )
        let encodedTag = try orderUnstableTestStringFromEncoding(of: tag)

        assertJSONEquivalent(
            encodedTag,
            """
            {
              "name" : "hello",
              "summary" : "world"
            }
            """
        )
    }

    func test_nameAndSummary_decode() throws {
        let tagData =
        """
        {
            "name": "hello",
            "summary": "world"
        }
        """.data(using: .utf8)!

        let tag = try orderUnstableDecode(OpenAPI.Tag.self, from: tagData)

        XCTAssertEqual(tag, OpenAPI.Tag(name: "hello", summary: "world"))
        XCTAssertEqual(tag.conditionalWarnings.count, 1)
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
        XCTAssertEqual(tag.conditionalWarnings.count, 0)
    }

    func test_allFields_encode() throws {
        let tag = OpenAPI.Tag(
            name: "hello",
            summary: "sum",
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
              "summary" : "sum",
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
            "summary": "sum",
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
                summary: "sum",
                description: "world",
                externalDocs: .init(url: URL(string: "http://google.com")!),
                vendorExtensions: ["x-specialFeature": false]
            )
        )
        XCTAssertEqual(tag.conditionalWarnings.count, 1)
    }
}
