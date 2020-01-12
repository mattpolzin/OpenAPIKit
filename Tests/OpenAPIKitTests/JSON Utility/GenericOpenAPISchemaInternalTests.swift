//
//  GenericOpenAPISchemaInternalTests.swift
//  
//
//  Created by Mathew Polzin on 1/11/20.
//

import XCTest
@testable import OpenAPIKit

final class GenericOpenAPISchemaInternalTests: XCTestCase {
    func test_reencodedSchemaGuess() throws {
        XCTAssertEqual(try reencodedSchemaGuess(for: "hello", using: testEncoder), .string)
        XCTAssertEqual(try reencodedSchemaGuess(for: 10, using: testEncoder), .integer)
        XCTAssertEqual(try reencodedSchemaGuess(for: 11.5, using: testEncoder), .number(format: .double))
        XCTAssertEqual(try reencodedSchemaGuess(for: true, using: testEncoder), .integer)
        XCTAssertEqual(try reencodedSchemaGuess(for: TestEnum.one, using: testEncoder), .string)
    }

    func test_openAPINodeGuessForType() {
        XCTAssertEqual(try openAPISchemaGuess(for: String.self, using: testEncoder), .string)
        XCTAssertEqual(try openAPISchemaGuess(for: Int.self, using: testEncoder), .integer)
        XCTAssertEqual(try openAPISchemaGuess(for: Float.self, using: testEncoder), .number(format: .float))
        XCTAssertEqual(try openAPISchemaGuess(for: Double.self, using: testEncoder), .number(format: .double))
        XCTAssertEqual(try openAPISchemaGuess(for: Bool.self, using: testEncoder), .boolean)
        XCTAssertEqual(try openAPISchemaGuess(for: TestEnum.self, using: testEncoder), .string)
    }

    func test_openAPINodeGuessForValue() {
        XCTAssertEqual(try openAPISchemaGuess(for: "hello", using: testEncoder), .string)
        XCTAssertEqual(try openAPISchemaGuess(for: 10, using: testEncoder), .integer)
        XCTAssertEqual(try openAPISchemaGuess(for: 11.5 as Float, using: testEncoder), .number(format: .float))
        XCTAssertEqual(try openAPISchemaGuess(for: 11.5, using: testEncoder), .number(format: .double))
        XCTAssertEqual(try openAPISchemaGuess(for: true, using: testEncoder), .boolean)
        XCTAssertEqual(try openAPISchemaGuess(for: TestEnum.one, using: testEncoder), .string)
    }
}

extension GenericOpenAPISchemaInternalTests {
    enum TestEnum: String, Codable, AnyRawRepresentable {
        case one
        case two
    }
}
