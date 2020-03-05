//
//  SwiftPrimitiveTypes+OpenAPITests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import XCTest
import OpenAPIKit

class SwiftPrimitiveTypesTests: XCTestCase {

    func test_StringNode() {
        XCTAssertEqual(try! String.openAPISchema(), .string)
    }

    func test_BoolNode() {
        XCTAssertEqual(try! Bool.openAPISchema(), .boolean)
    }

    func test_DoubleNode() {
        XCTAssertEqual(try! Double.openAPISchema(), .number(format: .double))
    }

    func test_FloatNode() {
        XCTAssertEqual(try! Float.openAPISchema(), .number(format: .float))
    }

    func test_IntNode() {
        XCTAssertEqual(try! Int.openAPISchema(), .integer)
    }

    func test_Int32Node() {
        XCTAssertEqual(try! Int32.openAPISchema(), .integer(format: .int32))
    }

    func test_Int64Node() {
        XCTAssertEqual(try! Int64.openAPISchema(), .integer(format: .int64))
    }

    func test_ArrayNode() {
        XCTAssertEqual(try! [String].openAPISchema(), .array(items: .string))

        XCTAssertEqual(try! [Bool].openAPISchema(), .array(items: .boolean))

        XCTAssertEqual(try! [Double].openAPISchema(), .array(items: .number(format: .double)))

        XCTAssertEqual(try! [Float].openAPISchema(), .array(items: .number(format: .float)))

        XCTAssertEqual(try! [Int].openAPISchema(), .array(items: .integer))

        XCTAssertEqual(try! [Int32].openAPISchema(), .array(items: .integer(format: .int32)))

        XCTAssertEqual(try! [Int64].openAPISchema(), .array(items: .integer(format: .int64)))

        XCTAssertEqual(try! [String?].openAPISchema(), .array(items: .string(required: false)))
    }

    func test_OptionalNodeType() {
        XCTAssertEqual(try! String?.openAPISchema(), .string(required:false))

        XCTAssertEqual(try! Bool?.openAPISchema(), .boolean(required: false))

        XCTAssertEqual(try! Double?.openAPISchema(), .number(format: .double, required: false))

        XCTAssertEqual(try! Float?.openAPISchema(), .number(format: .float, required: false))

        XCTAssertEqual(try! Int?.openAPISchema(), .integer(required: false))

        XCTAssertEqual(try! Int32?.openAPISchema(), .integer(format: .int32, required: false))

        XCTAssertEqual(try! Int64?.openAPISchema(), .integer(format: .int64, required: false))

        XCTAssertEqual(try! [String]?.openAPISchema(), .array(required: false, items: .string))

        XCTAssertEqual(try! [String?]?.openAPISchema(), .array(required: false, items: .string(required: false)))
    }

    static let localTestEncoder = JSONEncoder()
}
