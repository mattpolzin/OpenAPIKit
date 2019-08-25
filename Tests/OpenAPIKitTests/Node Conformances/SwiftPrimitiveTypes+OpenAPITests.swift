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
        XCTAssertEqual(try! String.openAPINode(), .string)
    }

    func test_BoolNode() {
        XCTAssertEqual(try! Bool.openAPINode(), .boolean)
    }

    func test_DoubleNode() {
        XCTAssertEqual(try! Double.openAPINode(), .number(format: .double))
    }

    func test_FloatNode() {
        XCTAssertEqual(try! Float.openAPINode(), .number(format: .float))
    }

    func test_IntNode() {
        XCTAssertEqual(try! Int.openAPINode(), .integer)
    }

    func test_Int32Node() {
        XCTAssertEqual(try! Int32.openAPINode(), .integer(format: .int32))
    }

    func test_Int64Node() {
        XCTAssertEqual(try! Int64.openAPINode(), .integer(format: .int64))
    }

    func test_RawNodeType() {
        XCTAssertEqual(try! RawRepStringEnum.rawOpenAPINode(), .string)
        XCTAssertEqual(try! RawRepIntEnum.rawOpenAPINode(), .integer)
    }

    func test_ArrayNode() {
        XCTAssertEqual(try! [String].openAPINode(), .array(items: .string))

        XCTAssertEqual(try! [Bool].openAPINode(), .array(items: .boolean))

        XCTAssertEqual(try! [Double].openAPINode(), .array(items: .number(format: .double)))

        XCTAssertEqual(try! [Float].openAPINode(), .array(items: .number(format: .float)))

        XCTAssertEqual(try! [Int].openAPINode(), .array(items: .integer))

        XCTAssertEqual(try! [Int32].openAPINode(), .array(items: .integer(format: .int32)))

        XCTAssertEqual(try! [Int64].openAPINode(), .array(items: .integer(format: .int64)))

        XCTAssertEqual(try! [String?].openAPINode(), .array(items: .string(required: false)))
    }

    func test_OptionalNodeType() {
        XCTAssertEqual(try! String?.openAPINode(), .string(required:false))

        XCTAssertEqual(try! Bool?.openAPINode(), .boolean(required: false))

        XCTAssertEqual(try! Double?.openAPINode(), .number(format: .double, required: false))

        XCTAssertEqual(try! Float?.openAPINode(), .number(format: .float, required: false))

        XCTAssertEqual(try! Int?.openAPINode(), .integer(required: false))

        XCTAssertEqual(try! Int32?.openAPINode(), .integer(format: .int32, required: false))

        XCTAssertEqual(try! Int64?.openAPINode(), .integer(format: .int64, required: false))

        XCTAssertEqual(try! [String]?.openAPINode(), .array(required: false, items: .string))

        XCTAssertEqual(try! [String?]?.openAPINode(), .array(required: false, items: .string(required: false)))
    }

    func test_OptionalRawRepresentable() {
        XCTAssertEqual(try! RawRepStringEnum?.rawOpenAPINode(), .string(required: false))

        XCTAssertEqual(try! RawRepIntEnum?.rawOpenAPINode(), .integer(required: false))
    }

    func test_OptionalRawNodeType() {
        XCTAssertEqual(try! RawRepStringEnum?.wrappedOpenAPINode(), .string(required: false))

        XCTAssertEqual(try! RawRepIntEnum?.wrappedOpenAPINode(), .integer(required: false))
    }

    func test_DoubleWrappedRawNodeType() {
        XCTAssertEqual(try! RawRepStringEnum??.wrappedOpenAPINode(), .string(required: false))

        XCTAssertEqual(try! RawRepIntEnum??.wrappedOpenAPINode(), .integer(required: false))

        XCTAssertEqual(try! RawRepStringEnum??.doubleWrappedOpenAPINode(), .string(required: false))

        XCTAssertEqual(try! RawRepIntEnum??.doubleWrappedOpenAPINode(), .integer(required: false))
    }

    func test_OptionalCaseIterableNodeAllCases() {
        XCTAssertTrue(RawRepStringEnum?.allCases(using: SwiftPrimitiveTypesTests.localTestEncoder).contains("hello"))
        XCTAssertTrue(RawRepStringEnum?.allCases(using: SwiftPrimitiveTypesTests.localTestEncoder).contains("world"))
        XCTAssertEqual(RawRepStringEnum?.allCases(using: SwiftPrimitiveTypesTests.localTestEncoder).count, 2)
    }

    @available(OSX 10.13, *)
    func test_OptionalDateNodeType() {
        XCTAssertEqual(Date?.dateOpenAPINodeGuess(using: testEncoder), .string(format: .dateTime, required: false))
    }

    static let localTestEncoder = JSONEncoder()
}

fileprivate enum RawRepStringEnum: String, RawRepresentable, RawOpenAPINodeType, CaseIterable, Codable {
    case hello
    case world
}

fileprivate enum RawRepIntEnum: Int, RawRepresentable, RawOpenAPINodeType {
    case one
    case two
}
