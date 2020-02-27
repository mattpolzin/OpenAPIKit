//
//  ResponseErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/25/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class ResponseErrorTests: XCTestCase {
    func test_headerWithContentAndSchema() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
paths:
    /hello/world:
        get:
            responses:
                '200':
                    description: hello
                    content: {}
                    headers:
                        hi:
                            schema:
                                type: string
                            content:
                                application/json:
                                    schema:
                                        type: string
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find either a $ref or a Header in .responses.200.headers.hi for the **GET** endpoint under `/hello/world` but found neither. \n\nHeader could not be decoded because:\nInconsistency encountered when parsing `Header`: A single path parameter must specify one but not both `content` and `schema`..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "responses",
                "200",
                "headers",
                "hi"
            ])
        }
    }
}
