//
//  PathsErrorTests.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import XCTest
import OpenAPIKit
import Yams

final class PathsErrorTests: XCTestCase {
    func test_missingPaths() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find `paths` key in the root Document object but it is missing.")
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_wrongTypeParameter() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: header
                      schema:
                        type: string
                    - invalid: hi
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[1] under the `/hello/world` path. \n\nParameter could not be decoded because:\nExpected to find `name` key but it is missing.."
            )
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "parameters", "Index 1"])
        }

        let documentYML2 =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: header
                      schema:
                        type: string
                    - []
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML2)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[1] under the `/hello/world` path. \n\nReference<Parameter> could not be decoded because:\nExpected value to be parsable as Mapping but it was not.\n\nParameter could not be decoded because:\nExpected value to be parsable as Mapping but it was not.."
            )
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "parameters", "Index 1"])
        }
    }

    func test_optionalPositionalPathParam() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: path
                      schema:
                        type: string
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[0] under the `/hello/world` path. \n\nParameter could not be decoded because:\nInconsistency encountered when parsing `world`: positional path parameters must be explicitly set to required.."
            )
            XCTAssertEqual(
                openAPIError.codingPath.map { $0.stringValue },
                [
                    "paths",
                    "/hello/world",
                    "parameters",
                    "Index 0"
                ]
            )
        }
    }

    func test_noContentOrSchemaParam() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: query
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[0] under the `/hello/world` path. \n\nParameter could not be decoded because:\nInconsistency encountered when parsing `world`: A parameter must specify either `content` or `schema`.."
            )
            XCTAssertEqual(
                openAPIError.codingPath.map { $0.stringValue },
                [
                    "paths",
                    "/hello/world",
                    "parameters",
                    "Index 0"
                ]
            )
        }
    }

    func test_bothContentAndSchemaParam() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: query
                      schema:
                        type: string
                      content:
                        application/json:
                            schema:
                                type: string
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a Parameter in .parameters[0] under the `/hello/world` path. \n\nParameter could not be decoded because:\nInconsistency encountered when parsing `world`: A parameter must specify one but not both `content` and `schema`.."
            )
            XCTAssertEqual(
                openAPIError.codingPath.map { $0.stringValue },
                [
                    "paths",
                    "/hello/world",
                    "parameters",
                    "Index 0"
                ]
            )
        }
    }

    func test_paramSchemaHasProblemDeeplyNestedInSchema() throws {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                summary: hello
                parameters:
                    - name: world
                      in: query
                      schema:
                        type: object
                        properties:
                            hi:
                                type: object
                                items:
                                    type: string
        """

        let warnResult = try testDecoder.decode(OpenAPI.Document.self, from: documentYML)

        let openAPIError = try warnResult.validate(using: Validator.blank).first

        XCTAssertEqual(
            openAPIError?.localizedDescription,
                """
                Inconsistency encountered when parsing `OpenAPI Schema`: Found schema attributes not consistent with the type specified: object.
                """
        )
        XCTAssertEqual(
            openAPIError?.codingPath?.map { $0.stringValue },
            [
                "paths",
                "/hello/world",
                "parameters",
                "Index 0",
                "schema",
                "properties",
                "hi"
            ]
        )
    }
}
