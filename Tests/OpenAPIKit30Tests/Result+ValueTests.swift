//
//  Result+ValueTests.swift
//  OpenAPIKitTests
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import XCTest
@testable import OpenAPIKit30

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
