//
//  DocumentTests.swift
//  
//
//  Created by Mathew Polzin on 10/27/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class DocumentTests: XCTestCase {
    func test_init() {
        // TODO: write test
    }

    func test_existingSecuritySchemeSuccess() {
        let docData =
"""
{
    "openapi": "3.0.0",
    "info": {
        "title": "test",
        "version": "1.0"
    },
    "paths": {},
    "components": {
        "securitySchemes": {
            "found": {
                "type": "http",
                "scheme": "basic"
            }
        }
    },
    "security": [
        {
            "found": []
        }
    ]
}
""".data(using: .utf8)!

        XCTAssertNoThrow(try JSONDecoder().decode(OpenAPI.Document.self, from: docData))
    }

    func test_missingSecuritySchemeError() {
        let docData =
"""
{
    "openapi": "3.0.0",
    "info": {
        "title": "test",
        "version": "1.0"
    },
    "paths": {},
    "components": {},
    "security": [
        {
            "missing": []
        }
    ]
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(OpenAPI.Document.self, from: docData)) { err in
            XCTAssertTrue(err is DecodingError)
            guard let decodingError = err as? DecodingError,
                case .dataCorrupted(let context) = decodingError else {
                    XCTFail("Expected data corrupted decoding error")
                    return
            }
            XCTAssertEqual(context.debugDescription, "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary.")
        }
    }
}

// MARK: - Codable
extension DocumentTests {
    // TODO: write tests
}
