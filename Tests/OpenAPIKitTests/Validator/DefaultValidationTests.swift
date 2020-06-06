//
//  DefaultValidatorTests.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class DefaultValidatorTests: XCTestCase {
    func test_noPathsOnDocumentFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.documentContainsPaths)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Document contains at least one path")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths"])
        }
    }

    func test_onePathOnDocumentSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init()
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.documentContainsPaths)
        try document.validate(using: validator)
    }

    func test_noOperationsOnPathItemFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init()
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathsContainOperations)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Paths contain at least one operation")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world"])
        }
    }

    func test_oneOperationOnPathItemSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [:])
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathsContainOperations)
        try document.validate(using: validator)
    }

    func test_duplicateTagOnDocumentFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "hello"]
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: The names of Tags in the Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_uniqueTagsOnDocumentSocceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "world"]
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noResponsesOnOperationFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [:])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operations contain at least one response")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "get", "responses"])
        }
    }

    func test_oneResponseOnOperationSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicateOperationParameterFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .path, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string)
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operation parameters are unqiue (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello", "get"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello'].get")
        }
    }

    func test_uniqueOperationParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .query, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string), // changes parameter location but not name
                            .parameter(name: "cool", context: .path, schema: .string)  // changes parameter name but not location
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noOperationParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [],
                        responses: [
                            200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicateOperationIdFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: All Operation Ids in Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_uniqueOperationIdsSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "one", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noOperationIdsSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicatePathItemParameterFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "hiya", context: .query, schema: .string),
                        .parameter(name: "hiya", context: .query, schema: .string)
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Path Item parameters are unqiue (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello']")
        }
    }

    func test_uniquePathItemParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "hiya", context: .query, schema: .string),
                        .parameter(name: "hiya", context: .path, schema: .string), // changes parameter location but not name
                        .parameter(name: "cool", context: .path, schema: .string) // changes parameter name but not location
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noPathItemParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [],
                        responses: [
                            200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }
}
