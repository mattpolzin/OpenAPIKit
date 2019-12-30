//
//  RequestTests.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import XCTest
import OpenAPIKit

final class RequestTests: XCTestCase {
    let simpleSchema = JSONSchema.object(
        properties: [
            "hello": .string
        ]
    )
    func test_init() {

        let _ = OpenAPI.Request(description: "A Request",
                                content: [:],
                                required: true)

        let _ = OpenAPI.Request(description: "A Request",
                                content: [
                                    .json: .init(schema: .init(simpleSchema))

            ],
                                required: false)

        let _ = OpenAPI.Request(content: [
            .xml: .init(schema: .init(simpleSchema))
            ])

        let _ = OpenAPI.Request(content: [
            .form: .init(schema: .init(simpleSchema))
            ])

        let _ = OpenAPI.Request(content: [
            .json: .init(schema: .init(.external("hello.json#/world")))
            ])
    }
}

// MARK: - Codable
extension RequestTests {
    func test_onlyEmptyContent_encode() {
        let content: OpenAPI.Content.Map = [:]
        let request = OpenAPI.Request(content: content)
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString, "{\n  \"content\" : {\n\n  }\n}")
    }

    func test_onlyEmptyContent_decode() {
        let requestData = #"{ "content": {} }"#.data(using: .utf8)!
        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [:]))
    }

    func test_onlyReferenceContent_encode() {
        let request = OpenAPI.Request(content: [
            .json: .init(schema: .init(.external("hello.json#/world")))
            ])
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "$ref" : "hello.json#\\/world"
      }
    }
  }
}
"""
        )
    }

    func test_onlyReferenceContent_decode() {
        let requestData = #"{ "content": { "application/json": { "schema": { "$ref": "hello.json#/world" } } } }"#.data(using: .utf8)!
        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [
            .json : .init(schema: .init(.external("hello.json#/world")))
            ]))
    }

    func test_onlySchemaContent_encode() {
        let schema = JSONSchema.object(
            properties: [
                "hello": .string
            ]
        )
        let request = OpenAPI.Request(content: [
            .json: .init(schema: .init(schema))
        ])
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "properties" : {
          "hello" : {
            "type" : "string"
          }
        },
        "required" : [
          "hello"
        ],
        "type" : "object"
      }
    }
  }
}
"""
                       )
    }

    func test_onlySchemaContent_decode() {
        let requestData = """
{
  "content": {
    "application/json": {
      "schema": {
        "type": "object",
        "properties": {
          "hello": { "type": "string" }
        }
      }
    }
  }
}
""".data(using: .utf8)!

        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [
            .json : .init(schema: .init(
                .object(required: false,
                        properties: ["hello": .string(required: false)])
                ))
            ]))
    }

    func test_withDescription_encode() {
        let request = OpenAPI.Request(description: "A request",
                                      content: [:])
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
"""
{
  "content" : {

  },
  "description" : "A request"
}
"""
                       )
    }

    func test_withDescription_decode() {
        let requestData =
"""
{
  "content" : {},
  "description" : "A request"
}
""".data(using: .utf8)!

        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(description: "A request",
                                                content: [:]))
    }

    func test_withRequired_encode() {
        let request = OpenAPI.Request(content: [:],
                                      required: true)
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
"""
{
  "content" : {

  },
  "required" : true
}
"""
                       )
    }

    func test_withRequired_decode() {
        let requestData =
"""
{
  "content" : {},
  "required" : true
}
""".data(using: .utf8)!

        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [:],
                                                required: true))
    }
}

// MARK: Other Content Types
extension RequestTests {
    func test_xml_onlySchemaContent_encode() {
        let schema = JSONSchema.object(
            properties: [
                "hello": .string
            ]
        )
        let request = OpenAPI.Request(content: [
            .xml: .init(schema: .init(schema))
            ])
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
                       """
{
  "content" : {
    "application\\/xml" : {
      "schema" : {
        "properties" : {
          "hello" : {
            "type" : "string"
          }
        },
        "required" : [
          "hello"
        ],
        "type" : "object"
      }
    }
  }
}
"""
        )
    }

    func test_xml_onlySchemaContent_decode() {
        let requestData = """
{
  "content": {
    "application/xml": {
      "schema": {
        "type": "object",
        "properties": {
          "hello": { "type": "string" }
        }
      }
    }
  }
}
""".data(using: .utf8)!

        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [
            .xml : .init(schema: .init(
                .object(required: false,
                        properties: ["hello": .string(required: false)])
                ))
            ]))
    }

    func test_form_onlySchemaContent_encode() {
        let schema = JSONSchema.object(
            properties: [
                "hello": .string
            ]
        )
        let request = OpenAPI.Request(content: [
            .form: .init(schema: .init(schema))
            ])
        let encodedString = try! testStringFromEncoding(of: request)

        XCTAssertEqual(encodedString,
                       """
{
  "content" : {
    "application\\/x-www-form-urlencoded" : {
      "schema" : {
        "properties" : {
          "hello" : {
            "type" : "string"
          }
        },
        "required" : [
          "hello"
        ],
        "type" : "object"
      }
    }
  }
}
"""
        )
    }

    func test_form_onlySchemaContent_decode() {
        let requestData = """
{
  "content": {
    "application/x-www-form-urlencoded": {
      "schema": {
        "type": "object",
        "properties": {
          "hello": { "type": "string" }
        }
      }
    }
  }
}
""".data(using: .utf8)!

        let request = try! testDecoder.decode(OpenAPI.Request.self, from: requestData)

        XCTAssertEqual(request, OpenAPI.Request(content: [
            .form : .init(schema: .init(
                .object(required: false,
                        properties: ["hello": .string(required: false)])
                ))
            ]))
    }
}
