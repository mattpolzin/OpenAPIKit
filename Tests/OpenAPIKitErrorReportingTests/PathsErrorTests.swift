//
//  PathsErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class PathsErrorTests: XCTestCase {
    func test_missingPaths() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `paths` key in the root Document object to be present but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [])
        }
    }
}
