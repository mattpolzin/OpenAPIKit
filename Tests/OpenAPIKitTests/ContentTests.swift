//
//  ContentTests.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/5/19.
//

import Foundation
import XCTest
import OpenAPIKit
import AnyCodable

final class ContentTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Content(schema: .init(.external("hello.json#/world")))

        let _ = OpenAPI.Content(schema: .init(.string))

        let _ = OpenAPI.Content(schema: .init(.string),
                                example: "hello",
                                encoding: [
                                    "json": .init()
            ])

        let _ = OpenAPI.Content(schema: .init(.string),
                                example: nil,
                                encoding: [
                                    "hello": .init(contentType: .json,
                                                   headers: [
                                                    "world": .init(OpenAPI.Header(schemaOrContent: .init(.init(.string))))
                                        ],
                                                   allowReserved: true)
            ])
    }

    func test_contentMap() {
        let _: OpenAPI.Content.Map = [
            .json: .init(schema: .init(.string)),
            .xml: .init(schema: .init(.external("hello.json#/world"))),
            .form: .init(schema: .init(.object(properties: ["hello": .string])))
        ]
    }

    func test_encodingInit() {
        let _ = OpenAPI.Content.Encoding()

        let _ = OpenAPI.Content.Encoding(contentType: .json)

        let _ = OpenAPI.Content.Encoding(headers: ["special": .b(.external("hello.yml"))])

        let _ = OpenAPI.Content.Encoding(allowReserved: true)

        let _ = OpenAPI.Content.Encoding(contentType: .form,
                                         headers: ["special": .b(.external("hello.yml"))], allowReserved: true)
    }
}

// MARK: - Codable
@available(OSX 10.13, *)
extension ContentTests {
    func test_referenceContent_encode() {
        let content = OpenAPI.Content(schema: .init(.external("hello.json#/world")))
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

        XCTAssertEqual(content, OpenAPI.Content(schema: .init(.external("hello.json#/world"))))
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

    func test_exampleAndSchemaContent_encode() {
        // TODO: write test
    }

    func test_exampleAndSchemaContent_decode() {
        // TODO: write test
    }

    func test_encodingAndSchema_encode() {
        // TODO: write test
    }

    func test_encodingAndSchema_decode() {
        // TODO: write test
    }

    func test_vendorExtensions_encode() {
        let content = OpenAPI.Content(schema: .init(.string),
                                      vendorExtensions: [ "x-hello": [ "world": 123 ] ])

        let encodedContent = try! testStringFromEncoding(of: content)

        XCTAssertEqual(encodedContent,
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : {
    "world" : 123
  }
}
"""
        )
    }

    func test_vendorExtensions_encode_fixKey() {
        let content = OpenAPI.Content(schema: .init(.string),
                                      vendorExtensions: [ "hello": [ "world": 123 ] ])

        let encodedContent = try! testStringFromEncoding(of: content)

        XCTAssertEqual(encodedContent,
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : {
    "world" : 123
  }
}
"""
        )
    }

    func test_vendorExtensions_decode() {
        let contentData =
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : {
    "world" : 123
  }
}
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        let contentToMatch = OpenAPI.Content(schema: .init(.string(required: false)),
                                             vendorExtensions: ["x-hello": AnyCodable(["world": 123])])

        // needs to be broken down due to difficulties with equality comparing of AnyCodable
        // created from code with a semantically equivalent AnyCodable from Data.
        XCTAssertEqual(content.schema, contentToMatch.schema)
        XCTAssertEqual(content.vendorExtensions.keys, contentToMatch.vendorExtensions.keys)
        XCTAssertEqual(content.vendorExtensions["x-hello"]?.value as? [String: Int], contentToMatch.vendorExtensions["x-hello"]?.value as? [String: Int]?)
    }
}

// MARK: Content.Encoding
@available(OSX 10.13, *)
extension ContentTests {
    // TODO: write tests
}
