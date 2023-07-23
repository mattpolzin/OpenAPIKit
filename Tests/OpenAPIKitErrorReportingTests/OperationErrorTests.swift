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
    func test_missingResponses() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                get: {}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a PathItem in Document.paths. \n\nPathItem could not be decoded because:\nExpected to find `responses` key for the **GET** endpoint under `/hello/world` but it is missing..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/hello/world"
            ])
        }
    }

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

extension OperationErrorTests {
    func test_missingResponseFromSSWGPitchConversation() {
        let documentYML =
        """
        openapi: 3.1.0
        info:
          title: API
          version: 1.0.0
        paths:
          /all-items:
            summary: Get all items
            get:
              responses:
                "200":
                  description: All items
          /one-item:
            get:
              summary: Get one item
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a PathItem in Document.paths. \n\nPathItem could not be decoded because:\nExpected to find `responses` key for the **GET** endpoint under `/one-item` but it is missing..")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [
                "paths",
                "/one-item"
            ])
        }
    }
}
