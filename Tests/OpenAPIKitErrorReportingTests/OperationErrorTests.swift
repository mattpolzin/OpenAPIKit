//
//  OperationErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class OperationErrorTests: XCTestCase {
    func test_wrongTypeTags() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get:
                    tags: 1234
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected `tags` value for the **GET** endpoint under `/hello/world` to be parsable as Sequence but it was not.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "tags"
            ])
        }
    }

    func test_missingUrlInServer() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get:
                    servers:
                        - url: http://google.com
                          description: google
                        - description: missing a url
                    responses: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `url` key in .servers[1] for the **GET** endpoint under `/hello/world` but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world",
                "get",
                "servers",
                "Index 1"
            ])
        }
    }
}
