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
        let validation = Validation<String>(check: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors = check("hello", at: [], in: testDocument)
        #else
        let errors = check.attempt(on: "hello", at: [], in: testDocument)
        #endif
        XCTAssertEqual(errors.map { $0.description }, [ "because at path: " ])

        #if swift(>=5.2)
        let errors2 = check("hello" as String?, at: [], in: testDocument)
        #else
        let errors2 = check.attempt(on: "hello" as String?, at: [], in: testDocument)
        #endif
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_wrongTypeValidation() {
        let validation = Validation<String>(check: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors2 = check(10, at: [], in: testDocument)
        #else
        let errors2 = check.attempt(on: 10, at: [], in: testDocument)
        #endif
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_failsPredicateValidation() {
        let validation = Validation<String>(check: { _ in [ ValidationError(reason: "because", at: []) ] }, when: { _ in false })
        let check = AnyValidation(validation)

        #if swift(>=5.2)
        let errors2 = check("hi", at: [], in: testDocument)
        #else
        let errors2 = check.attempt(on: "hi", at: [], in: testDocument)
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
