//
//  DiscriminatorTests.swift
//  
//
//  Created by Mathew Polzin on 11/3/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class DiscriminatorTests: XCTestCase {
    func test_init() {
        let t1 = OpenAPI.Discriminator(propertyName: "hello world")
        XCTAssertEqual(t1.propertyName, "hello world")
        XCTAssertNil(t1.mapping)

        let t2 = OpenAPI.Discriminator(propertyName: "hello world",
                                       mapping: ["hello": "world"])
        XCTAssertEqual(t2.propertyName, "hello world")
        XCTAssertEqual(t2.mapping, ["hello": "world"])
    }
}

// MARK: - Codable
extension DiscriminatorTests {
    func test_noMapping_encode() {
        let discriminator = OpenAPI.Discriminator(propertyName: "hello")
        let encodedDiscriminator = try! testStringFromEncoding(of: discriminator)

        XCTAssertEqual(encodedDiscriminator,
"""
{
  "propertyName" : "hello"
}
"""
        )
    }

    func test_noMapping_decode() {
        let discriminatorData =
"""
{
    "propertyName": "hello"
}
""".data(using: .utf8)!
        let discriminator = try! testDecoder.decode(OpenAPI.Discriminator.self, from: discriminatorData)

        XCTAssertEqual(discriminator, OpenAPI.Discriminator(propertyName: "hello"))
    }

    func test_withMapping_encode() {
        let discriminator = OpenAPI.Discriminator(propertyName: "hello",
                                                  mapping: ["hello": "world"])
        let encodedDiscriminator = try! testStringFromEncoding(of: discriminator)

        XCTAssertEqual(encodedDiscriminator,
"""
{
  "mapping" : {
    "hello" : "world"
  },
  "propertyName" : "hello"
}
"""
        )
    }

    func test_withMapping_decode() {
        let discriminatorData =
"""
{
    "propertyName": "hello",
    "mapping": {
        "hello": "world"
    }
}
""".data(using: .utf8)!
        let discriminator = try! testDecoder.decode(OpenAPI.Discriminator.self, from: discriminatorData)

        XCTAssertEqual(discriminator, OpenAPI.Discriminator(propertyName: "hello",
                                                            mapping: [ "hello": "world"]))
    }
}
