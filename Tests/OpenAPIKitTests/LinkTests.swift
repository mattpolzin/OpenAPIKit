//
//  LinkTests.swift
//  
//
//  Created by Mathew Polzin on 1/23/20.
//

import OpenAPIKit
import Foundation
import XCTest

final class LinkTests: XCTestCase {
    typealias Link = OpenAPI.Link

    func test_linkInitialization() {
        let link1 = Link(operation: .a(URL(string: "http://website.com")!))
        let link2 = Link(operation: .b("op1"))
        let link3 = Link(operationRef: URL(string: "http://website.com")!)
        let link4 = Link(operationId: "op1")

        XCTAssertEqual(link1, link3)
        XCTAssertEqual(link2, link4)

        let either1: Either<OpenAPI.Reference<Link>, Link> = .link(operationRef: URL(string: "http://website.com")!)
        let either2: Either<OpenAPI.Reference<Link>, Link> = .link(operationId: "op1")

        XCTAssertEqual(either1.linkValue, link1)
        XCTAssertEqual(either2.linkValue, link2)
    }
}

// MARK: - Codable
extension LinkTests {
    func test_minimalLink_decode() throws {
        let linkData =
            """
        {
            "operationRef": "http://website.com"
        }
        """.data(using: .utf8)!

        let linkDecoded = try orderUnstableDecode(Link.self, from: linkData)

        XCTAssertEqual(linkDecoded, Link(operationRef: URL(string: "http://website.com")!))

        let linkData2 =
            """
        {
            "operationId": "op1"
        }
        """.data(using: .utf8)!

        let linkDecoded2 = try orderUnstableDecode(Link.self, from: linkData2)

        XCTAssertEqual(linkDecoded2, Link(operationId: "op1"))
    }

    func test_minimalLink_encode() throws {
        let link = Link(operationRef: URL(string: "http://website.com")!)
        let encodedLink = try orderUnstableTestStringFromEncoding(of: link)

        assertJSONEquivalent(
            encodedLink,
            """
            {
              "operationRef" : "http:\\/\\/website.com"
            }
            """
        )

        let link2 = Link(operationId: "op1")
        let encodedLink2 = try orderUnstableTestStringFromEncoding(of: link2)

        assertJSONEquivalent(
            encodedLink2,
            """
            {
              "operationId" : "op1"
            }
            """
        )
    }

    func test_populatedParameters_encode() {
        let link = Link(
            operationId: "op1",
            parameters: [
                "param": .b(true)
            ]
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: link)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "operationId" : "op1",
              "parameters" : {
                "param" : true
              }
            }
            """
        )
    }

    func test_populatedParameters_decode() throws {

        let responseData =
            """
        {
          "operationId" : "op1",
          "parameters" : {
            "param" : true
          }
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Link.self, from: responseData)

        XCTAssertEqual(
            response,
            Link(
                operationId: "op1",
                parameters: [
                    "param": .b(true)
                ]
            )
        )
    }

    func test_populatedExtension_encode() {
        let link = Link(
            operationId: "op1",
            vendorExtensions: ["x-specialFeature" : true]
        )

        let encodedResponse = try! orderUnstableTestStringFromEncoding(of: link)

        assertJSONEquivalent(
            encodedResponse,
            """
            {
              "operationId" : "op1",
              "x-specialFeature" : true
            }
            """
        )
    }

    func test_Extension_decode() throws {

        let responseData =
            """
        {
          "operationId" : "op1",
          "x-specialFeature" : true
        }
        """.data(using: .utf8)!

        let response = try orderUnstableDecode(OpenAPI.Link.self, from: responseData)

        XCTAssertEqual(
            response,
            Link(
                operationId: "op1",
                vendorExtensions: ["x-specialFeature" : true]
            )
        )
    }
}
