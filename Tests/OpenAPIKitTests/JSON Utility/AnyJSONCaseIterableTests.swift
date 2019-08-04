//
//  AnyJSONCaseIterableTests.swift
//  
//
//  Created by Mathew Polzin on 8/4/19.
//

import XCTest
import AnyCodable
import OpenAPIKit

class AnyJSONCaseIterableTests: XCTestCase {
    func test_CodableToAllCases() {
        let testEncoder = JSONEncoder()

        let allCases = CodableEnum.allCases(using: testEncoder)

        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains("one"))
        XCTAssertTrue(allCases.contains("two"))
    }

    func testAnyCodableToAllCases() {
        let testEncoder = JSONEncoder()

        let allCases = try! CodableEnum.allCases(from: CodableEnum.allCases(using: testEncoder), using: testEncoder)

        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains("one"))
        XCTAssertTrue(allCases.contains("two"))
    }
}

enum CodableEnum: String, CaseIterable, Codable {
    case one
    case two
}

extension CodableEnum: AnyJSONCaseIterable {
    static func allCases(using encoder: JSONEncoder) -> [AnyCodable] {
        return (try? allCases(from: allCases, using: encoder)) ?? []
    }
}
