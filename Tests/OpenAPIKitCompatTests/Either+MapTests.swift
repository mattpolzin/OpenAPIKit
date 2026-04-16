//
//  Either+MapTests.swift
//  OpenAPIKit
//

import OpenAPIKitCore
@testable import OpenAPIKitCompat
import XCTest

final class EitherMapTests: XCTestCase {
    func test_mapFirst() {
        let x: Either<String, Int> = .a("hi")
        let y: Either<String, Int> = .b(2)

        XCTAssertEqual(x.mapFirst { $0 + "!"}, .a("hi!"))
        XCTAssertEqual(y.mapFirst { $0 + "!"}, .b(2))
    }

    func test_mapSecond() {
        let x: Either<String, Int> = .a("hi")
        let y: Either<String, Int> = .b(2)

        XCTAssertEqual(x.mapSecond(String.init), .a("hi"))
        XCTAssertEqual(y.mapSecond(String.init), .b("2"))
    }
}
