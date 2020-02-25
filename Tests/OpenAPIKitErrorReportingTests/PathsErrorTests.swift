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
openapi: "3.0.0"
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
openapi: "3.0.0"
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
            print(error)
            let openAPIError = OpenAPI.Error(from: error)

            XCTAssertEqual(openAPIError.localizedDescription, "Expected to find either a $ref or a Parameter in .parameters[1] under the `/hello/world` path but found neither: \n\nJSONReference<Components, Parameter> could not be decoded because:\nExpected to find `$ref` key in .paths./hello/world.parameters[1] but it is missing.\n\nParameter could not be decoded because:\nExpected to find `name` key in .paths./hello/world.parameters[1] but it is missing.."
            )
            XCTAssertEqual(openAPIError.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "parameters", "Index 1"])
        }
    }
}
