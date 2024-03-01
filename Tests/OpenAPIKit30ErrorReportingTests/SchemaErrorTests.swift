//
//  SchemaErrorTests.swift
//  
//
//  Created by Mathew Polzin.
//

import Foundation
import XCTest
import OpenAPIKit30
import Yams

final class SchemaErrorTests: XCTestCase {
    func test_nonIntegerMaximumForIntegerSchema() {
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
                            content:
                                'application/json':
                                    schema:
                                        type: integer
                                        maximum: 1.234
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a JSONSchema in .content['application/json'].schema for the status code '200' response of the **GET** endpoint under `/hello/world`. \n\nJSONSchema could not be decoded because:\nInconsistency encountered when parsing `maximum`: Expected an Integer literal but found a floating point value (1.234)..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "responses",
                "200",
                "content",
                "application/json",
                "schema"
            ])
        }
    }
}
