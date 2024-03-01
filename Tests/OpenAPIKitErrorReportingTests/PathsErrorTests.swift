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
    func test_badPathReference() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world:
                $ref: ''
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a PathItem in Document.paths['/hello/world']. \n\nReference<PathItem> could not be decoded because:\nInconsistency encountered when parsing `$ref`: Expected a reference string, but found an empty string instead..."
            )
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["paths", "/hello/world"])
        }
    }

    /// Errors as bad vendor extension since "boo" is not a valid expected property and all unexpected properties are assumed to be extensions and
    /// all extensions must begin with `x-`.
    func test_wayOffMarkForPathItemOrReference() {
        let documentYML =
        """
        openapi: "3.1.0"
        info:
            title: test
            version: 1.0
        paths:
            /hello/world: {"boo": 123}
        """

        XCTAssertThrowsError(try testDecoder.decode(OpenAPI.Document.self, from: documentYML)) { error in

            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Found neither a $ref nor a PathItem in Document.paths['/hello/world']. \n\nPathItem could not be decoded because:\nInconsistency encountered when parsing `Vendor Extension` under the `/hello/world` path: Found at least one vendor extension property that does not begin with the required 'x-' prefix. Invalid properties: [ boo ].."
            )
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["paths", "/hello/world"])
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

        let openAPIError = try warnResult.validate(using: Validator.blank, strict: false).first

        XCTAssertEqual(
            openAPIError?.localizedDescription,
                """
                Inconsistency encountered when parsing `OpenAPI Schema`: Found schema attributes not consistent with the type specified: object. Specifically, attributes for these other types: [\"array\"].
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
