//
//  ContentTests.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/5/19.
//

import Foundation
import XCTest
import OpenAPIKit

final class ContentTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Content(schema: .init(.file("hello.json#/world")))

        let _ = OpenAPI.Content(schema: .init(.string))
    }

    func test_contentMap() {
        let _: OpenAPI.Content.Map = [
            .json: .init(schema: .init(.string)),
            .xml: .init(schema: .init(.file("hello.json#/world"))),
            .form: .init(schema: .init(.object(properties: ["hello": .string])))
        ]
    }
}

// MARK: - Codable

extension ContentTests {
    func test_referenceContent_encode() {
        let content = OpenAPI.Content(schema: .init(.file("hello.json#/world")))
        let encodedContent = try! testStringFromEncoding(of: content)

        XCTAssertEqual(encodedContent,
"""
{
  "schema" : {
    "$ref" : "hello.json#\\/world"
  }
}
"""
                       )
    }

    func test_referenceContent_decode() {
        let contentData =
"""
{
  "schema" : {
    "$ref" : "hello.json#\\/world"
  }
}
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        XCTAssertEqual(content, OpenAPI.Content(schema: .init(.file("hello.json#/world"))))
    }

    func test_schemaContent_encode() {
        let content = OpenAPI.Content(schema: .init(.string))
        let encodedContent = try! testStringFromEncoding(of: content)

        XCTAssertEqual(encodedContent,
"""
{
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_schemaContent_decode() {
        let contentData =
"""
{
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        XCTAssertEqual(content, OpenAPI.Content(schema: .init(.string(required: false))))
    }
}
