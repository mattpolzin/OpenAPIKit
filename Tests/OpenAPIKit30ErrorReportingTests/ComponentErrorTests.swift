//
//  ComponentErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit30
@preconcurrency import Yams

final class ComponentErrorTests: XCTestCase {

    func test_badComponentKeyNames() {
        let documentYML =
        """
        openapi: "3.0.0"
        info:
            title: test
            version: 1.0
        paths: {}
        components:
            schemas:
                'h#llo':
                    type: string
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, #"Problem encountered when parsing `h#llo` in Document.components.schemas: Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\.\-_]+$`. 'h#llo' does not..."#)
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["components", "schemas", "h#llo"])
        }
    }

    func test_badResponseBecauseOfHeaderInsideComponents() {
        let documentYML =
        """
        openapi: "3.0.0"
        info:
            title: test
            version: 1.0
        paths: {}
        components:
            responses:
                IllFormed:
                    description: hello world
                    headers:
                        MissingSchemaKey:
                            type: string # should be nested within a `schema` object
                    content: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Header. \n\nHeader could not be decoded because:\nProblem encountered when parsing `Header`: A header parameter must specify either `content` or `schema`..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["components", "responses", "IllFormed", "headers", "MissingSchemaKey"])
        }
    }
}
