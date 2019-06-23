//
//  SchemaObjectTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation
import XCTest
import OpenAPI

final class SchemaObjectTests: XCTestCase {
    func test_jsonTypeFormat() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchemaObject.all(of: [boolean])
        let anyOf = JSONSchemaObject.any(of: [boolean])
        let oneOf = JSONSchemaObject.one(of: [boolean])
        let not = JSONSchemaObject.not(boolean)
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))

        XCTAssertEqual(boolean.jsonTypeFormat, .boolean(.unspecified))
        XCTAssertEqual(object.jsonTypeFormat, .object(.unspecified))
        XCTAssertEqual(array.jsonTypeFormat, .array(.unspecified))
        XCTAssertEqual(number.jsonTypeFormat, .number(.unspecified))
        XCTAssertEqual(integer.jsonTypeFormat, .integer(.unspecified))
        XCTAssertEqual(string.jsonTypeFormat, .string(.unspecified))
        XCTAssertNil(allOf.jsonTypeFormat)
        XCTAssertNil(anyOf.jsonTypeFormat)
        XCTAssertNil(oneOf.jsonTypeFormat)
        XCTAssertNil(not.jsonTypeFormat)
        XCTAssertNil(reference.jsonTypeFormat)
    }

    func test_required() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchemaObject.all(of: [boolean])
        let anyOf = JSONSchemaObject.any(of: [boolean])
        let oneOf = JSONSchemaObject.one(of: [boolean])
        let not = JSONSchemaObject.not(boolean)
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))

        XCTAssertTrue(boolean.required)
        XCTAssertTrue(object.required)
        XCTAssertTrue(array.required)
        XCTAssertTrue(number.required)
        XCTAssertTrue(integer.required)
        XCTAssertTrue(string.required)
        XCTAssertTrue(allOf.required)
        XCTAssertTrue(anyOf.required)
        XCTAssertTrue(oneOf.required)
        XCTAssertTrue(not.required)
        XCTAssertTrue(reference.required)
    }

    func test_optional() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: false))
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: false), .init(properties: [:]))
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: false), .init(items: .boolean(.init(format: .unspecified, required: false))))
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: false), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: false), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: false), .init())

        XCTAssertFalse(boolean.required)
        XCTAssertFalse(object.required)
        XCTAssertFalse(array.required)
        XCTAssertFalse(number.required)
        XCTAssertFalse(integer.required)
        XCTAssertFalse(string.required)
    }

    func test_nullable() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true, nullable: true))
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [:]))
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true, nullable: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true, nullable: true), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true, nullable: true), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true, nullable: true), .init())

        XCTAssertTrue(boolean.nullable)
        XCTAssertTrue(object.nullable)
        XCTAssertTrue(array.nullable)
        XCTAssertTrue(number.nullable)
        XCTAssertTrue(integer.nullable)
        XCTAssertTrue(string.nullable)
    }

    func test_notNullable() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchemaObject.all(of: [boolean])
        let anyOf = JSONSchemaObject.any(of: [boolean])
        let oneOf = JSONSchemaObject.one(of: [boolean])
        let not = JSONSchemaObject.not(boolean)
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))

        XCTAssertFalse(boolean.nullable)
        XCTAssertFalse(object.nullable)
        XCTAssertFalse(array.nullable)
        XCTAssertFalse(number.nullable)
        XCTAssertFalse(integer.nullable)
        XCTAssertFalse(string.nullable)
        XCTAssertFalse(allOf.nullable)
        XCTAssertFalse(anyOf.nullable)
        XCTAssertFalse(oneOf.nullable)
        XCTAssertFalse(not.nullable)
        XCTAssertFalse(reference.nullable)
    }

    func test_requiredToOptional() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
            .optionalSchemaObject()
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .optionalSchemaObject()
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
            .optionalSchemaObject()
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let allOf = JSONSchemaObject.all(of: [boolean])
            .optionalSchemaObject()
        let anyOf = JSONSchemaObject.any(of: [boolean])
            .optionalSchemaObject()
        let oneOf = JSONSchemaObject.one(of: [boolean])
            .optionalSchemaObject()
        let not = JSONSchemaObject.not(boolean)
            .optionalSchemaObject()
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))
            .optionalSchemaObject()

        XCTAssertFalse(boolean.required)
        XCTAssertFalse(object.required)
        XCTAssertFalse(array.required)
        XCTAssertFalse(number.required)
        XCTAssertFalse(integer.required)
        XCTAssertFalse(string.required)
        XCTAssertTrue(allOf.required)
        XCTAssertTrue(anyOf.required)
        XCTAssertTrue(oneOf.required)
        XCTAssertTrue(not.required)
        XCTAssertTrue(reference.required)
    }

    func test_optionalToRequired() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: false))
            .requiredSchemaObject()
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: false), .init(properties: [:]))
            .requiredSchemaObject()
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: false), .init(items: .boolean(.init(format: .unspecified, required: false))))
            .requiredSchemaObject()
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()

        XCTAssertTrue(boolean.required)
        XCTAssertTrue(object.required)
        XCTAssertTrue(array.required)
        XCTAssertTrue(number.required)
        XCTAssertTrue(integer.required)
        XCTAssertTrue(string.required)
    }

    func test_notNullableToNullable() {
        let boolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
            .nullableSchemaObject()
        let object = JSONSchemaObject.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .nullableSchemaObject()
        let array = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
            .nullableSchemaObject()
        let number = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let allOf = JSONSchemaObject.all(of: [boolean])
            .nullableSchemaObject()
        let anyOf = JSONSchemaObject.any(of: [boolean])
            .nullableSchemaObject()
        let oneOf = JSONSchemaObject.one(of: [boolean])
            .nullableSchemaObject()
        let not = JSONSchemaObject.not(boolean)
            .nullableSchemaObject()
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))
            .nullableSchemaObject()

        XCTAssertTrue(boolean.nullable)
        XCTAssertTrue(object.nullable)
        XCTAssertTrue(array.nullable)
        XCTAssertTrue(number.nullable)
        XCTAssertTrue(integer.nullable)
        XCTAssertTrue(string.nullable)
        XCTAssertFalse(allOf.nullable)
        XCTAssertFalse(anyOf.nullable)
        XCTAssertFalse(oneOf.nullable)
        XCTAssertFalse(not.nullable)
        XCTAssertFalse(reference.nullable)
    }

    func test_withInitalAllowedValues() {
        // TODO:
    }

    func test_withAddedAllowedValues() {
        // TODO:
    }

    func test_withInitialExample() {
        // TODO:
    }

    func test_withAddedExample() {
        // TODO:
    }
}

// MARK: - Codable

extension SchemaObjectTests {

    func test_encodeBoolean() {
        let requiredBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))

        XCTAssertEqual(try? testStringFromEncoding(of: requiredBoolean),
"""
{
  "type" : "boolean"
}
"""
        )

        let optionalBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: false))

        XCTAssertEqual(try? testStringFromEncoding(of: optionalBoolean),
"""
{
  "type" : "boolean"
}
"""
        )

        let nullableBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true, nullable: true))

        XCTAssertEqual(try? testStringFromEncoding(of: nullableBoolean),
"""
{
  "nullable" : true,
  "type" : "boolean"
}
"""
        )

        let allowedValueBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
            .with(allowedValues: [true])

        XCTAssertEqual(try? testStringFromEncoding(of: allowedValueBoolean),
"""
{
  "enum" : [
    true
  ],
  "type" : "boolean"
}
"""
        )
    }

    func test_decodeBoolean() {
        // TODO:
    }

    // TODO:
}
