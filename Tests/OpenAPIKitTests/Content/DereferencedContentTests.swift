//
//  DereferencedContentTests.swift
//  
//
//  Created by Mathew Polzin on 6/21/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class DereferencedContentTests: XCTestCase {
    func test_oneExampleInline() throws {
        let t1 = try DereferencedContent(OpenAPI.Content(schema: .string, example: "hello world"), resolvingIn: .noComponents)
        XCTAssertEqual(t1.example, "hello world")
    }

    func test_oneExampleReferenced() throws {
        let components = OpenAPI.Components(
            examples: ["test": .init(value: .init("hello world"))]
        )
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schema: .string,
                examples: ["test": .reference(.component(named: "test"))]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(t1.examples, ["test": .init(value: .init("hello world"))])
    }

    func test_multipleExamplesReferenced() throws {
        let components = OpenAPI.Components(
            examples: [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .a(URL(string: "http://website.com")!))
            ]
        )
        let t1 = try DereferencedContent(
            OpenAPI.Content(
                schema: .string,
                examples: [
                    "test1": .reference(.component(named: "test1")),
                    "test2": .reference(.component(named: "test2"))
                ]
            ),
            resolvingIn: components
        )
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(
            t1.examples,
            [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .init(URL(string: "http://website.com")!))
            ]
        )
    }
}
