//
//  RequestContentSchemaErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/25/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class RequestContentSchemaErrorTests: XCTestCase {
    func test_wrongTypeContentSchemaTypeProperty() {
        let documentYML =
"""
openapi: "3.0.0"
info:
    title: test
    version: 1.0
paths:
    /hello/world:
        get:
            requestBody:
                content:
                    application/json:
                        schema:
                            type:
                                hi: there
            responses: {}
"""

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find either a $ref or a JSONSchema in .requestBody.content['application/json'].schema for the **GET** endpoint under `/hello/world` but found neither. \n\nJSONSchema could not be decoded because:\nExpected value to be parsable as JSONSchema but it was not..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json",
                "schema"
            ])
        }
    }
}
