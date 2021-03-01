//
//  SwiftPrimitiveTypes+OpenAPITests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import XCTest
import OpenAPIKit30

class SwiftPrimitiveTypesTests: XCTestCase {

    func test_StringSchema() {
        XCTAssertEqual(String.openAPISchema, .string)
    }

    func test_BoolSchema() {
        XCTAssertEqual(Bool.openAPISchema, .boolean)
    }

    func test_DoubleSchema() {
        XCTAssertEqual(Double.openAPISchema, .number(format: .double))
    }

    func test_FloatSchema() {
        XCTAssertEqual(Float.openAPISchema, .number(format: .float))
    }

    func test_IntSchema() {
        XCTAssertEqual(Int.openAPISchema, .integer)
    }

    func test_Int32Schema() {
        XCTAssertEqual(Int32.openAPISchema, .integer(format: .int32))
    }

    func test_Int64Schema() {
        XCTAssertEqual(Int64.openAPISchema, .integer(format: .int64))
    }

    func test_urlSchema() {
        XCTAssertEqual(URL.openAPISchema, .string(format: .extended(.uri)))
    }

    func test_uuidSchema() {
        XCTAssertEqual(UUID.openAPISchema, .string(format: .extended(.uuid)))
    }

    func test_ArraySchema() {
        XCTAssertEqual([String].openAPISchema, .array(items: .string))

        XCTAssertEqual([Bool].openAPISchema, .array(items: .boolean))

        XCTAssertEqual([Double].openAPISchema, .array(items: .number(format: .double)))

        XCTAssertEqual([Float].openAPISchema, .array(items: .number(format: .float)))

        XCTAssertEqual([Int].openAPISchema, .array(items: .integer))

        XCTAssertEqual([Int32].openAPISchema, .array(items: .integer(format: .int32)))

        XCTAssertEqual([Int64].openAPISchema, .array(items: .integer(format: .int64)))

        XCTAssertEqual([URL].openAPISchema, .array(items: .string(format: .extended(.uri))))

        XCTAssertEqual([UUID].openAPISchema, .array(items: .string(format: .extended(.uuid))))

        XCTAssertEqual([String?].openAPISchema, .array(items: .string(required: false)))
    }

    func test_OptionalSchema() {
        XCTAssertEqual(String?.openAPISchema, .string(required:false))

        XCTAssertEqual(Bool?.openAPISchema, .boolean(required: false))

        XCTAssertEqual(Double?.openAPISchema, .number(format: .double, required: false))

        XCTAssertEqual(Float?.openAPISchema, .number(format: .float, required: false))

        XCTAssertEqual(Int?.openAPISchema, .integer(required: false))

        XCTAssertEqual(Int32?.openAPISchema, .integer(format: .int32, required: false))

        XCTAssertEqual(Int64?.openAPISchema, .integer(format: .int64, required: false))

        XCTAssertEqual(URL?.openAPISchema, .string(format: .extended(.uri), required: false))

        XCTAssertEqual(UUID?.openAPISchema, .string(format: .extended(.uuid), required: false))

        XCTAssertEqual([String]?.openAPISchema, .array(required: false, items: .string))

        XCTAssertEqual([String?]?.openAPISchema, .array(required: false, items: .string(required: false)))
    }

    func test_DictionarySchema() {
        XCTAssertEqual([String: String].openAPISchema, .object(additionalProperties: .schema(.string)))

        XCTAssertEqual([String: Bool].openAPISchema, .object(additionalProperties: .schema(.boolean)))

        XCTAssertEqual([String: Double].openAPISchema, .object(additionalProperties: .schema(.number(format: .double))))

        XCTAssertEqual([String: Float].openAPISchema, .object(additionalProperties: .schema(.number(format: .float))))

        XCTAssertEqual([String: Int].openAPISchema, .object(additionalProperties: .schema(.integer)))

        XCTAssertEqual([String: Int32].openAPISchema, .object(additionalProperties: .schema(.integer(format: .int32))))

        XCTAssertEqual([String: Int64].openAPISchema, .object(additionalProperties: .schema(.integer(format: .int64))))

        XCTAssertEqual([String: URL].openAPISchema, .object(additionalProperties: .schema(.string(format: .extended(.uri)))))

        XCTAssertEqual([String: UUID].openAPISchema, .object(additionalProperties: .schema(.string(format: .extended(.uuid)))))

        XCTAssertEqual([String: String?].openAPISchema, .object(additionalProperties: .schema(.string(required: false))))
    }
}
