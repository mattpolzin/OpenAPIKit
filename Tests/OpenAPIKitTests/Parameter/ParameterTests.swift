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
        let t1 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie(required: true),
            schemaOrContent: .init([.json: OpenAPI.Content(schema: .string)]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t1.required)

        let t2 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie(required: true),
            schemaOrContent: .content([.json: OpenAPI.Content(schema: .string)]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t2.deprecated)
        XCTAssertEqual(t1, t2)

        let t4 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie(required: false),
            schema: .init(.string, style: .default(for: .cookie)),
            description: "hi",
            deprecated: false
        )
        XCTAssertFalse(t4.required)

        let t5 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schema: .string
        )
        XCTAssertFalse(t5.deprecated)

        let t6 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schemaOrContent: .schema(.init(.string, style: .default(for: .cookie)))
        )
        XCTAssertEqual(t5, t6)

        let _ = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schemaReference: .component( named: "hello")
        )

        let _ = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            content: [.json: OpenAPI.Content(schema: .string)]
        )
    }

    func test_schemaAccess() {
        let t1 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schemaOrContent: .schema(.init(.string, style: .default(for: .cookie)))
        )

        XCTAssertNil(t1.schemaOrContent.contentValue)
        XCTAssertNil(t1.schemaOrContent.schemaReference)
        XCTAssertNil(t1.schemaOrContent.schemaContextValue?.schema.reference)
        XCTAssertEqual(t1.schemaOrContent.schemaValue, .string)
        XCTAssertEqual(t1.schemaOrContent.schemaContextValue, .init(.string, style: .default(for: .cookie)))
        XCTAssertEqual(t1.schemaOrContent.schemaContextValue?.schema.schemaValue, t1.schemaOrContent.schemaValue)

        let t2 = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schemaReference: .component( named: "hello")
        )

        XCTAssertNil(t2.schemaOrContent.contentValue)
        XCTAssertNil(t2.schemaOrContent.schemaValue)
        XCTAssertNil(t2.schemaOrContent.schemaContextValue?.schema.schemaValue)
        XCTAssertEqual(t2.schemaOrContent.schemaReference, .component( named: "hello"))
        XCTAssertEqual(t2.schemaOrContent.schemaContextValue?.schema.reference, t2.schemaOrContent.schemaReference)

        let t3 = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            content: [:]
        )

        XCTAssertNil(t3.schemaOrContent.schemaValue)
        XCTAssertNil(t3.schemaOrContent.schemaReference)
        XCTAssertNil(t3.schemaOrContent.schemaContextValue)
        XCTAssertEqual(t3.schemaOrContent.contentValue, [:])
    }

    func test_parameterArray() {
        let t1: OpenAPI.Parameter.Array = [
            .parameter(OpenAPI.Parameter(name: "hello", context: .cookie, schema: .string)),
            .parameter(name: "hello", context: .cookie, schema: .string),
            .parameter(OpenAPI.Parameter(name: "hello", context: .cookie, content: [.json: OpenAPI.Content(schema: .string)])),
            .parameter(name: "hello", context: .cookie, content: [.json: OpenAPI.Content(schema: .string)]),
            .reference(.component( named: "hello"))
        ]

        XCTAssertEqual(t1[0], t1[1])
        XCTAssertEqual(t1[2], t1[3])
        XCTAssertNotEqual(t1[4], t1[0])
        XCTAssertNotEqual(t1[4], t1[1])
        XCTAssertNotEqual(t1[4], t1[2])
        XCTAssertNotEqual(t1[4], t1[3])

        XCTAssertEqual(t1[0].parameterValue, OpenAPI.Parameter(name: "hello", context: .cookie, schema: .string))
        XCTAssertEqual(t1[4].reference, .component( named: "hello"))
    }
}

// MARK: - Codable Tests
extension ParameterTests {
    func test_minimalContent_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            content: [ .json: .init(schema: .string)]
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .path,
                content: [ .json: .init(schema: .string)]
            )
        )
        XCTAssertEqual(parameter.schemaOrContent.contentValue, [ .json: .init(schema: .string) ])
    }

    func test_minimalSchema_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .path,
                schema: .string
            )
        )
    }

    func test_queryParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .query,
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .query)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .query,
                schema: .string
            )
        )
        XCTAssertEqual(
            parameter.schemaOrContent.schemaContextValue,
            OpenAPI.Parameter.SchemaContext(.string, style: .default(for: .query))
        )
        XCTAssertEqual(parameter.schemaOrContent.schemaValue, parameter.schemaOrContent.schemaContextValue?.schema.schemaValue)
    }

    func test_queryParamAllowEmpty_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .query(allowEmptyValue: true),
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .query(allowEmptyValue: true),
                schema: .string
            )
        )
    }

    func test_requiredQueryParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .query(required: true),
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .query(required: true),
                schema: .string
            )
        )
    }

    func test_headerParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .header,
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .header)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .header,
                schema: .string
            )
        )
    }

    func test_requiredHeaderParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .header(required: true),
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .header(required: true),
                schema: .string
            )
        )
    }

    func test_cookieParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .cookie,
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .cookie)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .cookie,
                schema: .string
            )
        )
    }

    func test_requiredCookieParam_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .cookie(required: true),
            schema: .string
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .cookie(required: true),
                schema: .string
            )
        )
    }

    func test_deprecated_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            schema: .string,
            deprecated: true
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .path,
                schema: .string,
                deprecated: true
            )
        )
    }

    func test_description_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            schema: .string,
            description: "world"
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .path)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .path,
                schema: .string,
                description: "world"
            )
        )
    }

    func test_example_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .header(required: true),
            schema: .init(
                .string,
                style: .default(for: .header),
                example: "hello string"
            )
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
            """
            {
              "example" : "hello string",
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

    func test_example_decode() throws {
        let parameterData =
        """
        {
          "example" : "hello string",
          "in" : "header",
          "name" : "hello",
          "required" : true,
          "schema" : {
            "type" : "string"
          }
        }
        """.data(using: .utf8)!

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .header)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .header(required: true),
                schema: .init(
                    .string,
                    style: .default(for: .header),
                    example: "hello string"
                )
            )
        )
    }

    func test_vendorExtension_encode() throws {
        let parameter = OpenAPI.Parameter(
            name: "hello",
            context: .path,
            schema: .string,
            description: "world",
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

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
              },
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_vendorExtension_decode() throws {
        let parameterData =
        """
        {
          "description" : "world",
          "in" : "path",
          "name" : "hello",
          "required" : true,
          "schema" : {
            "type" : "string"
          },
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!

        let parameter = try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData)

        XCTAssertEqual(parameter.location, .path)
        XCTAssertEqual(
            parameter,
            OpenAPI.Parameter(
                name: "hello",
                context: .path,
                schema: .string,
                description: "world",
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
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

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData))
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

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData))

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

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Parameter.self, from: parameterData2))
    }
}
