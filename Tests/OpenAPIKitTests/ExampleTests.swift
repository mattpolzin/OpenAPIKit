//
//  ExampleTests.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class ExampleTests: XCTestCase {
    func test_init() {
        let full1 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            legacyValue: .b(.init(URL(string: "https://google.com")!)),
            vendorExtensions: ["hello": "world"]
        )

        XCTAssertEqual(full1.summary, "hello")
        XCTAssertEqual(full1.description, "world")
        XCTAssertEqual(full1.value?.value, .init(URL(string: "https://google.com")!))
        XCTAssertEqual(full1.legacyValue, .init(URL(string: "https://google.com")!))
        XCTAssertEqual(full1.dataOrLegacyValue, .init(URL(string: "https://google.com")!))
        XCTAssertEqual(full1.vendorExtensions["hello"]?.value as? String, "world")
        XCTAssertEqual(full1.conditionalWarnings.count, 0)

        let full2 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            dataValue: .init("hello"),
            vendorExtensions: ["hello": "world"]
        )
        XCTAssertEqual(full2.summary, "hello")
        XCTAssertEqual(full2.description, "world")
        XCTAssertEqual(full2.value?.value, .init("hello"))
        XCTAssertEqual(full2.dataValue, .init("hello"))
        XCTAssertEqual(full2.dataOrLegacyValue, .init("hello"))
        XCTAssertEqual(full2.vendorExtensions["hello"]?.value as? String, "world")
        XCTAssertEqual(full2.conditionalWarnings.count, 1)

        let full3 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            externalValue: URL(string: "https://google.com")!,
            vendorExtensions: ["hello": "world"]
        )

        XCTAssertEqual(full3.summary, "hello")
        XCTAssertEqual(full3.description, "world")
        XCTAssertEqual(full3.externalValue, URL(string: "https://google.com")!)
        XCTAssertEqual(full3.vendorExtensions["hello"]?.value as? String, "world")
        XCTAssertEqual(full3.conditionalWarnings.count, 0)

        let dataPlusSerialized = OpenAPI.Example(
            summary: "hello",
            dataValue: .init("hello"),
            serializedValue: "hello"
        )
        XCTAssertEqual(dataPlusSerialized.summary, "hello")
        XCTAssertEqual(dataPlusSerialized.dataValue, .init("hello"))
        XCTAssertEqual(dataPlusSerialized.serializedValue, "hello")
        XCTAssertEqual(dataPlusSerialized.conditionalWarnings.count, 2)

        let small = OpenAPI.Example(serializedValue: "hello")
        XCTAssertNil(small.summary)
        XCTAssertNil(small.description)
        XCTAssertEqual(small.serializedValue, "hello")
        XCTAssertEqual(small.vendorExtensions, [:])
        XCTAssertEqual(small.conditionalWarnings.count, 1)

        let noValue = OpenAPI.Example()
        XCTAssertNil(noValue.summary)
        XCTAssertNil(noValue.description)
        XCTAssertNil(noValue.value)
        XCTAssertEqual(noValue.vendorExtensions, [:])
        XCTAssertEqual(noValue.conditionalWarnings.count, 0)

        let _ = OpenAPI.Example(legacyValue: .b(.init(["hi": "hello"])))
        let _ = OpenAPI.Example(legacyValue: .b("<hi>hello</hi>"))
    }

    func test_locallyDereferenceable() throws {
        // should just be self
        let full1 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            dataValue: .init(URL(string: "https://google.com")!),
            vendorExtensions: ["hello": "world"]
        )
        XCTAssertEqual(try full1.dereferenced(in: .noComponents), full1)

        let full2 = OpenAPI.Example(
            summary: "hello",
            description: "world",
            serializedValue: "hello",
            vendorExtensions: ["hello": "world"]
        )
        XCTAssertEqual(try full2.dereferenced(in: .noComponents), full2)

        let small = OpenAPI.Example(legacyValue: .init("hello"))
        XCTAssertEqual(try small.dereferenced(in: .noComponents), small)

        let noValue = OpenAPI.Example()
        XCTAssertEqual(try noValue.dereferenced(in: .noComponents), noValue)
    }
}

// MARK: - Codable
extension ExampleTests {
    func test_summaryAndExternalExample_encode() throws {
        let example = OpenAPI.Example(
            summary: "hello",
            legacyValue: .init(URL(string: "https://google.com")!)
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
                                                legacyValue: .init(URL(string: "https://google.com")!)))
        XCTAssertEqual(example.externalValue, URL(string: "https://google.com")!)
    }

    func test_descriptionAndInternalExample_encode() throws {
        let example = OpenAPI.Example(
            description: "hello",
            serializedValue: "world"
        )
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "description" : "hello",
              "serializedValue" : "world"
            }
            """
        )
    }

    func test_descriptionAndInternalExample_decode() throws {
        let exampleData =
        """
        {
          "description" : "hello",
          "serializedValue" : "world"
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(description: "hello",
                                                serializedValue: "world"))
    }

    func test_vendorExtensionAndInternalExample_encode() throws {
        let example = OpenAPI.Example(dataValue: .init("world"),
                                      vendorExtensions: ["x-hello": 10])
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "dataValue" : "world",
              "x-hello" : 10
            }
            """
        )
    }

    func test_vendorExtensionAndInternalExample_decode() {
        let exampleData =
        """
        {
          "dataValue" : "world",
          "x-hello" : 10
        }
        """.data(using: .utf8)!

        let example = try! orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(dataValue: .init("world"),
                                                vendorExtensions: ["x-hello": 10]))
    }

    func test_internalLegacyExample_encode() {
        let example = OpenAPI.Example(legacyValue: .b(.init(["hi": "world"])))
        let encodedExample = try! orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "value" : {
                "hi" : "world"
              }
            }
            """
        )
    }

    func test_internalLegacyExample_decode() throws {
        let exampleData =
        """
        {
            "value" : {
              "hi" : "world"
            }
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(legacyValue: .b(.init(["hi": "world"]))))
    }

    func test_internalExample_encode() {
        let example = OpenAPI.Example(dataValue: .init(["hi": "world"]))
        let encodedExample = try! orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {
              "dataValue" : {
                "hi" : "world"
              }
            }
            """
        )
    }

    func test_internalExample_decode() throws {
        let exampleData =
        """
        {
            "dataValue" : {
              "hi" : "world"
            }
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example(dataValue: .init(["hi": "world"])))
    }

    func test_externalExample_encode() throws {
        let example = OpenAPI.Example(externalValue: URL(string: "https://google.com")!)
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

        XCTAssertEqual(example, OpenAPI.Example(externalValue: URL(string: "https://google.com")!))
    }

    func test_noExample_encode() throws {
        let example = OpenAPI.Example()
        let encodedExample = try orderUnstableTestStringFromEncoding(of: example)

        assertJSONEquivalent(
            encodedExample,
            """
            {

            }
            """
        )
    }

    func test_noExample_decode() throws {
        let exampleData =
        """
        {
        }
        """.data(using: .utf8)!

        let example = try orderUnstableDecode(OpenAPI.Example.self, from: exampleData)

        XCTAssertEqual(example, OpenAPI.Example())
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
