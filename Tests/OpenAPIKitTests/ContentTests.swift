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
        let t1 = OpenAPI.Content(schema: .init(.external("hello.json#/world")))
        XCTAssertNotNil(t1.schema.a)
        XCTAssertNil(t1.schema.b)

        let t2 = OpenAPI.Content(schema: .init(.string))
        XCTAssertNotNil(t2.schema.b)
        XCTAssertNil(t2.schema.a)

        let t3 = OpenAPI.Content(schemaReference: .external("hello.json#/world"))
        XCTAssertNotNil(t3.schema.a)
        XCTAssertNil(t3.schema.b)

        let withExample = OpenAPI.Content(schema: .init(.string),
                                          example: "hello",
                                          encoding: [
                                            "json": .init()
            ])
        XCTAssertNotNil(withExample.example)
        XCTAssertNil(withExample.examples)

        let withExamples = OpenAPI.Content(schema: .init(.string),
                                           examples: [
                                            "hello": .b(.init(value: .init("world"))),
                                            "bbbb": .b(.init(value: .b("pick me"))),
                                            "aaaa": .b(.init(value: .a(URL(string: "http://google.com")!)))
        ])
        XCTAssertNotNil(withExamples.examples)
        XCTAssertEqual(withExamples.example?.value as? String, "pick me")

        let t4 = OpenAPI.Content(schemaReference: .external("hello.json#/world"),
                                examples: nil)
        XCTAssertNotNil(t4.schema.a)
        XCTAssertNil(t4.schema.b)

        let t5 = OpenAPI.Content(schema: .string,
                                examples: nil)
        XCTAssertNotNil(t5.schema.b)
        XCTAssertNil(t5.schema.a)

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
            .bmp: .init(schema: .init(.string(format: .binary))),
            .css: .init(schema: .init(.string)),
            .csv: .init(schema: .init(.string)),
            .form: .init(schema: .init(.object(properties: ["hello": .string]))),
            .html: .init(schema: .init(.string)),
            .javascript: .init(schema: .init(.string)),
            .jpg: .init(schema: .init(.string(format: .binary))),
            .json: .init(schema: .init(.string)),
            .jsonapi: .init(schema: .init(.string)),
            .mov: .init(schema: .init(.string(format: .binary))),
            .mp3: .init(schema: .init(.string(format: .binary))),
            .mp4: .init(schema: .init(.string(format: .binary))),
            .mpg: .init(schema: .init(.string(format: .binary))),
            .multipartForm: .init(schema: .init(.string)),
            .pdf: .init(schema: .init(.string)),
            .rar: .init(schema: .init(.integer)),
            .rtf: .init(schema: .init(.string)),
            .tar: .init(schema: .init(.boolean)),
            .tif: .init(schema: .init(.string(format: .binary))),
            .txt: .init(schema: .init(.number)),
            .xml: .init(schema: .init(.external("hello.json#/world"))),
            .yaml: .init(schema: .init(.string)),
            .zip: .init(schema: .init(.string))
        ]
    }
}

// MARK: - Codable
extension ContentTests {
    func test_referenceContent_encode() {
        let content = OpenAPI.Content(schema: .init(.external("hello.json#/world")))
        let encodedContent = try! testStringFromEncoding(of: content)

        assertJSONEquivalent(encodedContent,
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

        assertJSONEquivalent(encodedContent,
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
        let content = OpenAPI.Content(schema: .init(.object(properties: ["hello": .string])),
                                      example: [ "hello": "world" ])
        let encodedContent = try! testStringFromEncoding(of: content)

        assertJSONEquivalent(encodedContent,
"""
{
  "example" : {
    "hello" : "world"
  },
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
"""
        )
    }

    func test_exampleAndSchemaContent_decode() {
        let contentData =
"""
{
  "example" : {
    "hello" : "world"
  },
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
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        XCTAssertEqual(content.schema, .init(.object(required: false, properties: ["hello": .string])))

        XCTAssertEqual(content.example?.value as? [String: String], [ "hello": "world" ])
    }

    func test_examplesAndSchemaContent_encode() {
        let content = OpenAPI.Content(schema: .init(.object(properties: ["hello": .string])),
                                      examples: ["hello": .b(OpenAPI.Example(value: .init([ "hello": "world" ])))])
        let encodedContent = try! testStringFromEncoding(of: content)

        assertJSONEquivalent(encodedContent,
"""
{
  "examples" : {
    "hello" : {
      "value" : {
        "hello" : "world"
      }
    }
  },
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
"""
        )
    }

    func test_examplesAndSchemaContent_decode() {
        let contentData =
"""
{
  "examples" : {
    "hello": {
        "value": {
            "hello" : "world"
        }
    }
  },
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
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        XCTAssertEqual(content.schema, .init(.object(required: false, properties: ["hello": .string])))

        XCTAssertEqual(content.example?.value as? [String: String], [ "hello": "world" ])
        XCTAssertEqual(content.examples?["hello"]?.b?.value.b?.value as? [String: String], [ "hello": "world" ])
    }

    func test_decodeFailureForBothExampleAndExamples() {
        let contentData =
"""
{
  "examples" : {
    "hello": {
        "value": {
            "hello" : "world"
        }
    }
  },
  "example" : {
    "hello" : "world"
  },
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
""".data(using: .utf8)!
        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Content.self, from: contentData))
    }

    func test_encodingAndSchema_encode() {
        let content = OpenAPI.Content(schema: .init(.string),
                                      encoding: ["json": .init(contentType: .json)])
        let encodedContent = try! testStringFromEncoding(of: content)

        assertJSONEquivalent(encodedContent,
"""
{
  "encoding" : {
    "json" : {
      "contentType" : "application\\/json"
    }
  },
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_encodingAndSchema_decode() {
        let contentData =
"""
{
  "encoding" : {
    "json" : {
      "allowReserved" : false,
      "contentType" : "application\\/json"
    }
  },
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!
        let content = try! testDecoder.decode(OpenAPI.Content.self, from: contentData)

        XCTAssertEqual(content, OpenAPI.Content(schema: .init(.string(required: false)),
                                                encoding: ["json": .init(contentType: .json)]))
    }

    func test_vendorExtensions_encode() {
        let content = OpenAPI.Content(schema: .init(.string),
                                      vendorExtensions: [ "x-hello": [ "world": 123 ] ])

        let encodedContent = try! testStringFromEncoding(of: content)

        assertJSONEquivalent(encodedContent,
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

        assertJSONEquivalent(encodedContent,
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

    func test_nonStringKeyNonesenseDecodeFailure() {
        let contentData =
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : {
    "world" : 123
  },
  10: "hello"
}
""".data(using: .utf8)!
        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Content.self, from: contentData))
    }
}

// MARK: - Content.Encoding
extension ContentTests {
    func test_encodingInit() {
        let _ = OpenAPI.Content.Encoding()

        let _ = OpenAPI.Content.Encoding(contentType: .json)

        let _ = OpenAPI.Content.Encoding(headers: ["special": .a(.external("hello.yml"))])

        let _ = OpenAPI.Content.Encoding(allowReserved: true)

        let _ = OpenAPI.Content.Encoding(contentType: .form,
                                         headers: ["special": .a(.external("hello.yml"))],
                                         allowReserved: true)
        let _ = OpenAPI.Content.Encoding(contentType: .json,
                                         style: .form)
        let _ = OpenAPI.Content.Encoding(contentType: .json,
                                         style: .form,
                                         explode: true)
    }
}

extension ContentTests {
    func test_encoding_minimal_encode() throws {
        let encoding = OpenAPI.Content.Encoding()

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{

}
"""
        )
    }

    func test_encoding_minimal_decode() throws {
        let encodingData =
"""
{}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(encoding, OpenAPI.Content.Encoding())
    }

    func test_encoding_contentType_encode() throws {
        let encoding = OpenAPI.Content.Encoding(contentType: .csv)

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{
  "contentType" : "text\\/csv"
}
"""
        )
    }

    func test_encoding_contentType_decode() throws {
        let encodingData =
"""
{
    "contentType": "text/csv"
}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(encoding, OpenAPI.Content.Encoding(contentType: .csv))
    }

    func test_encoding_headers_encode() throws {
        let encoding = OpenAPI.Content.Encoding(headers: [
            "X-CustomThing": .init(OpenAPI.Header(schema: .string))
        ])

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{
  "headers" : {
    "X-CustomThing" : {
      "schema" : {
        "type" : "string"
      }
    }
  }
}
"""
        )
    }

    func test_encoding_headers_decode() throws {
        let encodingData =
"""
{
  "headers" : {
    "X-CustomThing" : {
      "schema" : {
        "type" : "string"
      }
    }
  }
}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(
            encoding,
            OpenAPI.Content.Encoding(headers: [
                "X-CustomThing": .init(OpenAPI.Header(schema: .string(required: false)))
            ])
        )
    }

    func test_encoding_style_encode() throws {
        let encoding = OpenAPI.Content.Encoding(style: .pipeDelimited)

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{
  "style" : "pipeDelimited"
}
"""
        )
    }

    func test_encoding_style_decode() throws {
        let encodingData =
"""
{
  "style" : "pipeDelimited"
}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(
            encoding,
            OpenAPI.Content.Encoding(style: .pipeDelimited)
        )
    }

    func test_encoding_explode_encode() throws {
        let encoding = OpenAPI.Content.Encoding(explode: false)

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{
  "explode" : false
}
"""
        )
    }

    func test_encoding_explode_decode() throws {
        let encodingData =
"""
{
  "explode" : false
}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(
            encoding,
            OpenAPI.Content.Encoding(explode: false)
        )
    }

    func test_encoding_allowReserved_encode() throws {
        let encoding = OpenAPI.Content.Encoding(allowReserved: true)

        let encodedEncoding = try! testStringFromEncoding(of: encoding)

        assertJSONEquivalent(encodedEncoding,
"""
{
  "allowReserved" : true
}
"""
        )
    }

    func test_encoding_allowReserved_decode() throws {
        let encodingData =
"""
{
  "allowReserved" : true
}
""".data(using: .utf8)!
        let encoding = try! testDecoder.decode(OpenAPI.Content.Encoding.self, from: encodingData)

        XCTAssertEqual(
            encoding,
            OpenAPI.Content.Encoding(allowReserved: true)
        )
    }
}
