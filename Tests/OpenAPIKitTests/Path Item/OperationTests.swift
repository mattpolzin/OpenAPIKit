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
        // TODO: write tests
    }
}

// MARK: - Codable Tests
extension OperationTests {

    func test_responseOrder_encode() throws {
        let operation = OpenAPI.PathItem.Operation(
            responses: [
                404: .response(reference: .internal(\.responses, named: "404")),
                200: .response(reference: .internal(\.responses, named: "200"))
            ]
        )

        let encodedOperation = String(
            data: try JSONEncoder().encode(operation),
            encoding: .utf8
        )!

        XCTAssertEqual(
            encodedOperation,
"""
{"responses":{"404":{"$ref":"#\\/components\\/responses\\/404"},"200":{"$ref":"#\\/components\\/responses\\/200"}}}
"""
        )

        let operation2 = OpenAPI.PathItem.Operation(
            responses: [
                200: .response(reference: .internal(\.responses, named: "200")),
                404: .response(reference: .internal(\.responses, named: "404"))
            ]
        )

        let encodedOperation2 = String(
            data: try JSONEncoder().encode(operation2),
            encoding: .utf8
            )!

        XCTAssertEqual(
            encodedOperation2,
            """
{"responses":{"200":{"$ref":"#\\/components\\/responses\\/200"},"404":{"$ref":"#\\/components\\/responses\\/404"}}}
"""
        )
    }

    // Note that only the YAML decoder respects ordering currently
    func test_responseOrder_decode() throws {
        let operationString =
"""
responses:
  404:
    $ref: '#/components/responses/404'
  200:
    $ref: '#/components/responses/200'
"""

        let operation = try YAMLDecoder().decode(OpenAPI.PathItem.Operation.self, from: operationString)

        XCTAssertEqual(
            operation,
            OpenAPI.PathItem.Operation(
                responses: [
                    404: .response(reference: .internal(.unsafe("#/components/responses/404"))),
                    200: .response(reference: .internal(.unsafe("#/components/responses/200")))
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

        let operation2 = try YAMLDecoder().decode(OpenAPI.PathItem.Operation.self, from: operationString2)

        XCTAssertEqual(
            operation2,
            OpenAPI.PathItem.Operation(
                responses: [
                    200: .response(reference: .internal(.unsafe("#/components/responses/200"))),
                    404: .response(reference: .internal(.unsafe("#/components/responses/404")))
                ]
            )
        )
    }

    // TODO: write tests
}
