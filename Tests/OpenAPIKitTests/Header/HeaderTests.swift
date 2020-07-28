//
//  HeaderTests.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

import XCTest
import OpenAPIKit

final class HeaderTests: XCTestCase {
    func test_init() {
        let contentMap: OpenAPI.Content.Map = [
            .json: .init(schema: .string)
        ]

        let t1 = OpenAPI.Header(schemaOrContent: .init(contentMap))
        XCTAssertFalse(t1.deprecated)
        XCTAssertNil(t1.description)
        XCTAssertFalse(t1.required)
        XCTAssertEqual(t1.schemaOrContent, .init(contentMap))

        let t2 = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        XCTAssertEqual(t2.schemaOrContent, .init(.header(.string)))

        let t3 = OpenAPI.Header(schema: .string)
        XCTAssertEqual(t3.schemaOrContent, .init(.header(.string)))

        let t4 = OpenAPI.Header(schemaReference: .internal(path: "/hello"))
        XCTAssertEqual(t4.schemaOrContent, .init(.header(schemaReference: .internal(path: "/hello"))))

        let t5 = OpenAPI.Header(content: contentMap)
        XCTAssertEqual(t5.schemaOrContent, .init(contentMap))

        let t6 = OpenAPI.Header(content: contentMap, description: "hello")
        XCTAssertEqual(t6.description, "hello")

        let t7 = OpenAPI.Header(content: contentMap, required: true)
        XCTAssertTrue(t7.required)

        let t8 = OpenAPI.Header(content: contentMap, deprecated: true)
        XCTAssertTrue(t8.deprecated)

        let t9 = OpenAPI.Header(schema: OpenAPI.Header.SchemaContext.header(.string))
        XCTAssertEqual(t9, t3)
    }

    func test_headerSchemaInits() {
        let t1 = OpenAPI.Header.SchemaContext.header(.string)
        XCTAssertEqual(t1.style, .default(for: .header))

        let t2 = OpenAPI.Header.SchemaContext.header(.string, examples: nil)
        XCTAssertEqual(t2.style, .default(for: .header))

        let t3 = OpenAPI.Header.SchemaContext.header(schemaReference: .external(URL(string: "hello.yml")!))
        XCTAssertEqual(t3.style, .default(for: .header))

        let t4 = OpenAPI.Header.SchemaContext.header(schemaReference: .external(URL(string: "hello.yml")!), examples: nil)
        XCTAssertEqual(t4.style, .default(for: .header))
    }
}

// MARK: - Codable
extension HeaderTests {
    func test_header_contentMap_encode() throws {
        let header = OpenAPI.Header(content: [
            .json: .init(schema: .string)
        ])

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  }
}
"""
        )
    }

    func test_header_contentMap_decode() throws {
        let headerData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  }
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(content: [
                .json: .init(schema: .string(required: false))
            ])
        )
    }

    func test_header_schema_encode() throws {
        let header = OpenAPI.Header(schema: .string)

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_header_schema_decode() throws {
        let headerData =
"""
{
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(schema: .string(required: false))
        )
    }

    func test_header_schema_withExntesion_encode() throws {
        let header = OpenAPI.Header(schema: .string, vendorExtensions: ["x-hello": "hi"])

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : "hi"
}
"""
        )
    }

    func test_header_schema_withExtension_decode() throws {
        let headerData =
"""
{
  "schema" : {
    "type" : "string"
  },
  "x-hello" : "hi"
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(schema: .string(required: false), vendorExtensions: ["x-hello": "hi"])
        )
    }

    func test_header_required_encode() throws {
        let header = OpenAPI.Header(
            content: [
                .json: .init(schema: .string)
            ],
            required: true
        )

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "required" : true
}
"""
        )
    }

    func test_header_required_decode() throws {
        let headerData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "required" : true
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(
                content: [
                    .json: .init(schema: .string(required: false))
                ],
                required: true
            )
        )
    }

    func test_header_withDescription_encode() throws {
        let header = OpenAPI.Header(
            content: [
                .json: .init(schema: .string)
            ],
            description: "hello"
        )

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "description" : "hello"
}
"""
        )
    }

    func test_header_withDescription_decode() throws {
        let headerData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "description" : "hello"
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(
                content: [
                    .json: .init(schema: .string(required: false))
                ],
                description: "hello"
            )
        )
    }

    func test_header_deprecated_encode() throws {
        let header = OpenAPI.Header(
            content: [
                .json: .init(schema: .string)
            ],
            deprecated: true
        )

        let headerEncoding = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(headerEncoding,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "deprecated" : true
}
"""
        )
    }

    func test_header_deprecated_decode() throws {
        let headerData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "deprecated" : true
}
""".data(using: .utf8)!
        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(
                content: [
                    .json: .init(schema: .string(required: false))
                ],
                deprecated: true
            )
        )
    }

    func test_header_withExample_encode() throws {
        let header = OpenAPI.Header(
            schema: .init(
                .string,
                style: .default(for: .header),
                example: "hello string"
            ),
            required: true
        )

        let encodedHeader = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(
            encodedHeader,
"""
{
  "example" : "hello string",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_header_withExample_decode() throws {
        let headerData =
"""
{
  "example" : "hello string",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(
                schema: .init(
                    .string(required: false),
                    style: .default(for: .header),
                    example: "hello string"
                ),
                required: true
            )
        )
    }

    func test_header_withStyle_encode() throws {
        let header = OpenAPI.Header(
            schema: .init(
                .array(items: .string),
                style: .pipeDelimited
            ),
            required: true
        )

        let encodedHeader = try orderUnstableTestStringFromEncoding(of: header)

        assertJSONEquivalent(
            encodedHeader,
"""
{
  "required" : true,
  "schema" : {
    "items" : {
      "type" : "string"
    },
    "type" : "array"
  },
  "style" : "pipeDelimited"
}
"""
        )
    }

    func test_header_withStyle_decode() throws {
        let headerData =
"""
{
  "required" : true,
  "schema" : {
    "items" : {
      "type" : "string"
    },
    "type" : "array"
  },
  "style" : "pipeDelimited"
}
""".data(using: .utf8)!

        let header = try orderUnstableDecode(OpenAPI.Header.self, from: headerData)

        XCTAssertEqual(
            header,
            OpenAPI.Header(
                schema: .init(
                    .array(required: false, items: .string(required: false)),
                    style: .pipeDelimited
                ),
                required: true
            )
        )
    }

    func test_header_errorForBothContentAndSchema_decode() {
        let headerData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Header.self, from: headerData))
    }
}
