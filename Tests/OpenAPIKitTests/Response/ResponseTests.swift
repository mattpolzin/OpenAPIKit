//
//  ResponseTests.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/5/19.
//

import Foundation
import XCTest
import OpenAPIKit

final class ResponseTests: XCTestCase {
    func test_Initialization() {
        let r1 = OpenAPI.Response(description: "hello world",
                                  content: [:])
        XCTAssertEqual(r1.description, "hello world")
        XCTAssertNil(r1.headers)
        XCTAssertEqual(r1.content, [:])

        let content = OpenAPI.Content(schema: .init(OpenAPI.Reference<JSONSchema>.external(URL(string: "hello.yml")!)))
        let header = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        let r2 = OpenAPI.Response(description: "",
                                  headers: ["hello": .init(header)],
                                  content: [.json: content])
        XCTAssertEqual(r2.description, "")
        XCTAssertEqual(r2.headers?["hello"]?.headerValue, header)
        XCTAssertEqual(r2.content, [.json: content])
        XCTAssertEqual(r2.conditionalWarnings.count, 0)

        // two OAS 3.2.0 warnings: summary is used and description is not
        let r3 = OpenAPI.Response(summary: "",
                                  content: [:])
        XCTAssertEqual(r3.summary, "")
        XCTAssertNil(r3.description)
        XCTAssertEqual(r3.conditionalWarnings.count, 2)

        // one OAS 3.2.0 warnings: summary is used
        let r4 = OpenAPI.Response(summary: "",
                                  description: "",
                                  content: [:])
        XCTAssertEqual(r4.summary, "")
        XCTAssertEqual(r4.description, "")
        XCTAssertEqual(r4.conditionalWarnings.count, 1)

        // one OAS 3.2.0 warnings: description is not used
        let r5 = OpenAPI.Response(content: [:])
        XCTAssertNil(r5.summary)
        XCTAssertNil(r5.description)
        XCTAssertEqual(r5.conditionalWarnings.count, 1)
    }

    func test_responseMap() {
        let responseMap: OpenAPI.Response.Map = [
            200: .response(description: "hello world", content: [:]),
            404: .reference(.external(URL(string: "hello.json#/world")!)),
            500: .response(.init(description: "Server Error", content: [:]))
        ]

        XCTAssertNotNil(responseMap[200]?.responseValue)
        XCTAssertNil(responseMap[200]?.reference)
        XCTAssertNotNil(responseMap[404]?.reference)
        XCTAssertNil(responseMap[404]?.responseValue)
    }

    func test_status() {
        let t1: OpenAPI.Response.StatusCode = .range(.success)
        XCTAssertTrue(t1.isSuccess)

        let t2: OpenAPI.Response.StatusCode = 201
        XCTAssertTrue(t2.isSuccess)

        let t3: OpenAPI.Response.StatusCode = 200
        XCTAssertTrue(t3.isSuccess)

        let t4: OpenAPI.Response.StatusCode = 300
        XCTAssertFalse(t4.isSuccess)

        let t5: OpenAPI.Response.StatusCode = .range(.serverError)
        XCTAssertFalse(t5.isSuccess)
    }
}

// MARK: Response Status Code
extension ResponseTests {
    typealias StatusCode = OpenAPI.Response.StatusCode

    func test_defaultFromString() {
        XCTAssertEqual(StatusCode(rawValue: "default"), .default)
        XCTAssertEqual(StatusCode(rawValue: "default")?.rawValue, "default")
    }

    func test_codeFromString() {
        XCTAssertEqual(StatusCode(rawValue: "123"), .status(code: 123))
        XCTAssertEqual(StatusCode(rawValue: "123")?.rawValue, "123")
        XCTAssertEqual(StatusCode(rawValue: "404"), .status(code: 404))
        XCTAssertEqual(StatusCode(rawValue: "404")?.rawValue, "404")
        XCTAssertEqual(StatusCode(rawValue: "500"), .status(code: 500))
        XCTAssertEqual(StatusCode(rawValue: "500")?.rawValue, "500")
    }

    func test_NilForNonIntegerString() {
        XCTAssertNil(StatusCode(rawValue: "hello"))
    }

    func test_fallbackForTwoAlts() {
        let test = StatusCode(rawValue: "404/500")
        XCTAssertEqual(test?.rawValue, "404")
        XCTAssertEqual(test?.warnings.first?.localizedDescription, "Found non-compliant Status Code \'404/500\' but was able to parse as 404")
    }

    func test_codeFromIntegerLiteral() {
        XCTAssertEqual(123, StatusCode.status(code: 123))
        XCTAssertEqual(404, StatusCode.status(code: 404))
        XCTAssertEqual(500, StatusCode.status(code: 500))
    }
}

// MARK: - Codable
extension ResponseTests {
    func test_emptyDescriptionEmptyContent_encode() {
        let response = OpenAPI.Response(description: "", content: [:])
        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: response)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "description" : ""
            }
            """
        )

        let response2 = OpenAPI.Response(description: "", headers: [:], content: [:])
        let encodedResponse2 = try! orderUnstableTestStringFromEncoding(of: response2)

        assertJSONEquivalent(
            encodedResponse2,
            """
            {
              "description" : "",
              "headers" : {

              }
            }
            """
        )

        let response3 = OpenAPI.Response(summary: "", content: [:])
        let encodedResponse3 = try! orderUnstableTestStringFromEncoding(of: response3)

        assertJSONEquivalent(
            encodedResponse3,
            """
            {
              "summary" : ""
            }
            """
        )
    }

    func test_emptyDescriptionEmptyContent_decode() {
        let responseData =
        """
        {
          "description" : ""
        }
        """.data(using: .utf8)!
        let response = try! orderUnstableDecode(OpenAPI.Response.self, from: responseData)

        XCTAssertEqual(response, OpenAPI.Response(description: "", content: [:]))

        let responseData2 =
        """
        {
          "content": {},
          "description" : ""
        }
        """.data(using: .utf8)!
        let response2 = try! orderUnstableDecode(OpenAPI.Response.self, from: responseData2)

        XCTAssertEqual(response2, OpenAPI.Response(description: "", content: [:]))

        let responseData3 =
        """
        {
          "content": {},
          "description" : "",
          "headers": {}
        }
        """.data(using: .utf8)!
        let response3 = try! orderUnstableDecode(OpenAPI.Response.self, from: responseData3)

        XCTAssertEqual(response3, OpenAPI.Response(description: "", headers: [:], content: [:]))

        let responseData4 =
        """
        {
          "summary" : ""
        }
        """.data(using: .utf8)!
        let response4 = try! orderUnstableDecode(OpenAPI.Response.self, from: responseData4)

        XCTAssertEqual(response4, OpenAPI.Response(summary: "", content: [:]))
    }

    func test_populatedDescriptionPopulatedContent_encode() {
        let content = OpenAPI.Content(schema: .init(.string))
        let header = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        let response = OpenAPI.Response(
            description: "hello world",
            headers: ["hello": .init(header)],
            content: [.json: content]
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: response)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "content" : {
                "application\\/json" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "description" : "hello world",
              "headers" : {
                "hello" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              }
            }
            """
        )
    }

    func test_populatedDescriptionPopulatedContent_decode() throws {
        let responseData =
        """
        {
            "description": "hello world",
            "content": { "application/json": { "schema": { "type": "string" } } },
            "headers": {
                "hello": { "schema" : { "type" : "string" } }
            }
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Response.self, from: responseData)

        let content = OpenAPI.Content(schema: .init(.string))
        let header = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        XCTAssertEqual(
            response,
            OpenAPI.Response(
                description: "hello world",
                headers: ["hello": .init(header)],
                content: [.json: content]
            )
        )
    }

    func test_schemaReferenceHeader_encode() {
        let header = OpenAPI.Header(schemaReference: .component(named: "schemaRef"), description: "a good header")
        let response = OpenAPI.Response(
            description: "hello world",
            headers: ["hello": .init(header)],
            content: [:]
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: response)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "description" : "hello world",
              "headers" : {
                "hello" : {
                  "description" : "a good header",
                  "schema" : {
                    "$ref" : "#\\/components\\/schemas\\/schemaRef"
                  }
                }
              }
            }
            """
        )
    }

    func test_schemaReferenceHeader_decode() throws {
        let responseData =
        """
        {
            "description": "hello world",
            "headers": {
                "hello": {
                    "description": "a good header",
                    "schema" : { "$ref" : "#/components/schemas/schemaRef" }
                }
            }
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Response.self, from: responseData)

        let header = OpenAPI.Header(schemaReference: .component(named: "schemaRef"), description: "a good header")
        XCTAssertEqual(
            response,
            OpenAPI.Response(
                description: "hello world",
                headers: ["hello": .init(header)]
            )
        )
    }

    func test_populatedDescriptionPopulatedContent_withExtension_encode() {
        let content = OpenAPI.Content(schema: .init(.string))
        let header = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        let response = OpenAPI.Response(
            description: "hello world",
            headers: ["hello": .init(header)],
            content: [.json: content],
            vendorExtensions: [ "x-specialFeature": true ]
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: response)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "content" : {
                "application\\/json" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "description" : "hello world",
              "headers" : {
                "hello" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "x-specialFeature" : true
            }
            """
        )
    }

    func test_populatedDescriptionPopulatedContent_withExtension_decode() throws {
        let responseData =
        """
        {
            "description": "hello world",
            "content": { "application/json": { "schema": { "type": "string" } } },
            "headers": {
                "hello": { "schema" : { "type" : "string" } }
            },
            "x-specialFeature": true
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Response.self, from: responseData)

        let content = OpenAPI.Content(schema: .init(.string))
        let header = OpenAPI.Header(schemaOrContent: .init(.header(.string)))
        XCTAssertEqual(
            response,
            OpenAPI.Response(
                description: "hello world",
                headers: ["hello": .init(header)],
                content: [.json: content],
                vendorExtensions: [ "x-specialFeature": true ]
            )
        )
    }

    func test_populatedLinks_encode() {
        let links: OpenAPI.Link.Map = [
            "link1": .link(operationId: "op1")
        ]
        let response = OpenAPI.Response(
            description: "hello world",
            links: links
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: response)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "description" : "hello world",
              "links" : {
                "link1" : {
                  "operationId" : "op1"
                }
              }
            }
            """
        )
    }

    func test_populatedLinks_decode() throws {
        let responseData =
            """
        {
            "description" : "hello world",
              "links" : {
                "link1" : {
                  "operationId" : "op1"
                }
            }
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Response.self, from: responseData)

        let links: OpenAPI.Link.Map = [
            "link1": .link(operationId: "op1")
        ]
        XCTAssertEqual(
            response,
            OpenAPI.Response(
                description: "hello world",
                links: links
            )
        )
    }

    func test_doesNotFailDecodingLinks() {
        let t1 = """
        {
          "description" : "test",
          "links" : {
            "link" : {
              "operationId" : "test",
              "parameters" : {
                "userId" : "$response.body#/id",
                "description" : "A link test"
              }
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertNoThrow(try orderUnstableDecode(OpenAPI.Response.self, from: t1))
    }
}

// MARK: Response Status Code
extension ResponseTests {

    struct StatusCodeWrapper: Codable, Equatable {
        let status: OpenAPI.Response.StatusCode
    }

    func test_defaultStatusCode_encode() throws {
        let status = StatusCodeWrapper(status: .default)
        let encodedStatus = try orderUnstableTestStringFromEncoding(of: status)

        assertJSONEquivalent(
            encodedStatus,
            """
            {
              "status" : "default"
            }
            """
        )
    }

    func test_defaultStatusCode_decode() throws {
        let statusCodeData =
        """
        {
            "status": "default"
        }
        """.data(using: .utf8)!

        XCTAssertEqual(try orderUnstableDecode(StatusCodeWrapper.self, from: statusCodeData), StatusCodeWrapper(status: .default))
    }

    func test_numberStatusCode_encode() throws {
        let status = StatusCodeWrapper(status: 123)
        let encodedStatus = try orderUnstableTestStringFromEncoding(of: status)

        assertJSONEquivalent(
            encodedStatus,
            """
            {
              "status" : "123"
            }
            """
        )
    }

    func test_numberStatusCode_decode() throws {
        let statusCodeData =
        """
        {
            "status": "123"
        }
        """.data(using: .utf8)!

        XCTAssertEqual(try orderUnstableDecode(StatusCodeWrapper.self, from: statusCodeData), StatusCodeWrapper(status: 123))
    }

    func test_rangeStatusCode_encode() throws {
        let status = StatusCodeWrapper(status: .range(.redirect))
        let encodedStatus = try orderUnstableTestStringFromEncoding(of: status)

        assertJSONEquivalent(
            encodedStatus,
            """
            {
              "status" : "3XX"
            }
            """
        )
    }

    func test_rangeStatusCode_decode() throws {
        let statusCodeData =
        """
        {
            "status": "3XX"
        }
        """.data(using: .utf8)!

        XCTAssertEqual(
            try orderUnstableDecode(StatusCodeWrapper.self, from: statusCodeData),
            StatusCodeWrapper(status: .range(.redirect))
        )
    }

    func test_bestGuessStatusCode_decode() throws {
        let statusCodeData =
        """
        {
            "status": "400/500"
        }
        """.data(using: .utf8)!

        XCTAssertEqual(
            try orderUnstableDecode(StatusCodeWrapper.self, from: statusCodeData),
            StatusCodeWrapper(status: 400)
        )
    }

    func test_nonesenseStatusCode_decode_throws() {
        let statusCodeData =
        """
        {
            "status": "hello world"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(StatusCodeWrapper.self, from: statusCodeData))
    }
}
