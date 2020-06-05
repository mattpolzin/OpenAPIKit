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

        let errors = check.apply(to: "hello", at: [], in: testDocument)
        XCTAssertEqual(errors.map { $0.description }, [ "because at path: " ])

        let errors2 = check.apply(to: "hello" as String?, at: [], in: testDocument)
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_wrongTypeValidation() {
        let validation = Validation<String>(check: { _ in [ ValidationError(reason: "because", at: []) ] })
        let check = AnyValidation(validation)

        let errors2 = check.apply(to: 10, at: [], in: testDocument)
        XCTAssertTrue(errors2.isEmpty)
    }

    func test_failsPredicateValidation() {
        let validation = Validation<String>(check: { _ in [ ValidationError(reason: "because", at: []) ] }, when: { _ in false })
        let check = AnyValidation(validation)

        let errors2 = check.apply(to: "hi", at: [], in: testDocument)
        XCTAssertTrue(errors2.isEmpty)
    }
}

fileprivate let testDocument = OpenAPI.Document(
    info: .init(title: "hi", version: "1.0"),
    servers: [],
    paths: [:],
    components: .noComponents
)
