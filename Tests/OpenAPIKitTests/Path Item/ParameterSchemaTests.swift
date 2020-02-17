//
//  ParameterSchemaTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ParameterSchemaTests: XCTestCase {
    typealias Schema = OpenAPI.PathItem.Parameter.Schema

    func test_initialize() {
        // init specifying opposite of default explode and allowReserved.
        let t1 = Schema(
            .string,
            style: .form,
            explode: false,
            allowReserved: true,
            example: "hello"
        )

        XCTAssertEqual(t1.schema, .b(.string))
        XCTAssertEqual(t1.style, .form)
        XCTAssertFalse(t1.explode)
        XCTAssertTrue(t1.allowReserved)
        XCTAssertEqual(t1.example?.value as? String, "hello")
        XCTAssertNil(t1.examples)

        // init with defaults
        let t2 = Schema(
            .string,
            style: .form
        )

        XCTAssertEqual(t2.schema, .b(.string))
        XCTAssertEqual(t2.style, .form)
        XCTAssertTrue(t2.explode)
        XCTAssertFalse(t2.allowReserved)
        XCTAssertNil(t2.example)
        XCTAssertNil(t2.examples)

        // schema reference override explode
        let t3 = Schema(
            schemaReference: .external("hello.yml"),
            style: .deepObject,
            explode: true
        )

        XCTAssertEqual(t3.schema, .a(.external("hello.yml")))
        XCTAssertEqual(t3.style, .deepObject)
        XCTAssertTrue(t3.explode)
        XCTAssertFalse(t3.allowReserved)
        XCTAssertNil(t3.example)
        XCTAssertNil(t3.examples)

        // schema reference default explode
        let t4 = Schema(
            schemaReference: .external("hello.yml"),
            style: .deepObject
        )

        XCTAssertEqual(t4.schema, .a(.external("hello.yml")))
        XCTAssertEqual(t4.style, .deepObject)
        XCTAssertFalse(t4.explode)
        XCTAssertFalse(t4.allowReserved)
        XCTAssertNil(t4.example)
        XCTAssertNil(t4.examples)

        // straight to schema override explode
        let t5 = Schema(
            .string,
            style: .deepObject,
            explode: true
        )

        XCTAssertEqual(t5.schema, .b(.string))
        XCTAssertEqual(t5.style, .deepObject)
        XCTAssertTrue(t5.explode)
        XCTAssertFalse(t5.allowReserved)
        XCTAssertNil(t5.example)
        XCTAssertNil(t5.examples)

        // straight to schema default explode
        let t6 = Schema(
            .string,
            style: .deepObject
        )

        XCTAssertEqual(t6.schema, .b(.string))
        XCTAssertEqual(t6.style, .deepObject)
        XCTAssertFalse(t6.explode)
        XCTAssertFalse(t6.allowReserved)
        XCTAssertNil(t6.example)
        XCTAssertNil(t6.examples)

        // straight to schema multiple examples
        let t7 = Schema(
            .string,
            style: .deepObject,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(value: .init("world"))
            ]
        )

        XCTAssertEqual(t7.schema, .b(.string))
        XCTAssertEqual(t7.style, .deepObject)
        XCTAssertFalse(t7.explode)
        XCTAssertFalse(t7.allowReserved)
        XCTAssertNotNil(t7.example)
        XCTAssertEqual(t7.example?.value as? String, "hello")
        XCTAssertNotNil(t7.examples)
        XCTAssertEqual(t7.examples?["two"]?.b?.value.b?.value as? String, "world")

        // straight to schema override explode multiple examples
        let t8 = Schema(
            .string,
            style: .deepObject,
            explode: true,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(value: .init("world"))
            ]
        )

        XCTAssertEqual(t8.schema, .b(.string))
        XCTAssertEqual(t8.style, .deepObject)
        XCTAssertTrue(t8.explode)
        XCTAssertFalse(t8.allowReserved)
        XCTAssertNotNil(t8.example)
        XCTAssertEqual(t8.example?.value as? String, "hello")
        XCTAssertNotNil(t8.examples)
        XCTAssertEqual(t8.examples?["two"]?.b?.value.b?.value as? String, "world")

        // schema reference multiple examples
        let t9 = Schema(
            schemaReference: .external("hello.yml"),
            style: .deepObject,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(reference: .external("world.yml"))
            ]
        )

        XCTAssertEqual(t9.schema, .a(.external("hello.yml")))
        XCTAssertEqual(t9.style, .deepObject)
        XCTAssertFalse(t9.explode)
        XCTAssertFalse(t9.allowReserved)
        XCTAssertNotNil(t9.example)
        XCTAssertEqual(t9.example?.value as? String, "hello")
        XCTAssertNotNil(t9.examples)
        XCTAssertEqual(t9.examples?["two"]?.a, .external("world.yml"))

        // schema reference override explode multiple examples
        let t10 = Schema(
            schemaReference: .external("hello.yml"),
            style: .deepObject,
            explode: true,
            examples: [
                "one": .example(value: .init("hello")),
                "two": .example(reference: .external("world.yml"))
            ]
        )

        XCTAssertEqual(t10.schema, .a(.external("hello.yml")))
        XCTAssertEqual(t10.style, .deepObject)
        XCTAssertTrue(t10.explode)
        XCTAssertFalse(t10.allowReserved)
        XCTAssertNotNil(t10.example)
        XCTAssertEqual(t10.example?.value as? String, "hello")
        XCTAssertNotNil(t10.examples)
        XCTAssertEqual(t10.examples?["two"]?.a, .external("world.yml"))
    }

    public func test_style_defaults() {
        let t1 = Schema.Style.default(for: .query)
        XCTAssertEqual(t1, .form)

        let t2 = Schema.Style.default(for: .cookie)
        XCTAssertEqual(t2, .form)

        let t3 = Schema.Style.default(for: .path)
        XCTAssertEqual(t3, .simple)

        let t4 = Schema.Style.default(for: .header)
        XCTAssertEqual(t4, .simple)
    }

    public func test_style_defaultExplodes() {
        let t1 = Schema(.string, style: .form)
        XCTAssertTrue(t1.explode)

        let t2 = Schema(.string, style: .simple)
        XCTAssertFalse(t2.explode)

        let t3 = Schema(.string, style: .matrix)
        XCTAssertFalse(t3.explode)

        let t4 = Schema(.string, style: .label)
        XCTAssertFalse(t4.explode)

        let t5 = Schema(.string, style: .spaceDelimited)
        XCTAssertFalse(t5.explode)

        let t6 = Schema(.string, style: .pipeDelimited)
        XCTAssertFalse(t6.explode)

        let t7 = Schema(.string, style: .deepObject)
        XCTAssertFalse(t7.explode)
    }
}

// MARK: - Codable Tests
extension ParameterSchemaTests {
    // TODO: write tests
}
