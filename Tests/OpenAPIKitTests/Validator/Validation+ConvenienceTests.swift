//
//  Validation+ConvenienceTests.swift
//  
//
//  Created by Mathew Polzin on 6/5/20.
//

import Foundation
import XCTest
@testable import OpenAPIKit

final class ValidationConvenienceTests: XCTestCase {
    // MARK: - Operators
    // MARK: Context -> Error Array
    func test_and_toErrorArray() {
        let v1 = { (context: ValidationContext<String>) in
            return context.subject.starts(with: "he")
                ? []
                : [ ValidationError(reason: "", at: []) ]
        }
        let v2 = { (context: ValidationContext<String>) in
            return context.subject.count == 5
                ? []
                : [ ValidationError(reason: "", at: []) ]
        }

        XCTAssertTrue((v1 && v2)(dummyContext(for: "hello")).isEmpty)
        XCTAssertEqual((v1 && v2)(dummyContext(for: "heads up")).count, 1)
        XCTAssertEqual((v1 && v2)(dummyContext(for: "12345")).count, 1)
        XCTAssertEqual((v1 && v2)(dummyContext(for: "look out")).count, 2)
    }

    func test_or_toErrorArray() {
        let v1 = { (context: ValidationContext<String>) in
            return context.subject.starts(with: "he")
                ? []
                : [ ValidationError(reason: "", at: []) ]
        }
        let v2 = { (context: ValidationContext<String>) in
            return context.subject.count == 5
                ? []
                : [ ValidationError(reason: "", at: []) ]
        }

        XCTAssertTrue((v1 || v2)(dummyContext(for: "hello")).isEmpty)
        XCTAssertTrue((v1 || v2)(dummyContext(for: "heads up")).isEmpty)
        XCTAssertTrue((v1 || v2)(dummyContext(for: "12345")).isEmpty)
        XCTAssertEqual((v1 || v2)(dummyContext(for: "look out")).count, 2)
    }

    // MARK: Context -> Bool
    func test_and_toBool() {
        let v1 = { (context: ValidationContext<String>) in
            return context.subject.starts(with: "he")
        }
        let v2 = { (context: ValidationContext<String>) in
            return context.subject.count == 5
        }

        XCTAssertTrue((v1 && v2)(dummyContext(for: "hello")))
        XCTAssertFalse((v1 && v2)(dummyContext(for: "heads up")))
        XCTAssertFalse((v1 && v2)(dummyContext(for: "12345")))
        XCTAssertFalse((v1 && v2)(dummyContext(for: "look out")))
    }

    func test_or_toBool() {
        let v1 = { (context: ValidationContext<String>) in
            return context.subject.starts(with: "he")
        }
        let v2 = { (context: ValidationContext<String>) in
            return context.subject.count == 5
        }

        XCTAssertTrue((v1 || v2)(dummyContext(for: "hello")))
        XCTAssertTrue((v1 || v2)(dummyContext(for: "heads up")))
        XCTAssertTrue((v1 || v2)(dummyContext(for: "12345")))
        XCTAssertFalse((v1 || v2)(dummyContext(for: "look out")))
    }

    // MARK: Context KeyPath -> Bool
    func test_context_equals_toBool() {
        let v = \ValidationContext<String>.subject.count == 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_context_notEquals_toBool() {
        let v = \ValidationContext<String>.subject.count != 8

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_context_lessThan_toBool() {
        let v = \ValidationContext<String>.subject.count < 8

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_context_greaterThan_toBool() {
        let v = \ValidationContext<String>.subject.count > 4

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "hey")))
    }

    func test_context_lessThanOrEqualTo_toBool() {
        let v = \ValidationContext<String>.subject.count <= 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "1234")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_context_greaterThanOrEqualTo_toBool() {
        let v = \ValidationContext<String>.subject.count >= 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "hey")))
    }

    // MARK: Subject KeyPath -> Bool
    func test_subject_equals_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count == 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_subject_notEquals_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count != 8

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_subject_lessThan_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count < 8

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_subject_greaterThan_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count > 4

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "hey")))
    }

    func test_subject_lessThanOrEqualTo_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count <= 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "1234")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_subject_greaterThanOrEqualTo_toBool() {
        let v: (ValidationContext<String>) -> Bool = \String.count >= 5

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "hey")))
    }

    // MARK: Methods
    func test_context_take() {
        let v = take(\ValidationContext<String>.subject) { $0.count == 5 }

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_subject_take() {
        let v: (ValidationContext<String>) -> Bool = take(\.count) { $0 == 5 }

        XCTAssertTrue(v(dummyContext(for: "hello")))
        XCTAssertTrue(v(dummyContext(for: "12345")))
        XCTAssertFalse(v(dummyContext(for: "heads up")))
    }

    func test_context_lift() {
        let v = Validation(
            description: "int is 5",
            check: \.self == 5
        )

        XCTAssertTrue(
            lift(\.subject.count, into: v)(dummyContext(for: "hello")).isEmpty
        )
        XCTAssertTrue(
            lift(\.subject.count, into: v)(dummyContext(for: "12345")).isEmpty
        )
        XCTAssertFalse(
            lift(\.subject.count, into: v)(dummyContext(for: "heads up")).isEmpty
        )
    }

    func test_subject_lift() {
        let v = Validation(
            description: "int is 5",
            check: \.self == 5
        )

        XCTAssertTrue(
            lift(\.count, into: v)(dummyContext(for: "hello")).isEmpty
        )
        XCTAssertTrue(
            lift(\.count, into: v)(dummyContext(for: "12345")).isEmpty
        )
        XCTAssertFalse(
            lift(\.count, into: v)(dummyContext(for: "heads up")).isEmpty
        )
    }

    func test_context_unwrap() {
        let v = Validation<Int>(
            description: "string is 'H'",
            check: \.self == 1
        )

        XCTAssertTrue(
            unwrap(\.subject.first?.wholeNumberValue, into: v)(dummyContext(for: "12345")).isEmpty
        )
        XCTAssertFalse(
            unwrap(\.subject.first?.wholeNumberValue, into: v)(dummyContext(for: "hello")).isEmpty
        )
        XCTAssertTrue(
            unwrap(\.subject.first?.wholeNumberValue, into: v)(dummyContext(for: "1eads up")).isEmpty
        )
        // default unwrap nil error message
        XCTAssertFalse(
            unwrap(\.subject.first?.wholeNumberValue, into: v)(dummyContext(for: "")).isEmpty
        )
        // given description
        XCTAssertFalse(
            unwrap(\.subject.first?.wholeNumberValue, into: v, description: "test")(dummyContext(for: "")).isEmpty
        )
    }

    func test_subject_unwrap() {
        let v = Validation<Int>(
            description: "character is 'h'",
            check: \.self == 1
        )

        XCTAssertTrue(
            unwrap(\.first?.wholeNumberValue, into: v)(dummyContext(for: "12345")).isEmpty
        )
        XCTAssertFalse(
            unwrap(\.first?.wholeNumberValue, into: v)(dummyContext(for: "hello")).isEmpty
        )
        XCTAssertTrue(
            unwrap(\.first?.wholeNumberValue, into: v)(dummyContext(for: "1eads up")).isEmpty
        )
        // default unwrap nil error message
        XCTAssertFalse(
            unwrap(\.first?.wholeNumberValue, into: v)(dummyContext(for: "")).isEmpty
        )
        // given description
        XCTAssertFalse(
            unwrap(\.first?.wholeNumberValue, into: v, description: "test")(dummyContext(for: "")).isEmpty
        )
    }

    func test_subject_lookup() {
        let v = Validation<OpenAPI.Parameter>(
            description: "parameter is named test",
            check: \.name == "test"
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/test": .init(
                    parameters: [
                        .reference(.component(named: "test1")), // passes  validation
                        .reference(.component(named: "test2")), // wrong name
                        .reference(.component(named: "test3")) // not found
                    ]
                )
            ],
            components: .init(
                parameters: [
                    "test1": .init(name: "test", context: .header, content: [:]),
                    "test2": .init(name: "test2", context: .query, content: [:])
                ]
            )
        )

        let context = ValidationContext<OpenAPI.PathItem>(document: document, subject: document.paths["/test"]!.pathItem!, codingPath: [])

        // passses
        XCTAssertTrue(
            lookup(\OpenAPI.PathItem.parameters[0], thenApply: v)(context).isEmpty
        )
        // wrong name
        XCTAssertFalse(
            lookup(\OpenAPI.PathItem.parameters[1], thenApply: v)(context).isEmpty
        )
        // not found reference
        XCTAssertFalse(
            lookup(\OpenAPI.PathItem.parameters[2], thenApply: v)(context).isEmpty
        )
    }

    func test_subject_unwrapAndlookup() {
        let v = Validation<OpenAPI.Parameter>(
            description: "parameter is named test",
            check: \.name == "test"
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/test": .init(
                    parameters: [
                        .reference(.component(named: "test1")), // passes  validation
                        .reference(.component(named: "test2")), // wrong name
                        .reference(.component(named: "test3")) // not found
                    ]
                )
            ],
            components: .init(
                parameters: [
                    "test1": .init(name: "test", context: .header, content: [:]),
                    "test2": .init(name: "test2", context: .query, content: [:])
                ]
            )
        )

        let context = ValidationContext<OpenAPI.Document>(document: document, subject: document, codingPath: [])

        // passes
        XCTAssertTrue(
            unwrapAndLookup(\OpenAPI.Document.paths["/test"]?.pathItem?.parameters[0], thenApply: v)(context).isEmpty
        )
        // wrong name
        XCTAssertFalse(
            unwrapAndLookup(\OpenAPI.Document.paths["/test"]?.pathItem?.parameters[1], thenApply: v)(context).isEmpty
        )
        // not found reference
        XCTAssertFalse(
            unwrapAndLookup(\OpenAPI.Document.paths["/test"]?.pathItem?.parameters[2], thenApply: v)(context).isEmpty
        )
        // nil keypath
        XCTAssertFalse(
            unwrapAndLookup(\OpenAPI.Document.paths["/test2"]?.pathItem?.parameters.first, thenApply: v)(context).isEmpty
        )
    }

    func test_allCombinator() {
        let v1 = Validation<String>(
            description: "String is more than 5 characters",
            check: \.count > 5
        )
        let v2 = Validation<String>(
            description: "String starts with 'H'",
            check: \.first == "H"
        )

        XCTAssertTrue(
            all(v1, v2)(dummyContext(for: "Halloween")).isEmpty
        )
        XCTAssertFalse(
            all(v1, v2)(dummyContext(for: "Hello")).isEmpty
        )
        XCTAssertFalse(
            all(v1, v2)(dummyContext(for: "Nanoparticle")).isEmpty
        )
    }
}

fileprivate func dummyContext(for string: String) -> ValidationContext<String> {
    .init(document: testDocument, subject: string, codingPath: [])
}

fileprivate let testDocument = OpenAPI.Document(
    info: .init(title: "test", version: "1.0"),
    servers: [],
    paths: [:],
    components: .noComponents
)
