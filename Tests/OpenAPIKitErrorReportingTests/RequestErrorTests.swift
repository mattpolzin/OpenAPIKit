//
//  RequestErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/24/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class RequestErrorTests: XCTestCase {
    func test_wrongTypeRequest() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get:
                    requestBody: hello
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Request in .requestBody for the **GET** endpoint under `/hello/world`. \n\nJSONReference<Request> could not be decoded because:\nExpected value to be parsable as Mapping but it was not.\n\nRequest could not be decoded because:\nExpected value to be parsable as Mapping but it was not..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody"
            ])
        }
    }

    func test_missingContentMap() {
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
                        description: incomplete
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Request in .requestBody for the **GET** endpoint under `/hello/world`. \n\nRequest could not be decoded because:\nExpected to find `content` key but it is missing..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody"
            ])
        }
    }

    func test_wrongTypeContentMap() {
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
                        description: incomplete
                        content: []
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Request in .requestBody for the **GET** endpoint under `/hello/world`. \n\nRequest could not be decoded because:\nExpected `content` value to be parsable as Mapping but it was not..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "requestBody"
            ])
        }
    }
}
