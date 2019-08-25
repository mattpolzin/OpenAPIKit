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

        let content = OpenAPI.Content(schema: .init(JSONReference<OpenAPI.Components, JSONSchema>.file("hello.yml")))
        let r2 = OpenAPI.Response(description: "",
                                  content: [.json: content])
        XCTAssertEqual(r2.description, "")
        XCTAssertEqual(r2.content, [.json: content])
    }
}

// MARK: Response Status Code
extension ResponseTests {
    func test_defaultFromString() {
        typealias StatusCode = OpenAPI.Response.StatusCode
        XCTAssertEqual(StatusCode(rawValue: "default"), .default)
        XCTAssertEqual(StatusCode(rawValue: "default")?.rawValue, "default")
    }

    func test_codeFromString() {
        typealias StatusCode = OpenAPI.Response.StatusCode
        XCTAssertEqual(StatusCode(rawValue: "123"), .status(code: 123))
        XCTAssertEqual(StatusCode(rawValue: "123")?.rawValue, "123")
        XCTAssertEqual(StatusCode(rawValue: "404"), .status(code: 404))
        XCTAssertEqual(StatusCode(rawValue: "404")?.rawValue, "404")
        XCTAssertEqual(StatusCode(rawValue: "500"), .status(code: 500))
        XCTAssertEqual(StatusCode(rawValue: "500")?.rawValue, "500")
    }

    func test_NilForNonIntegerString() {
        typealias StatusCode = OpenAPI.Response.StatusCode
        XCTAssertNil(StatusCode(rawValue: "hello"))
    }

    func test_codeFromIntegerLiteral() {
        typealias StatusCode = OpenAPI.Response.StatusCode
        XCTAssertEqual(123, StatusCode.status(code: 123))
        XCTAssertEqual(404, StatusCode.status(code: 404))
        XCTAssertEqual(500, StatusCode.status(code: 500))
    }
}

// MARK: - Codable
@available(OSX 10.13, *)
extension ResponseTests {
    func test_emptyDescriptionEmptyContent_encode() {
        let response = OpenAPI.Response(description: "", content: [:])
        let encodedResponse = try! testStringFromEncoding(of: response)

        XCTAssertEqual(encodedResponse,
"""
{
  "description" : ""
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
        let response = try! testDecoder.decode(OpenAPI.Response.self, from: responseData)

        XCTAssertEqual(response, OpenAPI.Response(description: "", content: [:]))

        let responseData2 =
"""
{
  "content": {},
  "description" : ""
}
""".data(using: .utf8)!
        let response2 = try! testDecoder.decode(OpenAPI.Response.self, from: responseData2)

        XCTAssertEqual(response2, OpenAPI.Response(description: "", content: [:]))
    }

    func test_populatedDescriptionPopulatedContent_encode() {
        let content = OpenAPI.Content(schema: .init(.string))
        let response = OpenAPI.Response(description: "hello world", content: [.json: content])

        let encodedResponse = try! testStringFromEncoding(of: response)

        XCTAssertEqual(encodedResponse,
"""
{
  "content" : {
    "application\\/json" : {
      "schema" : {
        "type" : "string"
      }
    }
  },
  "description" : "hello world"
}
"""
                       )
    }

    func test_populatedDescriptionPopulatedContent_decode() {
        let responseData =
"""
{
    "description": "hello world",
    "content": { "application/json": { "schema": { "type": "string" } } }
}
""".data(using: .utf8)!

        let response = try! testDecoder.decode(OpenAPI.Response.self, from: responseData)

        let content = OpenAPI.Content(schema: .init(.string(required: false)))
        XCTAssertEqual(response, OpenAPI.Response(description: "hello world", content: [.json: content]))
    }
}

// MARK: Response Status Code
@available(OSX 10.13, *)
extension ResponseTests {

    struct StatusCodeWrapper: Codable, Equatable {
        let status: OpenAPI.Response.StatusCode
    }

    func test_defaultStatusCode_encode() {
        let status = StatusCodeWrapper(status: .default)
        let encodedStatus = try! testStringFromEncoding(of: status)

        XCTAssertEqual(encodedStatus,
"""
{
  "status" : "default"
}
"""
                       )
    }

    func test_defaultStatusCode_decode() {
        let statusCodeData =
"""
{
    "status": "default"
}
""".data(using: .utf8)!

        XCTAssertEqual(try! testDecoder.decode(StatusCodeWrapper.self, from: statusCodeData), StatusCodeWrapper(status: .default))
    }

    func test_numberStatusCode_encode() {
        let status = StatusCodeWrapper(status: 123)
        let encodedStatus = try! testStringFromEncoding(of: status)

        XCTAssertEqual(encodedStatus,
"""
{
  "status" : "123"
}
"""
        )
    }

    func test_numberStatusCode_decode() {
        let statusCodeData =
"""
{
    "status": "123"
}
""".data(using: .utf8)!

        XCTAssertEqual(try! testDecoder.decode(StatusCodeWrapper.self, from: statusCodeData), StatusCodeWrapper(status: 123))
    }

    func test_nonesenseStatusCode_decode_throws() {
        let statusCodeData =
"""
{
    "status": "hello world"
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try testDecoder.decode(StatusCodeWrapper.self, from: statusCodeData))
    }
}
