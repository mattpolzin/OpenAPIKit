//
//  RequestContentMapErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/24/20.
//

import Foundation
import XCTest
import OpenAPIKit
@preconcurrency import Yams

final class RequestContentMapErrorTests: XCTestCase {
    func test_wrongTypeContentValue() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get:
                    requestBody:
                        content:
                            application/json: hello
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Content in .content['application/json'] for the request body of the **GET** endpoint under `/hello/world`. \n\nReference<Content> could not be decoded because:\nExpected value to be parsable as Mapping but it was not.\n\nContent could not be decoded because:\nExpected value to be parsable as Mapping but it was not..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json"
            ])
        }
    }

    func test_incorrectVendorExtension() {
        let documentYML =
        """
        openapi: "3.1.0"
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
                                    type: string
                                x-hello: world
                                invalid: extension
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Content in .content['application/json'] for the request body of the **GET** endpoint under `/hello/world`. \n\nContent could not be decoded because:\nProblem encountered when parsing `Vendor Extension`: Found at least one vendor extension property that does not begin with the required 'x-' prefix. Invalid properties: [ invalid ]..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody",
                "content",
                "application/json"
            ])
        }
    }
}
