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
        let t1 = try OpenAPI.Content(schema: .string, example: "hello world").dereferenced(in: .noComponents)
        XCTAssertEqual(t1.example, "hello world")
    }

    func test_oneExampleReferenced() throws {
        let components = OpenAPI.Components(
            examples: ["test": .init(value: .init("hello world"))]
        )
        let t1 = try OpenAPI.Content(
            schema: .string,
            examples: ["test": .reference(.component(named: "test"))]
        ).dereferenced(in: components)
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
        let t1 = try OpenAPI.Content(
            schema: .string,
            examples: [
                "test1": .reference(.component(named: "test1")),
                "test2": .reference(.component(named: "test2"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.example, "hello world")
        XCTAssertEqual(
            t1.examples,
            [
                "test1": .init(value: .init("hello world")),
                "test2": .init(value: .init(URL(string: "http://website.com")!))
            ]
        )
    }

    func test_missingExample() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(
            try OpenAPI.Content(
                schema: .string,
                examples: ["test": .reference(.component(named: "test"))]
            ).dereferenced(in: components)
        )
    }

    func test_inlineSchema() throws {
        let t1 = try OpenAPI.Content(schema: .string).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.schema, .string(.init(), .init()))
    }

    func test_referencedSchema() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )
        let t1 = try OpenAPI.Content(
            schemaReference: .component(named: "test")
        ).dereferenced(in: components)
        XCTAssertEqual(t1.schema, .string(.init(), .init()))
    }

    func test_missingSchema() {
        XCTAssertThrowsError(
            try OpenAPI.Content(
                schemaReference: .component(named: "missing")
            ).dereferenced(in: .noComponents)
        )
    }

    func test_inlineEncoding() throws {
        let t1 = try OpenAPI.Content(schema: .string, encoding: ["test": .init()]).dereferenced(in: .noComponents)
        XCTAssertNotNil(t1.encoding?["test"])
        XCTAssertNil(t1.encoding?["test"]?.headers)
    }

    func test_referencedHeaderInEncoding() throws {
        let components = OpenAPI.Components(
            headers: [
                "test": OpenAPI.Header(schema: .string)
            ]
        )
        let t1 = try OpenAPI.Content(
            schema: .string,
            encoding: [
                "test": .init(
                    headers: [
                        "test": .reference(.component(named: "test"))
                    ]
                )
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(
            t1.encoding?["test"]?.headers?["test"]?.schemaOrContent.schemaValue,
            DereferencedJSONSchema.string(.init(), .init())
        )
        // just test that dynamic member lookup is connected correctly
        XCTAssertEqual(t1.encoding?["test"]?.style, OpenAPI.Content.Encoding.defaultStyle)
    }

    func test_missingHeaderInEncoding() {
        XCTAssertThrowsError(
            try OpenAPI.Content(
                schema: .string,
                encoding: [
                    "test": .init(
                        headers: [
                            "test": .reference(.component(named: "test"))
                        ]
                    )
                ]
            ).dereferenced(in: .noComponents)
        )
    }

    func test_vendorExtensionThroughUnderlyingContent() throws {
        let content = OpenAPI.Content(schema: .string, vendorExtensions: ["hello": "world"])
        let dereferencedContent = try content.dereferenced(in: .noComponents)
        XCTAssertEqual(dereferencedContent.vendorExtensions, content.vendorExtensions)
    }
}
