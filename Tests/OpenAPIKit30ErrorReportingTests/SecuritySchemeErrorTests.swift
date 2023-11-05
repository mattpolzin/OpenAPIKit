//
//  SecuritySchemeErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit30
import Yams

final class SecuritySchemeErrorTests: XCTestCase {
    func test_missingSecuritySchemeError() {
        // missing as-in not found in the Components Object
        let documentYML =
        """
        openapi: 3.0.0
        info:
            title: test
            version: 1.0
        paths: {}
        components: {}
        security:
            - missing: []
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Inconsistency encountered when parsing `security` in the root Document object: Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "security"
            ])
        }
    }

    func test_missingSecuritySchemeInPathsError() {
        // missing as-in not found in the Components Object
        let documentYML =
        """
        openapi: 3.0.0
        info:
            title: test
            version: 1.0
        paths: {
            "/hello/world": {
                "get": {
                    "responses": {},
                    "security": [
                        "hello": []
                    ]
                }
            }
        }
        components: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Inconsistency encountered when parsing `hello` in Document.paths['/hello/world'].get.security: Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "security",
                "hello"
            ])
        }
    }
}
