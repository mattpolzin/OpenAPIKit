//
//  ValidatorTests.swift
//  
//
//  Created by Mathew Polzin on 6/2/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class ValidatorTests: XCTestCase {
    func test_randomSyntaxConstructions() {
        // just here to test out syntax constructions and make sure they compile
        let validator = Validator()

        _ = validator.validating(
            "",
            check: \OpenAPI.Document.openAPIVersion == .v3_0_0
        )
        _ = validator.validating(
            "",
            check: { (context: ValidationContext<OpenAPI.Document>) in context.subject.openAPIVersion == .v3_0_0 }
        )

        _ = validator.validating(
            "",
            check: \[OpenAPI.Server].count > 1
        )

        _ = validator.validating(
            "",
            check: take(\OpenAPI.Server.urlTemplate.absoluteString) { $0.contains("prod") }
        )

        _ = validator.validating(
            "",
            check: \[OpenAPI.Server].count >= 2,
            when: { context in
                context.subject.map { $0.urlTemplate.absoluteString }.contains("https://test.server.com")
            }
        )

        _ = validator.validating(
            "At least two servers are specified if one of them is the test server.",
            check: \[OpenAPI.Server].count >= 2,
            when: take(\.subject) { $0.map { $0.urlTemplate.absoluteString }.contains("https://test.server.com") }
        )

        _ = Validation(
            description: "x-string is 'hello'",
            check: \.subject == "hello",
            when: \.codingPath.last?.stringValue == "x-string"
        )

        let allRoutesOfferJSON = Validation(
            description: "All content maps have JSON members.",
            check: \OpenAPI.Content.Map[.json] != nil
        )

        _ = Validation(
            check: lift(\OpenAPI.Request.content, into: allRoutesOfferJSON)
        )

        _ = Validation(
            check: lift(\OpenAPI.Response.content, into: allRoutesOfferJSON)
        )

        let contentValidation = Validation<OpenAPI.Content>(
            check: { _ in [] }
        )

        let _ = Validation(
            check: unwrap(\OpenAPI.Content.Map[.json], into: contentValidation),
            when: \OpenAPI.Content.Map[.json] != nil
        )
    }

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

        let validator = Validator()
            .validating { (_: ValidationContext<OpenAPI.Server>) in [] }

        try document.validate(using: validator)
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
            },
            when: { _ in false }
        )

        try document.validate(using: validator)
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
            },
            when: { _ in true }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
            },
            when: { context in context.subject.description != "hello world" }
        )

        try document.validate(using: validator)
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

        let validator = Validator()
            .validating(
            { (_: ValidationContext<OpenAPI.Server>) in [] },
            when: { context in context.subject.description == "hello world" }
        )

        try document.validate(using: validator)
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
            },
            when: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
        }

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: context.subject.description ?? "", at: context.codingPath) ]
            },
            when: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "hello world")
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: String(context.subject), at: context.codingPath) ]
            },
            when: { context in context.subject == "world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: context.subject, at: context.codingPath) ]
            },
            when: { context in ["hello", "world"].contains(context.subject) }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: context.subject, at: context.codingPath) ]
            },
            when: \.subject == "hello"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
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

        let validator = Validator()
            .validating(
                "there should be two servers",
                check: { context in context.document.servers.count == 2 }, // just something false to check for every "hello" String value
                when: \.subject == "hello"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 3)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: there should be two servers")
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

        let validator = Validator()
            .validating(
                "API version is not 2.0",
                check: \OpenAPI.Document.Info.version != "2.0",
                when: \.title == "hello"
        )

        try document.validate(using: validator)
    }

    func test_andCheckSucceeds() throws {
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

        try document.validate(using: Validator()
            .validating(
                "Operations must have at least one Response and they all must be status code 200",
                check: \OpenAPI.Operation.responseOutcomes.count >= 1
                    && { $0.subject.responseOutcomes.allSatisfy { $0.status == 200 } }
            )
        )
    }

    func test_andCheckFails() throws {
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
                            ),
                            404: .response(
                                description: "Leave the world",
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

        let validator = Validator()
            .validating(
                "Operations must have at least one Response and they all must be status code 200",
                check: \OpenAPI.Operation.responseOutcomes.count >= 1
                    && { $0.subject.responseOutcomes.allSatisfy { $0.status == 200 } }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operations must have at least one Response and they all must be status code 200")
        }
    }

    func test_orCheckSucceeds() throws {
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
                            ),
                            404: .response(
                                description: "Leave the world",
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

        try document.validate(using: Validator()
            .validating(
                "Operations must contain a status code 500 or there must be two possible response",
                check: take(\OpenAPI.Response.Map.keys) { $0.contains(500) }
                    || \.count == 2

            )
        )
    }

    func test_orCheckFails() throws {
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

        let validator = Validator()
            .validating(
                "Operations must contain a status code 500 or there must be two possible responses",
                check: take(\OpenAPI.Response.Map.keys) { $0.contains(500) }
                    || \.count == 2
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operations must contain a status code 500 or there must be two possible responses")
        }
    }

    func test_conditionForExtensionWithPassingCheck() throws {
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
            components: .noComponents,
            vendorExtensions: [
                "x-string": "hello"
            ]
        )

        let validator = Validator()
            .validating(
                "x-string is 'hello'",
                check: \.subject == "hello",
                when: take(\.codingPath) { $0.last?.stringValue == "x-string" } // see alternative construction test cases for more concise version of this
        )

        try document.validate(using: validator)
    }

    func test_conditionForExtensionWithFailingCheck() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
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
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator()
            .validating(
                "x-string is 'hello'",
                check: \.subject == "hello",
                when: take(\.codingPath) { $0.last?.stringValue == "x-string" } // see alternative construction test cases for more concise version of this
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: x-string is 'hello'")
        }
    }

    // MARK: - Misc Test Cases
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

        try document.validate(using: Validator()
            .validating(
                "Path Items must have at least one Operation",
                check: \OpenAPI.PathItem.endpoints.count > 0
            )
        )
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

        let validator = Validator()
            .validating(
                "Path Items must have at least one Operation",
                check: \OpenAPI.PathItem.endpoints.count > 0
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Path Items must have at least one Operation")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world"])
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

        let validator = Validator()
            .validating(
                "At least two servers are specified on root Document if one of them is the test server.",
                check: \.document.servers.count >= 2,
                when: \OpenAPI.Server.urlTemplate == URLTemplate(rawValue: "https://test.server.com")!
                    && \.codingPath.first?.stringValue == "servers"
        )

        XCTAssertThrowsError(try document.validate(using: validator))

        let document2 = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [:],
            components: .noComponents
        )

        let validator2 = Validator()
            .validating(
                "At least two servers are specified if one of them is the test server.",
                check: \.document.servers.count >= 2,
                when: \OpenAPI.Server.urlTemplate == URLTemplate(rawValue: "https://test.server.com")!
        )

        XCTAssertNoThrow(try document2.validate(using: validator2))
    }

    func test_ifTestServerThenTwoServersAlternative() throws {
        // in this alternative, the condition is checked against
        // the OpenAPI.Document.servers property instead of checking
        // against OpenAPI.Server.url.
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

        let validator = Validator()
            .validating(
                "At least two servers are specified if one of them is the test server.",
                check: \.document.servers.count >= 2,
                when: take(\OpenAPI.Document.servers) { servers in
                    servers.map { $0.urlTemplate.absoluteString }.contains("https://test.server.com")
                }
        )

        XCTAssertThrowsError(try document.validate(using: validator))

        let document2 = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [:],
            components: .noComponents
        )

        let validator2 = Validator()
            .validating(
                "At least two servers are specified if one of them is the test server.",
                check: \.document.servers.count >= 2,
                when: take(\OpenAPI.Document.servers) { servers in
                    servers.map { $0.urlTemplate.absoluteString }.contains("https://test.server.com")
                }
        )

        XCTAssertNoThrow(try document2.validate(using: validator2))
    }

    func test_conditionForExtensionWithFailingCheckAlternativeWhereConstruction() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
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
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator()
            .validating(
                "x-string is 'hello'",
                check: \.subject == "hello",
                when: \.codingPath.last?.stringValue == "x-string"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: x-string is 'hello'")
        }
    }

    func test_conditionForExtensionWithFailingCheckAlternativeConstruction() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
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
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validation = Validation<String>(
            check: { context in
                guard context.subject == "hello" else {
                    return [ ValidationError(reason: "x-string needs to be 'hello'", at: context.codingPath) ]
                }
                return []
            },
            when: { context in context.codingPath.last?.stringValue == "x-string" }
        )

        let validator = Validator()
            .validating(validation)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "x-string needs to be 'hello'")
        }
    }

    func test_unconditionalServerCountCheckFails() {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [
                "/hello/world": .init(
                    servers: [server, server],
                    get: .init(responses: [:], servers: [server])
                )
            ],
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator.blank
            .validating(
                "All server arrays have more than 1 server",
                check: \[OpenAPI.Server].count > 1
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: All server arrays have more than 1 server")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "get", "servers"])
        }
    }

    func test_conditionalServerCountCheckSucceeds() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
                "x-int": 2244,
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"])
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "hello", version: "1.0"),
            servers: [server, server],
            paths: [
                "/hello/world": .init(
                    servers: [server, server],
                    get: .init(responses: [:], servers: [server])
                )
            ],
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator.blank
            .validating(
                "All server arrays have not in operations have more than 1 server",
                check: \[OpenAPI.Server].count > 1,
                when: \.codingPath.count == 1 // server array is under root document (coding path count 1)
                    || take(\.codingPath) { codingPath in
                        // server array is not under an HTTP verb (i.e. in an operation)
                        guard codingPath.count > 1 else { return false }

                        let secondToLastPathComponent = codingPath.suffix(2).first!.stringValue
                        let httpMethods = OpenAPI.HttpMethod.allCases.map { $0.rawValue.lowercased() }

                        return !httpMethods.contains(secondToLastPathComponent)
                }
        )

        try document.validate(using: validator)
    }

    func test_requestBodySchemaValidationFails() {
        // should fail in three ways:
        // 1. No `name` in request schema
        // 2. No `name` in response schema
        // 3. No `id` in response schema

        let createRequest = OpenAPI.Request(
            content: [
                .json: .init(
                    schema: .object(
                        properties: [
                            "classification": .string(allowedValues: "big", "small")
                        ]
                    )
                )
            ]
        )

        let successCreateResponse = OpenAPI.Response(
            description: "Created Widget",
            content: [
                .json: .init(
                    schema: .object(
                        properties: [
                            "classification": .string(allowedValues: "big", "small")
                        ]
                    )
                )
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/widget/create": .init(
                    post: .init(
                        requestBody: createRequest,
                        responses: [
                            201: .response(successCreateResponse)
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        let resourceContainsName = Validation<JSONSchema>(
            description: "All JSON resources must have a String name",
            check: take(\.subject) { schema in
                guard case let .object(_, context) = schema,
                    let nameProperty = context.properties["name"] else {
                        return false
                }
                return nameProperty.jsonTypeFormat?.jsonType == .string
            }
        )

        let responseResourceContainsId = Validation<JSONSchema>(
            description: "All JSON response resources must have an Id",
            check: take(\.subject) { schema in
                guard case let .object(_, context) = schema,
                    let idProperty = context.properties["id"] else {
                        return false
                }
                return idProperty.jsonTypeFormat?.jsonType == .integer
            }
        )

        let requestBodyContainsName = Validation(
            check: unwrap(
                \.content[.json]?.schema?.schemaValue,
                into: resourceContainsName
            ),

            when: \OpenAPI.Request.content[.json]?.schema?.schemaValue != nil
        )

        let responseBodyContainsNameAndId = Validation(
            check: unwrap(
                \.content[.json]?.schema?.schemaValue,
                into: resourceContainsName, responseResourceContainsId
            ),

            when: \OpenAPI.Response.content[.json]?.schema?.schemaValue != nil
        )

        let successResponseBodyContainsNameAndId = Validation(
            check: unwrap(
                \OpenAPI.Response.Map[status: 201]?.responseValue,
                into: responseBodyContainsNameAndId,
                description: "201 status response value"
            )
        )

        let postRequestAndResponsesAreValid = Validation(
            check: unwrap(
                \OpenAPI.PathItem[.post]?.requestBody?.requestValue,
                into: requestBodyContainsName
            )
            && unwrap(
                \OpenAPI.PathItem[.post]?.responses,
                into: successResponseBodyContainsNameAndId
            ),

            when: \OpenAPI.PathItem[.post] != nil
        )

        let validator = Validator()
            .validating(postRequestAndResponsesAreValid)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 3)
            XCTAssertEqual(error?.values.map { $0.reason }, [
                "Failed to satisfy: All JSON resources must have a String name",
                "Failed to satisfy: All JSON resources must have a String name",
                "Failed to satisfy: All JSON response resources must have an Id"
            ])
            XCTAssertEqual(
                error?.values.map { $0.codingPath.map { $0.stringValue } },
                [
                    ["paths", "/widget/create"], // request name property
                    ["paths", "/widget/create"],   // response name property
                    ["paths", "/widget/create"]    // response id property
                ]
            )
        }
    }

    func test_requestBodySchemaValidationSucceeds() throws {
        let createRequest = OpenAPI.Request(
            content: [
                .json: .init(
                    schema: .object(
                        properties: [
                            "name": .string,
                            "classification": .string(allowedValues: "big", "small")
                        ]
                    )
                )
            ]
        )

        let successCreateResponse = OpenAPI.Response(
            description: "Created Widget",
            content: [
                .json: .init(
                    schema: .object(
                        properties: [
                            "id": .integer,
                            "name": .string,
                            "classification": .string(allowedValues: "big", "small")
                        ]
                    )
                )
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/widget/create": .init(
                    post: .init(
                        requestBody: createRequest,
                        responses: [
                            201: .response(successCreateResponse)
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        let resourceContainsName = Validation<JSONSchema>(
            description: "All JSON resources must have a String name",
            check: take(\.subject) { schema in
                guard case let .object(_, context) = schema,
                    let nameProperty = context.properties["name"] else {
                        return false
                }
                return nameProperty.jsonTypeFormat?.jsonType == .string
            }
        )

        let responseResourceContainsId = Validation<JSONSchema>(
            description: "All JSON response resources must have an Id",
            check: take(\.subject) { schema in
                guard case let .object(_, context) = schema,
                    let idProperty = context.properties["id"] else {
                        return false
                }
                return idProperty.jsonTypeFormat?.jsonType == .integer
            }
        )

        let requestBodyContainsName = Validation(
            check: unwrap(
                \.content[.json]?.schema?.schemaValue,
                into: resourceContainsName
            ),

            when: \OpenAPI.Request.content[.json]?.schema?.schemaValue != nil
        )

        let responseBodyContainsNameAndId = Validation(
            check: unwrap(
                \.content[.json]?.schema?.schemaValue,
                into: resourceContainsName, responseResourceContainsId
            ),

            when: \OpenAPI.Response.content[.json]?.schema?.schemaValue != nil
        )

        let successResponseBodyContainsNameAndId = Validation(
            check: unwrap(
                \OpenAPI.Response.Map[status: 201]?.responseValue,
                into: responseBodyContainsNameAndId,
                description: "201 status response value"
            )
        )

        let postRequestAndResponsesAreValid = Validation(
            check: unwrap(
                \OpenAPI.PathItem[.post]?.requestBody?.requestValue,
                into: requestBodyContainsName
            )
            && unwrap(
                \OpenAPI.PathItem[.post]?.responses,
                into: successResponseBodyContainsNameAndId
            ),

            when: \OpenAPI.PathItem[.post] != nil
        )

        let validator = Validator()
            .validating(postRequestAndResponsesAreValid)

        try document.validate(using: validator)
    }

    // MARK: - Type validations
    func test_typeValidationSucceeds() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"]),
                "x-float": AnyCodable(22.5 as Float),
                "x-bool": true
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .init(
                schemas: [
                    "double": .number(multipleOf: 10.5),
                    "int": .integer(multipleOf: 3),
                    "bool": .object(deprecated: true)
                ]
            )
        )

        let validator = Validator()
            .validating("string", check: \String.self == "hiya", when: \.codingPath.last?.stringValue == "x-string")
            .validating("int", check: \Int.self == 3)
            .validating("double", check: \Double.self == 10.5)
            .validating("float", check: \Float.self == 22.5)
            .validating("bool", check: \Bool.self == true)

        try document.validate(using: validator)
    }

    func test_typeValidationFails() throws {
        let server = OpenAPI.Server(
            url: URL(string: "https://google.com")!,
            description: "hello world",
            variables: [:],
            vendorExtensions: [
                "x-string": "hiya",
                "x-double": 10.5,
                "x-dict": [ "string": "world"],
                "x-array": AnyCodable(["hello", nil, "world"]),
                "x-float": AnyCodable(22.5 as Float),
                "x-bool": true
            ]
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [server],
            paths: [:],
            components: .init(
                schemas: [
                    "double": .number(multipleOf: 10.5),
                    "int": .integer(multipleOf: 3),
                    "bool": .object(deprecated: true)
                ]
            )
        )

        let validator = Validator()
            .validating("string", check: \String.self == "hello there", when: \.codingPath.last?.stringValue == "x-string")
            .validating("int", check: \Int.self == 1)
            .validating("double", check: \Double.self == 2.2)
            .validating("float", check: \Float.self == 10.5)
            .validating("bool", check: \Bool.self == false)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let errors = error as? ValidationErrorCollection
            XCTAssertEqual(errors?.values.count, 7)
        }
    }
}
