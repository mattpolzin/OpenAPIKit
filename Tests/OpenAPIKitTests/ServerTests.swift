//
//  ServerTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import XCTest
import OpenAPIKit

class ServerTests: XCTestCase {
    typealias Server = OpenAPI.Server

    func test_serverVariableInitialization() {
        let v1 = Server.Variable(default: "hello")

        XCTAssertEqual(v1.default, "hello")
        XCTAssertEqual(v1.enum, [])
        XCTAssertNil(v1.description)

        let v2 = Server.Variable(enum: ["hello"],
                                 default: "hello",
                                 description: "hello world")
        XCTAssertEqual(v2.enum, ["hello"])
        XCTAssertEqual(v2.default, "hello")
        XCTAssertEqual(v2.description, "hello world")
    }

    func test_serverInitialization() {
        let s1 = Server(url: URL(string: "https://hello.com")!)

        XCTAssertEqual(s1.urlTemplate, TemplatedURL(rawValue: "https://hello.com")!)
        XCTAssertNil(s1.description)
        XCTAssertEqual(s1.variables, [:])

        let variable = Server.Variable(default: "world")
        let s2 = Server(url: URL(string: "https://hello.com")!,
                        description: "hello world",
                        variables: [
                            "hello": variable
            ])

        XCTAssertEqual(s2.urlTemplate, TemplatedURL(rawValue: "https://hello.com")!)
        XCTAssertEqual(s2.description, "hello world")
        XCTAssertEqual(s2.variables, ["hello": variable])
    }
}

// MARK: - Codable
extension ServerTests {
    func test_minimalServer_decode() {
        let serverData =
"""
{
    "url": "https://hello.com"
}
""".data(using: .utf8)!

        let serverDecoded = try! orderUnstableDecode(Server.self, from: serverData)

        XCTAssertEqual(serverDecoded, Server(url: URL(string: "https://hello.com")!))
    }

    func test_minimalServer_encode() {
        let server = Server(url: URL(string: "https://hello.com")!)
        let encodedServer = try! orderUnstableTestStringFromEncoding(of: server)

        assertJSONEquivalent(encodedServer,
"""
{
  "url" : "https:\\/\\/hello.com"
}
"""
                       )
    }

    func test_minimalServerVariable_decode() {
        let serverData =
"""
{
    "url": "https://hello.com",
    "variables": {
        "world": {
            "default": "cool"
        }
    }
}
""".data(using: .utf8)!

        let serverDecoded = try! orderUnstableDecode(Server.self, from: serverData)

        XCTAssertEqual(
            serverDecoded,
            Server(
                url: URL(string: "https://hello.com")!,
                variables: [
                    "world": .init(
                        default: "cool"
                    )
                ]
            )
        )
    }

    func test_minimalServerVariable_encode() {
        let server = Server(
            url: URL(string: "https://hello.com")!,
            variables: [
                "world": .init(
                    default: "cool"
                )
            ]
        )
        let encodedServer = try! orderUnstableTestStringFromEncoding(of: server)

        assertJSONEquivalent(encodedServer,
"""
{
  "url" : "https:\\/\\/hello.com",
  "variables" : {
    "world" : {
      "default" : "cool"
    }
  }
}
"""
        )
    }

    func test_maximalServer_decode() {
        let serverData =
"""
{
    "url": "https://hello.com",
    "description": "hello world",
    "variables": {
        "hello": {
            "enum": ["hello"],
            "default": "hello",
            "description": "hello again",
            "x-otherThing": 1234
        }
    },
    "x-specialFeature": [
        "hello",
        "world"
    ]
}
""".data(using: .utf8)!

        let serverDecoded = try! orderUnstableDecode(Server.self, from: serverData)

        XCTAssertEqual(
            serverDecoded,
            Server(
                url: URL(string: "https://hello.com")!,
                description: "hello world",
                variables: [
                    "hello": .init(
                        enum: ["hello"],
                        default: "hello",
                        description: "hello again",
                        vendorExtensions: [ "x-otherThing": 1234 ]
                    )
                ],
                vendorExtensions: ["x-specialFeature": ["hello", "world"]]
            )
        )
    }

    func test_maximalServer_encode() {
        let server = Server(
            url: URL(string: "https://hello.com")!,
            description: "hello world",
            variables: [
                "hello": .init(
                    enum: ["hello"],
                    default: "hello",
                    description: "hello again",
                    vendorExtensions: [ "x-otherThing": 1234 ]
                )
            ],
            vendorExtensions: ["x-specialFeature": ["hello", "world"]]
        )
        let encodedServer = try! orderUnstableTestStringFromEncoding(of: server)

        assertJSONEquivalent(encodedServer,
"""
{
  "description" : "hello world",
  "url" : "https:\\/\\/hello.com",
  "variables" : {
    "hello" : {
      "default" : "hello",
      "description" : "hello again",
      "enum" : [
        "hello"
      ],
      "x-otherThing" : 1234
    }
  },
  "x-specialFeature" : [
    "hello",
    "world"
  ]
}
"""
        )
    }
}
