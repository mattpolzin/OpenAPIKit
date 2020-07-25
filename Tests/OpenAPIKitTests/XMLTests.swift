//
//  XMLTests.swift
//  
//
//  Created by Mathew Polzin on 1/15/20.
//

import OpenAPIKit
import XCTest

final class XMLTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.XML()
        let _ = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            attribute: true,
            wrapped: true
        )
    }
}

// MARK: - Codable Tests
extension XMLTests {
    func test_empty_encode() throws {
        let xml = OpenAPI.XML()
        let encodedXML = try orderUnstableTestStringFromEncoding(of: xml)

        assertJSONEquivalent(
            encodedXML,
"""
{

}
"""
            )
    }

    func test_empty_decode() throws {
        let xmlData =
"""
{

}
""".data(using: .utf8)!

        let xml = try orderUnstableDecode(OpenAPI.XML.self, from: xmlData)

        XCTAssertEqual(
            xml,
            OpenAPI.XML()
        )
    }

    func test_complete_encode() throws {
        let xml = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            attribute: true,
            wrapped: true
        )
        let encodedXML = try orderUnstableTestStringFromEncoding(of: xml)

        assertJSONEquivalent(
            encodedXML,
"""
{
  "attribute" : true,
  "name" : "hello",
  "namespace" : "http:\\/\\/hello.world.com",
  "prefix" : "there",
  "wrapped" : true
}
"""
        )
    }

    func test_complete_decode() throws {
        let xmlData =
"""
{
  "attribute" : true,
  "name" : "hello",
  "namespace" : "http:\\/\\/hello.world.com",
  "prefix" : "there",
  "wrapped" : true
}
""".data(using: .utf8)!

        let xml = try orderUnstableDecode(OpenAPI.XML.self, from: xmlData)

        XCTAssertEqual(
            xml,
            OpenAPI.XML(
                name: "hello",
                namespace: URL(string: "http://hello.world.com")!,
                prefix: "there",
                attribute: true,
                wrapped: true
            )
        )
    }
}
