//
//  ExternalDocTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 10/18/19.
//

import XCTest
import OpenAPIKit

final class ExternalDocTests: XCTestCase {
    func test_init() {
        let t1 = OpenAPI.ExternalDoc(url: URL(string: "http://google.com")!)
        XCTAssertNil(t1.description)

        let t2 = OpenAPI.ExternalDoc(description: "hello world",
                                     url: URL(string: "http://google.com")!)
        XCTAssertEqual(t2.description, "hello world")
    }
}

// MARK: - Codable
extension ExternalDocTests {
    func test_descriptionAndUrl_encode() {
        let externalDoc = OpenAPI.ExternalDoc(description: "hello world",
                                              url: URL(string: "http://google.com")!)

        let encodedExternalDoc = try! testStringFromEncoding(of: externalDoc)

        XCTAssertEqual(encodedExternalDoc,
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
        let externalDocs = try! testDecoder.decode(OpenAPI.ExternalDoc.self, from: externalDocsData)

        XCTAssertEqual(externalDocs, OpenAPI.ExternalDoc(description: "hello world",
                                                url: URL(string: "http://google.com")!))
    }

    func test_onlyUrl_encode() {
        let externalDoc = OpenAPI.ExternalDoc(url: URL(string: "http://google.com")!)

        let encodedExternalDoc = try! testStringFromEncoding(of: externalDoc)

        XCTAssertEqual(encodedExternalDoc,
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
        let externalDocs = try! testDecoder.decode(OpenAPI.ExternalDoc.self, from: externalDocsData)

        XCTAssertEqual(externalDocs, OpenAPI.ExternalDoc(url: URL(string: "http://google.com")!))
    }
}
