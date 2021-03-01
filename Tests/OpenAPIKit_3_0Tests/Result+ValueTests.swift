//
//  Result+ValueTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import XCTest
@testable import OpenAPIKit

fileprivate enum TestErrorType: Swift.Error, Equatable {
    case problem
}

class ResultValueTests: XCTestCase {
    func test_valueAccess() {
        let r1: Result<String, TestErrorType> = .success("hello")
        let r2: Result<String, TestErrorType> = .failure(.problem)

        XCTAssertEqual(r1.value, "hello")
        XCTAssertNil(r2.value)
    }

    func test_errorAccess() {
        let r1: Result<String, TestErrorType> = .success("hello")
        let r2: Result<String, TestErrorType> = .failure(.problem)

        XCTAssertNil(r1.error)
        XCTAssertEqual(r2.error, .problem)
    }
}
