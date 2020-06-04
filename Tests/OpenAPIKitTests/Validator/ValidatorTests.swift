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
            check: given(\OpenAPI.Server.url.absoluteString) { $0.contains("prod") }
        )

        _ = validator.validating(
            "",
            check: \[OpenAPI.Server].count >= 2,
            where: { context in
                context.subject.map { $0.url.absoluteString }.contains("https://test.server.com")
            }
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
            where: { _ in false }
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
            where: { _ in true }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
            },
            where: { context in context.subject.description != "hello world" }
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
            where: { context in context.subject.description == "hello world" }
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
            where: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
        }

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<OpenAPI.Server>) in
                [ ValidationError(reason: context.subject.description ?? "", at: context.codingPath) ]
            },
            where: { context in context.subject.description == "hello world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating { (context: ValidationContext<URL>) in
                [ ValidationError(reason: "just because", at: context.codingPath) ]
        }

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: String(context.subject), at: context.codingPath) ]
            },
            where: { context in context.subject == "world" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: context.subject, at: context.codingPath) ]
            },
            where: { context in ["hello", "world"].contains(context.subject) }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
            { (context: ValidationContext<String>) in
                [ ValidationError(reason: context.subject, at: context.codingPath) ]
            },
            where: \.subject == "hello"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
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

        let validator = Validator()
            .validating(
                "there should be two servers",
                check: { context in context.document.servers.count == 2 }, // just something false to check for every "hello" String value
                where: \.subject == "hello"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
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
                where: \.title == "hello"
        )

        try document.validate(using: validator)
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
            let error = error as? ValidationErrors
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
                "At least two servers are specified if one of them is the test server.",
                check: \.document.servers.count >= 2,
                where: \OpenAPI.Server.url == URL(string: "https://test.server.com")!
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
                where: \OpenAPI.Server.url == URL(string: "https://test.server.com")!
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
                where: given(\OpenAPI.Document.servers) { servers in
                    servers.map { $0.url.absoluteString }.contains("https://test.server.com")
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
                where: given(\OpenAPI.Document.servers) { servers in
                    servers.map { $0.url.absoluteString }.contains("https://test.server.com")
                }
        )

        XCTAssertNoThrow(try document2.validate(using: validator2))
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
            let error = error as? ValidationErrors
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
                check: given(\OpenAPI.Response.Map.keys, { $0.contains(500) })
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
                check: given(\OpenAPI.Response.Map.keys) { $0.contains(500) }
                    || \.count == 2
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
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
                where: given(\.codingPath) { $0.last?.stringValue == "x-string" }
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
                where: given(\.codingPath) { $0.last?.stringValue == "x-string" }
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 2)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: x-string is 'hello'")
        }
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
                where: \.codingPath.last?.stringValue == "x-string"
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
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
            where: { context in context.codingPath.last?.stringValue == "x-string" }
        )

        let validator = Validator()
            .validating(validation)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
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
                "/hello/world": .init(servers: [server])
            ],
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator()
            .validating(
                "All server arrays have more than 1 server",
                check: \[OpenAPI.Server].count > 1
        )

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrors
            XCTAssertEqual(error?.values.count, 1)
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: All server arrays have more than 1 server")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "servers"])
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
                "/hello/world": .init(servers: [server])
            ],
            components: .noComponents,
            vendorExtensions: [
                "x-string": "world"
            ]
        )

        let validator = Validator()
            .validating(
                "All server arrays have more than 1 server",
                check: \[OpenAPI.Server].count > 1,
                where: \.codingPath.count < 2
        )

        try document.validate(using: validator)
    }
}
