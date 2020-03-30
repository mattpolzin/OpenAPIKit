//
//  ParameterTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ParameterTests: XCTestCase {
    func test_initialize() {
        let t1 = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie(required: true),
            schemaOrContent: .init([.json: OpenAPI.Content(schema: .string)]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t1.required)

        let t2 = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie(required: true),
            schemaOrContent: .content([.json: OpenAPI.Content(schema: .string)]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t2.deprecated)
        XCTAssertEqual(t1, t2)

        let t4 = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie(required: false),
            schema: .init(.string, style: .default(for: .cookie)),
            description: "hi",
            deprecated: false
        )
        XCTAssertFalse(t4.required)

        let t5 = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie,
            schema: .string
        )
        XCTAssertFalse(t5.deprecated)

        let t6 = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie,
            schemaOrContent: .schema(.init(.string, style: .default(for: .cookie)))
        )
        XCTAssertEqual(t5, t6)

        let _ = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie,
            schemaReference: .component( named: "hello")
        )

        let _ = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie,
            content: [.json: OpenAPI.Content(schema: .string)]
        )
    }

    func test_parameterArray() {
        let t1: OpenAPI.PathItem.Parameter.Array = [
            .parameter(OpenAPI.PathItem.Parameter(name: "hello", parameterLocation: .cookie, schema: .string)),
            .parameter(name: "hello", parameterLocation: .cookie, schema: .string),
            .parameter(OpenAPI.PathItem.Parameter(name: "hello", parameterLocation: .cookie, content: [.json: OpenAPI.Content(schema: .string)])),
            .parameter(name: "hello", parameterLocation: .cookie, content: [.json: OpenAPI.Content(schema: .string)]),
            .reference(.component( named: "hello"))
        ]

        XCTAssertEqual(t1[0], t1[1])
        XCTAssertEqual(t1[2], t1[3])
        XCTAssertNotEqual(t1[4], t1[0])
        XCTAssertNotEqual(t1[4], t1[1])
        XCTAssertNotEqual(t1[4], t1[2])
        XCTAssertNotEqual(t1[4], t1[3])

        XCTAssertEqual(t1[0].parameterValue, OpenAPI.PathItem.Parameter(name: "hello", parameterLocation: .cookie, schema: .string))
        XCTAssertEqual(t1[4].reference, .component( named: "hello"))
    }
}

// MARK: - Codable Tests
extension ParameterTests {
    func test_minimalContent_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .path,
            content: [ .json: .init(schema: .string)]
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "in" : "path",
  "name" : "hello",
  "required" : true
}
"""
        )
    }

    func test_minimalContent_decode() throws {
        let parameterData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "in" : "path",
  "name" : "hello",
  "required" : true
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .path,
                content: [ .json: .init(schema: .string(required: false))]
            )
        )
        XCTAssertEqual(parameter.schemaOrContent.contentValue, [ .json: .init(schema: .string(required: false)) ])
    }

    func test_minimalSchema_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .path,
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_minamalScheam_decode() throws {
        let parameterData =
"""
{
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .path,
                schema: .string(required: false)
            )
        )
    }

    func test_queryParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .query,
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "query",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_queryParam_decode() throws {
        let parameterData =
"""
{
  "in" : "query",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .query,
                schema: .string(required: false)
            )
        )
        XCTAssertEqual(
            parameter.schemaOrContent.schemaValue,
            OpenAPI.PathItem.Parameter.Schema(.string(required: false), style: .default(for: .query))
        )
    }

    func test_queryParamAllowEmpty_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .query(allowEmptyValue: true),
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "allowEmptyValue" : true,
  "in" : "query",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_queryParamAllowEmpty_decode() throws {
        let parameterData =
"""
{
  "allowEmptyValue" : true,
  "in" : "query",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .query(allowEmptyValue: true),
                schema: .string(required: false)
            )
        )
    }

    func test_requiredQueryParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .query(required: true),
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "query",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_requiredQueryParam_decode() throws {
        let parameterData =
"""
{
  "in" : "query",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .query(required: true),
                schema: .string(required: false)
            )
        )
    }

    func test_headerParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .header,
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "header",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_headerParam_decode() throws {
        let parameterData =
"""
{
  "in" : "header",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .header,
                schema: .string(required: false)
            )
        )
    }

    func test_requiredHeaderParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .header(required: true),
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "header",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_requiredHeaderParam_decode() throws {
        let parameterData =
"""
{
  "in" : "header",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .header(required: true),
                schema: .string(required: false)
            )
        )
    }

    func test_cookieParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie,
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "cookie",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_cookieParam_decode() throws {
        let parameterData =
"""
{
  "in" : "cookie",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .cookie,
                schema: .string(required: false)
            )
        )
    }

    func test_requiredCookieParam_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .cookie(required: true),
            schema: .string
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "in" : "cookie",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_requiredCookieParam_decode() throws {
        let parameterData =
"""
{
  "in" : "cookie",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .cookie(required: true),
                schema: .string(required: false)
            )
        )
    }

    func test_deprecated_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .path,
            schema: .string,
            deprecated: true
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "deprecated" : true,
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_deprecated_decode() throws {
        let parameterData =
"""
{
  "deprecated" : true,
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .path,
                schema: .string(required: false),
                deprecated: true
            )
        )
    }

    func test_description_encode() throws {
        let parameter = OpenAPI.PathItem.Parameter(
            name: "hello",
            parameterLocation: .path,
            schema: .string,
            description: "world"
        )

        let encodedParameter = try testStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
"""
{
  "description" : "world",
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
"""
        )
    }

    func test_description_decode() throws {
        let parameterData =
"""
{
  "description" : "world",
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let parameter = try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.PathItem.Parameter(
                name: "hello",
                parameterLocation: .path,
                schema: .string(required: false),
                description: "world"
            )
        )
    }

    func test_decodeBothSchemaAndContent_throws() {
        let parameterData =
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "in" : "path",
  "name" : "hello",
  "required" : true,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData))
    }

    func test_decodeNonRequiredPathParam_throws() {
        let parameterData =
"""
{
  "in" : "path",
  "name" : "hello",
  "required" : false,
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData))

        let parameterData2 =
"""
{
  "in" : "path",
  "name" : "hello",
  "schema" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.PathItem.Parameter.self, from: parameterData2))
    }
}
