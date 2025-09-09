//
//  ComponentKeyTests.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 2/16/25.
//

import OpenAPIKitCore
import XCTest

final class ComponentKeyTests: XCTestCase {
    func test_init() throws {
        let t1 : Shared.ComponentKey = "abcd"
        XCTAssertEqual(t1.rawValue, "abcd")

        let t2 = Shared.ComponentKey(rawValue: "abcd")
        XCTAssertEqual(t2?.rawValue, "abcd")

        let t3 = Shared.ComponentKey(rawValue: "")
        XCTAssertNil(t3)

        let t4 = Shared.ComponentKey(rawValue: "(abcd)")
        XCTAssertNil(t4)

        let t5 = try Shared.ComponentKey.forceInit(rawValue: "abcd")
        XCTAssertEqual(t5.rawValue, "abcd")

        XCTAssertThrowsError(try Shared.ComponentKey.forceInit(rawValue: nil))
        XCTAssertThrowsError(try Shared.ComponentKey.forceInit(rawValue: "(abcd)"))
    }

    func test_problemString() {
        let message = Shared.ComponentKey.problem(with: "(abcd)")

        XCTAssertEqual(message, "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '(abcd)' does not..")

        let nonProblem = Shared.ComponentKey.problem(with: "abcd")
        XCTAssertNil(nonProblem)
    }
}
