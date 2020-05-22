//
//  ExternalDocumentationTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 10/18/19.
//

import XCTest
import OpenAPIKit

final class ExternalDocumentationTests: XCTestCase {
    func test_init() {
        let t1 = OpenAPI.ExternalDocumentation(url: URL(string: "http://google.com")!)
        XCTAssertNil(t1.description)

        let t2 = OpenAPI.ExternalDocumentation(description: "hello world",
                                     url: URL(string: "http://google.com")!)
        XCTAssertEqual(t2.description, "hello world")
    }
}

// MARK: - Codable
extension ExternalDocumentationTests {
    func test_descriptionAndUrlAndExtension_encode() {
        let externalDoc = OpenAPI.ExternalDocumentation(
            description: "hello world",
            url: URL(string: "http://google.com")!,
            vendorExtensions: [ "x-specialFeature": "hi" ]
        )

        let encodedExternalDoc = try! testStringFromEncoding(of: externalDoc)

        assertJSONEquivalent(encodedExternalDoc,
"""
{
  "description" : "hello world",
  "url" : "http:\\/\\/google.com",
  "x-specialFeature" : "hi"
}
"""
        )
    }

    func test_descriptionAndUrlAndExtension_decode() {
        let externalDocsData =
"""
{
  "description" : "hello world",
  "url" : "http:\\/\\/google.com",
  "x-specialFeature" : "hi"
}
""".data(using: .utf8)!
        let externalDocs = try! testDecoder.decode(OpenAPI.ExternalDocumentation.self, from: externalDocsData)

        XCTAssertEqual(
            externalDocs,
            OpenAPI.ExternalDocumentation(
                description: "hello world",
                url: URL(string: "http://google.com")!,
                vendorExtensions: [ "x-specialFeature": "hi" ]
            )
        )
    }

    func test_descriptionAndUrl_encode() {
        let externalDoc = OpenAPI.ExternalDocumentation(description: "hello world",
                                              url: URL(string: "http://google.com")!)

        let encodedExternalDoc = try! testStringFromEncoding(of: externalDoc)

        assertJSONEquivalent(encodedExternalDoc,
"""
{
  "description" : "hello world",
  "url" : "http:\\/\\/google.com"
}
"""
        )
    }

    func test_descriptionAndUrl_decode() {
        let externalDocsData =
"""
{
  "description" : "hello world",
  "url" : "http:\\/\\/google.com"
}
""".data(using: .utf8)!
        let externalDocs = try! testDecoder.decode(OpenAPI.ExternalDocumentation.self, from: externalDocsData)

        XCTAssertEqual(externalDocs, OpenAPI.ExternalDocumentation(description: "hello world",
                                                url: URL(string: "http://google.com")!))
    }

    func test_onlyUrl_encode() {
        let externalDoc = OpenAPI.ExternalDocumentation(url: URL(string: "http://google.com")!)

        let encodedExternalDoc = try! testStringFromEncoding(of: externalDoc)

        assertJSONEquivalent(encodedExternalDoc,
"""
{
  "url" : "http:\\/\\/google.com"
}
"""
        )
    }

    func test_onlyUrl_decode() {
        let externalDocsData =
"""
{
  "url" : "http:\\/\\/google.com"
}
""".data(using: .utf8)!
        let externalDocs = try! testDecoder.decode(OpenAPI.ExternalDocumentation.self, from: externalDocsData)

        XCTAssertEqual(externalDocs, OpenAPI.ExternalDocumentation(url: URL(string: "http://google.com")!))
    }
}
