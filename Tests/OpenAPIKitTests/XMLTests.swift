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
        let t1 = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            attribute: true,
            wrapped: true
        )
        XCTAssertEqual(t1.structure, .legacy(attribute: true, wrapped: true))
        XCTAssertEqual(t1.conditionalWarnings.count, 0)

        let t2 = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            nodeType: nil
        )
        XCTAssertEqual(t2.structure, nil)
        XCTAssertEqual(t2.conditionalWarnings.count, 0)

        let t3 = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            nodeType: .text
        )
        XCTAssertEqual(t3.structure, .nodeType(.text))
        XCTAssertEqual(t3.conditionalWarnings.count, 1)
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

    func test_completeLegacy_encode() throws {
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

    func test_completeLegacy_decode() throws {
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
        XCTAssertEqual(xml.conditionalWarnings.count, 0)

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

    func test_complete_encode() throws {
        let xml = OpenAPI.XML(
            name: "hello",
            namespace: URL(string: "http://hello.world.com")!,
            prefix: "there",
            nodeType: .text
        )
        let encodedXML = try orderUnstableTestStringFromEncoding(of: xml)

        assertJSONEquivalent(
            encodedXML,
            """
            {
              "name" : "hello",
              "namespace" : "http:\\/\\/hello.world.com",
              "nodeType" : "text",
              "prefix" : "there"
            }
            """
        )
    }

    func test_complete_decode() throws {
        let xmlData =
        """
        {
          "name" : "hello",
          "namespace" : "http:\\/\\/hello.world.com",
          "nodeType" : "text",
          "prefix" : "there"
        }
        """.data(using: .utf8)!

        let xml = try orderUnstableDecode(OpenAPI.XML.self, from: xmlData)
        
        XCTAssertEqual(xml.conditionalWarnings.count, 1)

        XCTAssertEqual(
            xml,
            OpenAPI.XML(
                name: "hello",
                namespace: URL(string: "http://hello.world.com")!,
                prefix: "there",
                nodeType: .text
            )
        )
    }
}
