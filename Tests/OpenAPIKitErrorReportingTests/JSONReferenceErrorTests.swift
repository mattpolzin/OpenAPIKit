//
//  JSONReferenceErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/27/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class JSONReferenceErrorTests: XCTestCase {
    func test_referenceFailedToParse() {
        let documentYML =
        """
        openapi: "3.0.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get:
                    responses: {}
                    parameters:
                        - $ref: 'not a reference'
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[0] for the **GET** endpoint under `/hello/world`. \n\nJSONReference<Parameter> could not be decoded because:\nInconsistency encountered when parsing `JSON Reference`: Failed to parse a valid URI for a JSON Reference from 'not a reference'.\n\nParameter could not be decoded because:\nExpected to find `name` key but it is missing..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "parameters",
                "Index 0"
            ])
        }
    }
}
