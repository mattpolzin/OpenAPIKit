//
//  SchemaObjectYamsTests.swift
//  
//
//  Created by Mathew Polzin on 4/22/20.
//

///
/// This file exists to facilitate regression tests for Yams-specific problems encountered
/// and fixed.
///

import Foundation
import XCTest
import OpenAPIKit
@preconcurrency import Yams

final class SchemaObjectYamsTests: XCTestCase {
    func test_nullTypeDecode() throws {
        let nullString =
        """
        type: 'null'
        """

        let null = try YAMLDecoder().decode(JSONSchema.self, from: nullString)

        XCTAssertEqual(
            null,
            JSONSchema.null()
        )
    }

    func test_floatingPointWholeNumberIntegerDecode() throws {
        let integerString =
        """
        type: integer
        minimum: 1.0
        maximum: 10.0
        """

        let integer = try YAMLDecoder().decode(JSONSchema.self, from: integerString)

        XCTAssertEqual(
            integer,
            JSONSchema.integer(maximum: (10, exclusive: false), minimum: (1, exclusive: false))
        )
    }

    func test_floatingPointIntegerDecodeFails() {
        let integerString =
        """
        type: integer
        maximum: 10.2
        """

        XCTAssertThrowsError(try YAMLDecoder().decode(JSONSchema.self, from: integerString)) { error in
            XCTAssertEqual(OpenAPI.Error(from: error).localizedDescription, "Problem encountered when parsing `maximum`: Expected an Integer literal but found a floating point value (10.2).")
        }

        let integerString2 =
        """
        type: integer
        minimum: 1.1
        """

        XCTAssertThrowsError(try YAMLDecoder().decode(JSONSchema.self, from: integerString2)) { error in
            XCTAssertEqual(OpenAPI.Error(from: error).localizedDescription, "Problem encountered when parsing `minimum`: Expected an Integer literal but found a floating point value (1.1).")
        }
    }
}
