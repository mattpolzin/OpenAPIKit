//
//  ValidityEncoderTests.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class ValidityEncoderTests: XCTestCase {
    func test_validationSucceedsUnconditionally() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating { (_: ValidationContext<OpenAPI.Server>) in .valid }

        try validator.assertValidity()
    }

    func test_validationNeverRunsAndSucceeds() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
            },
            if: { _ in false }
        )

        try validator.assertValidity()
    }

    func test_validationFailsUnconditionally() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
            },
            if: { _ in true }
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "just because")
        }
    }

    func test_singleConditionallyDoesNotRunAndSucceeds() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
            },
            if: { context in context.subject.description != "hello world" }
        )

        try validator.assertValidity()
    }

    func test_singleConditionallyRunsAndSucceeds() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (_: ValidationContext<OpenAPI.Server>) in
                .valid
            },
            if: { context in context.subject.description == "hello world" }
        )

        try validator.assertValidity()
    }

    func test_singleConditionallyRunsAndFails() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
            },
            if: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "just because")
        }
    }

    func test_failsTwiceForSameValueOfSameTypeTwice() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
        }

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "just because")
            XCTAssertEqual(error?.values.last?.reason, "just because")
        }
    }

    func test_failsOnceForDifferentValuesOfSameType() {
        let server1 = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )
        let server2 = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "coolio",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server1, server2],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                .invalid(because: [ ValidationError(reason: context.subject.description ?? "", at: context.codingPath) ])
            },
            if: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "hello world")
        }
    }

    func test_failsParentURL() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating { (context: ValidationContext<URL>) in
                .invalid(because: [ ValidationError(reason: "just because", at: context.codingPath) ])
        }

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "just because")
        }
    }

    func test_failsNestedString() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<String>) in
                .invalid(because: [ ValidationError(reason: String(context.subject), at: context.codingPath) ])
            },
            if: { context in context.subject == "world" }
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "world")
        }
    }

    func test_failsTwoChildStrings() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<String>) in
                .invalid(because: [ ValidationError(reason: context.subject, at: context.codingPath) ])
            },
            if: { context in ["hello", "world"].contains(context.subject) }
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 5)
            XCTAssertEqual(error?.values.map { $0.reason }.filter { $0 == "hello" }.count, 3)
            XCTAssertEqual(error?.values.map { $0.reason }.filter { $0 == "world" }.count, 2)
        }
    }

    func test_equalsPredicate() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
            { (context: ValidationContext<String>) in
                .invalid(because: [ ValidationError(reason: context.subject, at: context.codingPath) ])
            },
            if: \.subject == "hello"
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 3)
            XCTAssertEqual(error?.values.map { $0.reason }.filter { $0 == "hello" }.count, 3)
            XCTAssertEqual(error?.values.map { $0.reason }.filter { $0 == "world" }.count, 0)
        }
    }

    func test_equalsPredicateAndDescribeValidator() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
                "there should be two servers",
                asserting: { context in context.document.servers.count == 2 },
                if: \.subject == "hello"
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 3)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: 'there should be two servers'.")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["info", "title"])
        }
    }

    func test_equalsPredicateAndNotEqualsValidator() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
                "API version is 2.0",
                asserting: \OpenAPI.Document.Info.version != "2.0",
                if: \.title == "hello"
        )

        try validator.assertValidity()
    }

    func test_pathItemHasAtLeastOneOperationSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "get the world",
                    get: .init(
                        tags: "World",
                        responses: [
                            200: .response(
                                description: "Get the world",
                                content: [
                                    .json: .init(schema: .string)
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        try document.validator
            .validating(
                "Path Items must have at least one Operation",
                asserting: \OpenAPI.PathItem.endpoints.count > 0
        )
            .assertValidity()
    }

    func test_pathItemHasAtLeastOneOperationFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "get the world"
                )
            ],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
                "Path Items must have at least one Operation",
                asserting: \OpenAPI.PathItem.endpoints.count > 0
        )

        XCTAssertThrowsError(try validator.assertValidity()) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: 'Path Items must have at least one Operation'.")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths"])
        }
    }

    func test_ifTestServerThenTwoServers() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://test.server.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hello",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .noComponents
        )

        let validator = document
            .validator
            .validating(
                "At least two servers are specified if one of them is the test server.",
                asserting: \.document.servers.count >= 2,
                if: \OpenAPI.Server.url == URL(string: "https://test.server.com")!
        )

        XCTAssertThrowsError(try validator.assertValidity())

        let document2 = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [:],
            components: .noComponents
        )

        let validator2 = document2
            .validator
            .validating(
                "At least two servers are specified if one of them is the test server.",
                asserting: \.document.servers.count >= 2,
                if: \OpenAPI.Server.url == URL(string: "https://test.server.com")!
        )

        XCTAssertNoThrow(try validator2.assertValidity())
    }
}
