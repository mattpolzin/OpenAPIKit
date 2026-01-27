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
        let t1 = OpenAPI.Parameter.cookie(
            name: "hello",
            required: true,
            schemaOrContent: .init([.json: .content(OpenAPI.Content(schema: .string))]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t1.required)

        let t2 = OpenAPI.Parameter.cookie(
            name: "hello",
            required: true,
            schemaOrContent: .content([.json: .content(OpenAPI.Content(schema: .string))]),
            description: "hi",
            deprecated: true
        )
        XCTAssertTrue(t2.deprecated)
        XCTAssertEqual(t1, t2)

        let t6 = OpenAPI.Parameter.cookie(
            name: "hello",
            schemaOrContent: .schema(.init(.string, style: .default(for: .cookie)))
        )
        XCTAssertFalse(t6.required)

        let _ = OpenAPI.Parameter.cookie(
            name: "hello",
            schemaReference: .component( named: "hello")
        )
    }

    func test_schemaAccess() {
        let t1 = OpenAPI.Parameter.cookie(
            name: "hello",
            schemaOrContent: .schema(.init(.string, style: .default(for: .cookie)))
        )

        XCTAssertNil(t1.schemaOrContent.contentValue)
        XCTAssertNil(t1.schemaOrContent.schemaReference)
        XCTAssertNil(t1.schemaOrContent.schemaContextValue?.schema.reference)
        XCTAssertEqual(t1.schemaOrContent.schemaValue, .string)
        XCTAssertEqual(t1.schemaOrContent.schemaContextValue, .init(.string, style: .default(for: .cookie)))
        XCTAssertEqual(t1.schemaOrContent.schemaContextValue?.schema.schemaValue, t1.schemaOrContent.schemaValue)

        let t2 = OpenAPI.Parameter.cookie(
            name: "hello",
            schemaReference: .component( named: "hello")
        )

        XCTAssertNil(t2.schemaOrContent.contentValue)
        XCTAssertNil(t2.schemaOrContent.schemaValue)
        XCTAssertNil(t2.schemaOrContent.schemaContextValue?.schema.schemaValue)
        XCTAssertEqual(t2.schemaOrContent.schemaReference, .component( named: "hello"))
        XCTAssertEqual(t2.schemaOrContent.schemaContextValue?.schema.reference, t2.schemaOrContent.schemaReference)

        let t3 = OpenAPI.Parameter.path(
            name: "hello",
            content: [:]
        )

        XCTAssertNil(t3.schemaOrContent.schemaValue)
        XCTAssertNil(t3.schemaOrContent.schemaReference)
        XCTAssertNil(t3.schemaOrContent.schemaContextValue)
        XCTAssertEqual(t3.schemaOrContent.contentValue, [:])
    }

    func test_parameterArray() {
        let t1: OpenAPI.Parameter.Array = [
            .parameter(OpenAPI.Parameter.cookie(name: "hello", schema: .string)),
            .parameter(name: "hello", context: .cookie(schema: .string)),
            .parameter(OpenAPI.Parameter.cookie(name: "hello", content: [.json: .content(OpenAPI.Content(schema: .string))])),
            .parameter(name: "hello", context: .cookie(content: [.json: .content(OpenAPI.Content(schema: .string))])),
            .reference(.component( named: "hello"))
        ]

        XCTAssertEqual(t1[0], t1[1])
        XCTAssertEqual(t1[2], t1[3])
        XCTAssertNotEqual(t1[4], t1[0])
        XCTAssertNotEqual(t1[4], t1[1])
        XCTAssertNotEqual(t1[4], t1[2])
        XCTAssertNotEqual(t1[4], t1[3])

        XCTAssertEqual(t1[0].parameterValue, OpenAPI.Parameter.cookie(name: "hello", schema: .string))
        XCTAssertEqual(t1[4].reference, .component( named: "hello"))
    }

    func test_querystringLocation() {
        let t1 = OpenAPI.Parameter.querystring(name: "string", content: [:])
        XCTAssertEqual(t1.conditionalWarnings.count, 1)
    }
}

// MARK: - Codable Tests
extension ParameterTests {
    func test_minimalContent_encode() throws {
        let parameter = OpenAPI.Parameter.path(
            name: "hello",
            content: [ .json: .content(.init(schema: .string))]
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
            OpenAPI.Parameter.path(
                name: "hello",
                content: [ .json: .content(.init(schema: .string))]
            )
        )
        XCTAssertEqual(parameter.schemaOrContent.contentValue, [ .json: .content(.init(schema: .string) )])
    }

    func test_minimalSchema_encode() throws {
        let parameter = OpenAPI.Parameter.path(
            name: "hello",
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
            OpenAPI.Parameter.path(
                name: "hello",
                schema: .string
            )
        )
    }

    func test_queryParam_encode() throws {
        let parameter = OpenAPI.Parameter.query(
            name: "hello",
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
            OpenAPI.Parameter.query(
                name: "hello",
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
        let parameter = OpenAPI.Parameter.query(
            name: "hello",
            allowEmptyValue: true,
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
            OpenAPI.Parameter.query(
                name: "hello",
                allowEmptyValue: true,
                schema: .string
            )
        )
    }

    func test_requiredQueryParam_encode() throws {
        let parameter = OpenAPI.Parameter.query(
            name: "hello",
            required: true,
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
            OpenAPI.Parameter.query(
                name: "hello",
                required: true,
                schema: .string
            )
        )
    }

    func test_headerParam_encode() throws {
        let parameter = OpenAPI.Parameter.header(
            name: "hello",
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
            OpenAPI.Parameter.header(
                name: "hello",
                schema: .string
            )
        )
    }

    func test_requiredHeaderParam_encode() throws {
        let parameter = OpenAPI.Parameter.header(
            name: "hello",
            required: true,
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
            OpenAPI.Parameter.header(
                name: "hello",
                required: true,
                schema: .string
            )
        )
    }

    func test_cookieParam_encode() throws {
        let parameter = OpenAPI.Parameter.cookie(
            name: "hello",
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
            OpenAPI.Parameter.cookie(
                name: "hello",
                schema: .string
            )
        )
    }

    func test_requiredCookieParam_encode() throws {
        let parameter = OpenAPI.Parameter.cookie(
            name: "hello",
            required: true,
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
            OpenAPI.Parameter.cookie(
                name: "hello",
                required: true,
                schema: .string
            )
        )
    }

    func test_deprecated_encode() throws {
        let parameter = OpenAPI.Parameter.path(
            name: "hello",
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
            OpenAPI.Parameter.path(
                name: "hello",
                schema: .string,
                deprecated: true
            )
        )
    }

    func test_description_encode() throws {
        let parameter = OpenAPI.Parameter.path(
            name: "hello",
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
            OpenAPI.Parameter.path(
                name: "hello",
                schema: .string,
                description: "world"
            )
        )
    }

    func test_example_encode() throws {
        let parameter = OpenAPI.Parameter.header(
            name: "hello",
            required: true,
            schemaOrContent: .schema(
                .init(
                    .string,
                    style: .default(for: .header),
                    example: "hello string"
                )
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
            OpenAPI.Parameter.header(
                name: "hello",
                required: true,
                schemaOrContent: .schema(
                    .init(
                        .string,
                        style: .default(for: .header),
                        example: "hello string"
                    )
                )
            )
        )
    }

    func test_examples_encode() throws {
        let parameter = OpenAPI.Parameter.header(
            name: "hello",
            required: true,
            schemaOrContent: .schema(
                .init(
                    .string,
                    style: .default(for: .header),
                    allowReserved: true,
                    examples: [
                        "test": .example(externalValue: URL(string: "http://website.com")!)
                    ]
                )
            )
        )

        let encodedParameter = try orderUnstableTestStringFromEncoding(of: parameter)

        assertJSONEquivalent(
            encodedParameter,
            """
            {
              "allowReserved" : true,
              "examples" : {
                "test" : {
                  "externalValue" : "http:\\/\\/website.com"
                }
              },
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

    func test_examples_decode() throws {
        let parameterData =
        """
        {
          "allowReserved" : true,
          "examples" : {
            "test" : {
              "externalValue" : "http://website.com"
            }
          },
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
            OpenAPI.Parameter.header(
                name: "hello",
                required: true,
                schemaOrContent: .schema(
                    .init(
                        .string,
                        style: .default(for: .header),
                        allowReserved: true,
                        examples: [
                            "test": .example(externalValue: URL(string: "http://website.com")!)
                        ]
                    )
                )
            )
        )
    }

    func test_vendorExtension_encode() throws {
        let parameter = OpenAPI.Parameter.path(
            name: "hello",
            schema: .string,
            description: "world",
            vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
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
            OpenAPI.Parameter.path(
                name: "hello",
                schema: .string,
                description: "world",
                vendorExtensions: ["x-specialFeature": .init(["hello", "world"])]
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
