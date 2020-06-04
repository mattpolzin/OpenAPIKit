//
//  ValidationTests.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import Foundation
import XCTest
@testable import OpenAPIKit

final class ValidationTests: XCTestCase {
    func test_optionalValidation() {
        let validation = Validation<String>(validate: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors = check("hello", in: testDocument, at: [])
        #else
        let errors = check.attempt(on: "hello", in: testDocument, at: [])
        #endif
        XCTAssertEqual(errors.map { $0.description }, [ "because at path: " ])

        #if swift(>=5.2)
        let errors2 = check("hello" as String?, in: testDocument, at: [])
        #else
        let errors2 = check.attempt(on: "hello" as String?, in: testDocument, at: [])
        #endif
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_wrongTypeValidation() {
        let validation = Validation<String>(validate: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors2 = check(10, in: testDocument, at: [])
        #else
        let errors2 = check.attempt(on: 10, in: testDocument, at: [])
        #endif
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_failsPredicateValidation() {
        let validation = Validation<String>(if: { _ in false }, validate: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors2 = check("hi", in: testDocument, at: [])
        #else
        let errors2 = check.attempt(on: "hi", in: testDocument, at: [])
        #endif
        XCTAssertTrue(errors2.isEmpty)
    }
}

fileprivate let testDocument = OpenAPI.Document(
    info: .init(title: "hi", version: "1.0"),
    servers: [],
    paths: [:],
    components: .noComponents
)
