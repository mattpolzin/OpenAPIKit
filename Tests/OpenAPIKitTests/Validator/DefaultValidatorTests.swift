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
}
