//
//  RuntimeExpressionTests.swift
//  
//
//  Created by Mathew Polzin on 11/1/20.
//

import XCTest
import OpenAPIKit

final class RuntimeExpressionTests: XCTestCase {
    func test_url_decode() throws {
        let t = """
        {
            "expression": "$url"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .url
        )
    }

    func test_url_encode() throws {
        let wrapper = Wrapper(expression: .url)

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$url"
            }
            """
        )
    }

    func test_method_decode() throws {
        let t = """
        {
            "expression": "$method"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .method
        )
    }

    func test_method_encode() throws {
        let wrapper = Wrapper(expression: .method)

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$method"
            }
            """
        )
    }

    func test_statusCode_decode() throws {
        let t = """
        {
            "expression": "$statusCode"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .statusCode
        )
    }

    func test_statusCode_encode() throws {
        let wrapper = Wrapper(expression: .statusCode)

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$statusCode"
            }
            """
        )
    }

    func test_requestHeader_decode() throws {
        let t = """
        {
            "expression": "$request.header.Authorization"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .request(.header(name: "Authorization"))
        )
    }

    func test_requestHeader_encode() throws {
        let wrapper = Wrapper(expression: .request(.header(name: "Authorization")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$request.header.Authorization"
            }
            """
        )
    }

    func test_requestQuery_decode() throws {
        let t = """
        {
            "expression": "$request.query.search"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .request(.query(name: "search"))
        )
    }

    func test_requestQuery_encode() throws {
        let wrapper = Wrapper(expression: .request(.query(name: "search")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$request.query.search"
            }
            """
        )
    }

    func test_requestPath_decode() throws {
        let t = """
        {
            "expression": "$request.path.id"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .request(.path(name: "id"))
        )
    }

    func test_requestPath_encode() throws {
        let wrapper = Wrapper(expression: .request(.path(name: "id")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$request.path.id"
            }
            """
        )
    }

    func test_requestBody_decode() throws {
        let t = """
        {
            "expression": "$request.body"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .request(.body(nil))
        )
    }

    func test_requestBody_encode() throws {
        let wrapper = Wrapper(expression: .request(.body(nil)))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$request.body"
            }
            """
        )
    }

    func test_requestBodyPath_decode() throws {
        let t = """
        {
            "expression": "$request.body#/data/type"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .request(.body(.path("/data/type")))
        )
    }

    func test_requestBodyPath_encode() throws {
        let wrapper = Wrapper(expression: .request(.body(.path("/data/type"))))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$request.body#\\/data\\/type"
            }
            """
        )
    }

    func test_responseHeader_decode() throws {
        let t = """
        {
            "expression": "$response.header.Authorization"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .response(.header(name: "Authorization"))
        )
    }

    func test_responseHeader_encode() throws {
        let wrapper = Wrapper(expression: .response(.header(name: "Authorization")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$response.header.Authorization"
            }
            """
        )
    }

    func test_responseQuery_decode() throws {
        let t = """
        {
            "expression": "$response.query.search"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .response(.query(name: "search"))
        )
    }

    func test_responseQuery_encode() throws {
        let wrapper = Wrapper(expression: .response(.query(name: "search")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$response.query.search"
            }
            """
        )
    }

    func test_responsePath_decode() throws {
        let t = """
        {
            "expression": "$response.path.id"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .response(.path(name: "id"))
        )
    }

    func test_responsePath_encode() throws {
        let wrapper = Wrapper(expression: .response(.path(name: "id")))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$response.path.id"
            }
            """
        )
    }

    func test_responseBody_decode() throws {
        let t = """
        {
            "expression": "$response.body"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .response(.body(nil))
        )
    }

    func test_responseBody_encode() throws {
        let wrapper = Wrapper(expression: .response(.body(nil)))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$response.body"
            }
            """
        )
    }

    func test_responseBodyPath_decode() throws {
        let t = """
        {
            "expression": "$response.body#/data/type"
        }
        """.data(using: .utf8)!

        let wrapper = try orderUnstableDecode(Wrapper.self, from: t)

        XCTAssertEqual(
            wrapper.expression,
            .response(.body(.path("/data/type")))
        )
    }

    func test_responseBodyPath_encode() throws {
        let wrapper = Wrapper(expression: .response(.body(.path("/data/type"))))

        let t = try orderUnstableTestStringFromEncoding(of: wrapper)

        XCTAssertEqual(
            t,
            """
            {
              "expression" : "$response.body#\\/data\\/type"
            }
            """
        )
    }

    // MARK: - Failures

    func test_urlTypo() throws {
        let t = """
        {
            "expression": "$urll"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(Wrapper.self, from: t))
    }

    func test_noRequestSource() throws {
        let t = """
        {
            "expression": "$request."
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(Wrapper.self, from: t))
    }

    func test_noResponseSource() throws {
        let t = """
        {
            "expression": "$response."
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(Wrapper.self, from: t))
    }

    struct Wrapper: Codable {
        public let expression: OpenAPI.RuntimeExpression
    }
}
