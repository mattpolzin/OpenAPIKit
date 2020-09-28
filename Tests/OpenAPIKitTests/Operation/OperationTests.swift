//
//  OperationTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit
import Yams

final class OperationTests: XCTestCase {
    func test_init() {
        // minimum
        let _ = OpenAPI.Operation(
            responses: [:]
        )

        // all things
        let _ = OpenAPI.Operation(
            tags: ["hello"],
            summary: "summary",
            description: "description",
            externalDocs: .init(url: URL(string: "https://google.com")!),
            operationId: "123",
            parameters: [.parameter(name: "hi", context: .query, schema: .string)],
            requestBody: .init(content: [:]),
            responses: [:],
            deprecated: false,
            security: [],
            servers: []
        )

        // variadic tags
        let _ = OpenAPI.Operation(
            tags: "hi", "hello",
            parameters: [],
            responses: [:]
        )
    }

    func test_responseOutcomes() {
        let t1 = OpenAPI.Operation(
            responses: [
                200: .response(description: "success", content: [:]),
                404: .reference(.component(named: "notFound"))
            ]
        )

        XCTAssertEqual(
            t1.responseOutcomes,
            [
                .init(status: 200, response: .response(description: "success", content: [:])),
                .init(status: 404, response: .reference(.component(named: "notFound")))
            ]
        )
    }
}

// MARK: - Codable Tests
extension OperationTests {

    func test_minimal_encode() throws {
        let operation = OpenAPI.Operation(
            responses: [:]
        )

        let encodedOperation = try orderUnstableTestStringFromEncoding(of: operation)

        assertJSONEquivalent(
            encodedOperation,
            """
            {
              "responses" : {

              }
            }
            """
        )
    }

    func test_minimal_decode() throws {
        let operationData =
        """
        {
          "responses" : {}
        }
        """.data(using: .utf8)!

        let operation = try orderUnstableDecode(OpenAPI.Operation.self, from: operationData)

        XCTAssertEqual(
            operation,
            OpenAPI.Operation(responses: [:])
        )
    }

    func test_maximal_encode() throws {
        let operation = OpenAPI.Operation(
            tags: ["hi", "hello"],
            summary: "summary",
            description: "description",
            externalDocs: .init(url: URL(string: "https://google.com")!),
            operationId: "123",
            parameters: [
                .reference(.component(named: "hello"))
            ],
            requestBody: .init(content: [.json: .init(schema: .init(.string))]),
            responses: [200: .reference(.component(named: "test"))],
            deprecated: true,
            security: [[.component(named: "security"): []]],
            servers: [.init(url: URL(string: "https://google.com")!)],
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )

        let encodedOperation = try orderUnstableTestStringFromEncoding(of: operation)

        assertJSONEquivalent(
            encodedOperation,
            """
            {
              "deprecated" : true,
              "description" : "description",
              "externalDocs" : {
                "url" : "https:\\/\\/google.com"
              },
              "operationId" : "123",
              "parameters" : [
                {
                  "$ref" : "#\\/components\\/parameters\\/hello"
                }
              ],
              "requestBody" : {
                "content" : {
                  "application\\/json" : {
                    "schema" : {
                      "type" : "string"
                    }
                  }
                }
              },
              "responses" : {
                "200" : {
                  "$ref" : "#\\/components\\/responses\\/test"
                }
              },
              "security" : [
                {
                  "security" : [

                  ]
                }
              ],
              "servers" : [
                {
                  "url" : "https:\\/\\/google.com"
                }
              ],
              "summary" : "summary",
              "tags" : [
                "hi",
                "hello"
              ],
              "x-specialFeature" : [
                "hello",
                "world"
              ]
            }
            """
        )
    }

    func test_maximal_decode() throws {
        let operationData =
        """
        {
          "deprecated" : true,
          "description" : "description",
          "externalDocs" : {
            "url" : "https://google.com"
          },
          "operationId" : "123",
          "parameters" : [
            {
              "$ref" : "#/components/parameters/hello"
            }
          ],
          "requestBody" : {
            "content" : {
              "application\\/json" : {
                "schema" : {
                  "type" : "string"
                }
              }
            }
          },
          "responses" : {
            "200" : {
              "$ref" : "#/components/responses/test"
            }
          },
          "security" : [
            {
              "security" : [

              ]
            }
          ],
          "servers" : [
            {
              "url" : "https://google.com"
            }
          ],
          "summary" : "summary",
          "tags" : [
            "hi",
            "hello"
          ],
          "x-specialFeature" : [
            "hello",
            "world"
          ]
        }
        """.data(using: .utf8)!

        let operation = try orderUnstableDecode(OpenAPI.Operation.self, from: operationData)

        XCTAssertEqual(
            operation,
            OpenAPI.Operation(
                tags: ["hi", "hello"],
                summary: "summary",
                description: "description",
                externalDocs: .init(url: URL(string: "https://google.com")!),
                operationId: "123",
                parameters: [
                    .reference(.component(named: "hello"))
                ],
                requestBody: .init(content: [.json: .init(schema: .init(.string))]),
                responses: [200: .reference(.component(named: "test"))],
                deprecated: true,
                security: [[.component(named: "security"): []]],
                servers: [.init(url: URL(string: "https://google.com")!)],
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )

        // compare request to construction of Either
        XCTAssertEqual(operation.requestBody, .request(.init(content: [.json: .init(schema: .init(.string))])))
        // compare request having extracted from Either
        XCTAssertEqual(operation.requestBody?.requestValue, .init(content: [.json: .init(schema: .init(.string))]))

        XCTAssertNil(operation.responses[200]?.responseValue)
        XCTAssertEqual(operation.responses[200]?.reference, .component(named: "test"))
    }

    func test_doesNotFailDecodingCallbacks() {
        let operationData =
        """
        {
          "responses" : {},
          "callbacks" : {
            "callback" : {
              "{$request.query.queryUrl}" : {
                "post" : {
                  "responses" : {
                    "200" : {
                      "description" : "callback successfully processed"
                    }
                  }
                }
              }
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertNoThrow(try orderUnstableDecode(OpenAPI.Operation.self, from: operationData))
    }

    // Note that JSONEncoder for Linux Foundation does not respect order
    func test_responseOrder_encode() throws {
        let operation = OpenAPI.Operation(
            responses: [
                404: .reference(.component(named: "404")),
                200: .reference(.component(named: "200"))
            ]
        )

        let encodedOperation = String(
            data: try orderStableEncode(operation),
            encoding: .utf8
        )!

        XCTAssertEqual(
            encodedOperation,
            """
            {
              "responses": {
                "404": {
                  "$ref": "#/components/responses/404"
                },
                "200": {
                  "$ref": "#/components/responses/200"
                }
              }
            }
            """
        )

        let operation2 = OpenAPI.Operation(
            responses: [
                200: .reference(.component(named: "200")),
                404: .reference(.component(named: "404"))
            ]
        )

        let encodedOperation2 = String(
            data: try orderStableEncode(operation2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedOperation2,
            """
            {
              "responses": {
                "200": {
                  "$ref": "#/components/responses/200"
                },
                "404": {
                  "$ref": "#/components/responses/404"
                }
              }
            }
            """
        )
    }

    // Note that JSONDecoder does not respect order
    func test_responseOrder_decode() throws {
        let operationString =
        """
        responses:
          404:
            $ref: '#/components/responses/404'
          200:
            $ref: '#/components/responses/200'
        """

        let operation = try YAMLDecoder().decode(OpenAPI.Operation.self, from: operationString)

        XCTAssertEqual(
            operation,
            OpenAPI.Operation(
                responses: [
                    404: .reference(.component(named: "404")),
                    200: .reference(.component(named: "200"))
                ]
            )
        )

        let operationString2 =
        """
        responses:
          200:
            $ref: '#/components/responses/200'
          404:
            $ref: '#/components/responses/404'
        """

        let operation2 = try YAMLDecoder().decode(OpenAPI.Operation.self, from: operationString2)

        XCTAssertEqual(
            operation2,
            OpenAPI.Operation(
                responses: [
                    200: .reference(.component(named: "200")),
                    404: .reference(.component(named: "404"))
                ]
            )
        )
    }
}
