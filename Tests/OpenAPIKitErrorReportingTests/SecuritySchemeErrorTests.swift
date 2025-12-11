//
//  SecuritySchemeErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit
@preconcurrency import Yams

final class SecuritySchemeErrorTests: XCTestCase {
    func test_missingSecuritySchemeError() throws {
        #if os(Linux) && compiler(>=6.0) && compiler(<6.1)
        throw XCTSkip("Swift bug causes no exception in this test case for just one Swift 6 version (6.0)")
        #endif

        // missing as-in not found in the Components Object nor a valid external
        // URL
        let documentYML =
        """
        openapi: 3.1.0
        info:
            title: test
            version: 1.0
        paths: {}
        components: {}
        security: [
          "": []
        ]
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Problem encountered when parsing `security` in the root Document object: Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary or be a JSON reference to a security scheme found in another file.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "security"
            ])
        }
    }

    func test_missingSecuritySchemeInPathsError() {
        // missing as-in not found in the Components Object nor a valid external
        // URL
        let documentYML =
        """
        openapi: 3.1.0
        info:
            title: test
            version: 1.0
        paths: {
            "/hello/world": {
                "get": {
                    "responses": {},
                    "security": [
                        "": []
                    ]
                }
            }
        }
        components: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Problem encountered when parsing `` in Document.paths['/hello/world'].get.security: Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary or be a JSON reference to a Security Scheme found in another file.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "security",
                ""
            ])
        }
    }
}
