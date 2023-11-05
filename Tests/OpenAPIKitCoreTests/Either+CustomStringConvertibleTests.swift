//
//  Either+CustomStringConvertibleTests.swift
//  
//
//  Created by Mathew Polzin on 12/18/21.
//

import OpenAPIKitCore
import XCTest

final class EitherCustomStringConvertibleTests: XCTestCase {
    func test_Description() {
        let either1: Either<String, Int> = .a("hello")
        let either2: Either<String, Int> = .b(10)

        XCTAssertEqual(either1.description, "hello")
        XCTAssertEqual(either2.description, "10")
    }

    func test_DebugDescription() {
        let either1: Either<String, Int> = .a("hello")
        let either2: Either<String, Int> = .b(10)

        XCTAssertEqual(either1.debugDescription, "Either(\"hello\")")
        XCTAssertEqual(either2.debugDescription, "Either(10)")
    }
}
