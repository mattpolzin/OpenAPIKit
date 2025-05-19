//
//  GenericErrorTests.swift
//  
//
//  Created by Mathew Polzin on 7/2/20.
//

@testable import OpenAPIKitCore
import XCTest

final class GenericErrorTests: XCTestCase {
    let error = GenericError(
        subjectName: "subject",
        details: "details",
        codingPath: []
    )

    func test_contextString() {
        XCTAssertEqual(error.contextString, "")
    }

    func test_localizedDescription() {
        XCTAssertEqual(error.localizedDescription, "details")
    }
}
