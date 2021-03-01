//
//  ExampleTests.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation
import OpenAPIKit30
import XCTest

final class ExampleTests: XCTestCase {
    func test_init() {
        let full1 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            value: .init(URL(string: "https://google.com")!),
            vendorExtensions: ["hello": "world"]
        )

        XCTAssertEqual(full1.summary, "hello")
        XCTAssertEqual(full1.description, "world")
        XCTAssertEqual(full1.value, .init(URL(string: "https://google.com")!))
        XCTAssertEqual(full1.vendorExtensions["hello"]?.value as? String, "world")

        let full2 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            value: .init("hello"),
            vendorExtensions: ["hello": "world"]
        )

        XCTAssertEqual(full2.summary, "hello")
        XCTAssertEqual(full2.description, "world")
        XCTAssertEqual(full2.value, .init("hello"))
        XCTAssertEqual(full2.vendorExtensions["hello"]?.value as? String, "world")

        let small = OpenAPI.Example(value: .init("hello"))
        XCTAssertNil(small.summary)
        XCTAssertNil(small.description)
        XCTAssertEqual(small.value, .init("hello"))
        XCTAssertEqual(small.vendorExtensions, [:])
    }

    func test_locallyDereferenceable() throws {
        // should just be self
        let full1 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            value: .init(URL(string: "https://google.com")!),
            vendorExtensions: ["hello": "world"]
        )
        XCTAssertEqual(try full1.dereferenced(in: .noComponents), full1)

        let full2 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            value: .init("hello"),
            vendorExtensions: ["hello": "world"]
        )
        XCTAssertEqual(try full2.dereferenced(in: .noComponents), full2)

        let small = OpenAPI.Example(value: .init("hello"))
        XCTAssertEqual(try small.dereferenced(in: .noComponents), small)
    }
}

// MARK: - Codable
extension ExampleTests {
    func test_summaryAndExternalExample_encode() throws {
        let example = OpenAPI.Example(
            summary: "hello",
            value: .init(URL(string: "https://google.com")!)
        )
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "externalValue" : "https:\\/\\/google.com",
              "summary" : "hello"
            }
            """
        )
    }

    func test_summaryAndExternalExample_decode() throws {
        let exampleData =
        """
        {
            "externalValue": "https://google.com",
            "summary": "hello"
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(summary: "hello",
                                                value: .init(URL(string: "https://google.com")!)))
        XCTAssertEqual(example.value.urlValue, URL(string: "https://google.com")!)
    }

    func test_descriptionAndInternalExample_encode() throws {
        let example = OpenAPI.Example(
            description: "hello",
            value: .init("world")
        )
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "description" : "hello",
              "value" : "world"
            }
            """
        )
    }

    func test_descriptionAndInternalExample_decode() throws {
        let exampleData =
        """
        {
          "description" : "hello",
          "value" : "world"
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(description: "hello",
                                                value: .init("world")))
    }

    func test_vendorExtensionAndInternalExample_encode() throws {
        let example = OpenAPI.Example(value: .init("world"),
                                      vendorExtensions: ["x-hello": 10])
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "value" : "world",
              "x-hello" : 10
            }
            """
        )
    }

    func test_vendorExtensionAndInternalExample_decode() {
        let exampleData =
        """
        {
          "value" : "world",
          "x-hello" : 10
        }
        """.data(using: .utf8)!

        let example = try! orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(value: .init("world"),
                                                vendorExtensions: ["x-hello": 10]))
    }

    func test_internalExample_encode() {
        let example = OpenAPI.Example(value: .init("world"))
        let encodedExample = try! orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "value" : "world"
            }
            """
        )
    }

    func test_internalExample_decode() throws {
        let exampleData =
        """
        {
          "value" : "world"
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(value: .init("world")))
    }

    func test_externalExample_encode() throws {
        let example = OpenAPI.Example(value: .init(URL(string: "https://google.com")!))
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "externalValue" : "https:\\/\\/google.com"
            }
            """
        )
    }

    func test_externalExample_decode() throws {
        let exampleData =
        """
        {
          "externalValue" : "https://google.com"
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(value: .init(URL(string: "https://google.com")!)))
    }

    func test_failedDecodeForInternalAndExternalExamples() {
        let exampleData =
        """
        {
            "externalValue": "https://google.com",
            "value": "world"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(OpenAPI.Example.self, from: exampleData))
    }
}
