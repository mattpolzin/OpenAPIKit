//
//  ResponseErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/25/20.
//

import Foundation
import XCTest
import OpenAPIKit30
@preconcurrency import Yams

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

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Header in .headers.hi for the status code '200' response of the **GET** endpoint under `/hello/world`. \n\nHeader could not be decoded because:\nInconsistency encountered when parsing `Header`: A header must specify one but not both `content` and `schema`..")
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

    func test_missingDescriptionResponseObject() {
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
                            not-a-thing: hi
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Response in .responses.200 for the **GET** endpoint under `/hello/world`. \n\nResponse could not be decoded because:\nExpected to find `description` key but it is missing..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "responses",
                "200"
            ])
        }
    }

    func test_badResponseExtension() {
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
                            description: described
                            not-a-thing: hi
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Response in .responses.200 for the **GET** endpoint under `/hello/world`. \n\nResponse could not be decoded because:\nInconsistency encountered when parsing `Vendor Extension`: Found at least one vendor extension property that does not begin with the required 'x-' prefix. Invalid properties: [ not-a-thing ]..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "responses",
                "200"
            ])
        }
    }

    func test_badStatusCode() {
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
                        'twohundred':
                            description: hello
                            content: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `twohundred` value in .responses for the **GET** endpoint under `/hello/world` to be parsable as ResponseStatusCode but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "responses",
                "twohundred"
            ])
        }
    }
}
