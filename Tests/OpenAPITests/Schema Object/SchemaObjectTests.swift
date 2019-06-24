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
        let floatNumber = JSONSchemaObject.number(.init(format: .float, required: true), .init())
        let doubleNumber = JSONSchemaObject.number(.init(format: .double, required: true), .init())
        let integer = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
        let integer32 = JSONSchemaObject.integer(.init(format: .int32, required: true), .init())
        let integer64 = JSONSchemaObject.integer(.init(format: .int64, required: true), .init())
        let string = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
        let byteString = JSONSchemaObject.string(.init(format: .byte, required: true), .init())
        let binaryString = JSONSchemaObject.string(.init(format: .binary, required: true), .init())
        let dateString = JSONSchemaObject.string(.init(format: .date, required: true), .init())
        let dateTimeString = JSONSchemaObject.string(.init(format: .dateTime, required: true), .init())
        let passwordString = JSONSchemaObject.string(.init(format: .password, required: true), .init())
        let allOf = JSONSchemaObject.all(of: [boolean])
        let anyOf = JSONSchemaObject.any(of: [boolean])
        let oneOf = JSONSchemaObject.one(of: [boolean])
        let not = JSONSchemaObject.not(boolean)
        let reference = JSONSchemaObject.reference(.file("hello/world.json#/hello"))

        XCTAssertEqual(boolean.jsonTypeFormat, .boolean(.unspecified))
        XCTAssertEqual(object.jsonTypeFormat, .object(.unspecified))
        XCTAssertEqual(array.jsonTypeFormat, .array(.unspecified))
        XCTAssertEqual(number.jsonTypeFormat, .number(.unspecified))
        XCTAssertEqual(floatNumber.jsonTypeFormat, .number(.float))
        XCTAssertEqual(doubleNumber.jsonTypeFormat, .number(.double))
        XCTAssertEqual(integer.jsonTypeFormat, .integer(.unspecified))
        XCTAssertEqual(integer32.jsonTypeFormat, .integer(.int32))
        XCTAssertEqual(integer64.jsonTypeFormat, .integer(.int64))
        XCTAssertEqual(string.jsonTypeFormat, .string(.unspecified))
        XCTAssertEqual(byteString.jsonTypeFormat, .string(.byte))
        XCTAssertEqual(binaryString.jsonTypeFormat, .string(.binary))
        XCTAssertEqual(dateString.jsonTypeFormat, .string(.date))
        XCTAssertEqual(dateTimeString.jsonTypeFormat, .string(.dateTime))
        XCTAssertEqual(passwordString.jsonTypeFormat, .string(.password))
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
        let optionalBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: false))
        let nullableBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true, nullable: true))
        let allowedValueBoolean = JSONSchemaObject.boolean(.init(format: .unspecified, required: true))
            .with(allowedValues: [true])

        testAllSharedSimpleContextEncoding(typeName: "boolean",
                                           requiredEntity: requiredBoolean,
                                           optionalEntity: optionalBoolean,
                                           nullableEntity: nullableBoolean,
                                           allowedValues: (entity: allowedValueBoolean,
                                                           value: "true"))
    }

    func test_decodeBoolean() {
        // TODO:
    }

    func test_encodeObject() {
        // TODO:
    }

    func test_decodeObject() {
        // TODO:
    }

    func test_encodeObjectWithMaxProperties() {
        // TODO:
    }

    func test_decodeObjectWithMaxProperties() {
        // TODO:
    }

    func test_encodeObjectWithMinProperties() {
        // TODO:
    }

    func test_decodeObjectWithMinProperties() {
        // TODO:
    }

    func test_encodeObjectWithAdditionalProperties() {
        // TODO:
    }

    func test_decodeObjectWithAdditionalProperties() {
        // TODO:
    }

    func test_encodeObjectWithRequiredProperties() {
        // TODO:
    }

    func test_decodeObjectWithRequiredProperties() {
        // TODO:
    }

    func test_encodeArray() {
        let requiredArray = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init())
        let optionalArray = JSONSchemaObject.array(.init(format: .unspecified, required: false), .init())
        let nullableArray = JSONSchemaObject.array(.init(format: .unspecified, required: true, nullable: true), .init())
        let allowedValueArray = JSONSchemaObject.array(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [[10]])

        testAllSharedSimpleContextEncoding(typeName: "array",
                                           requiredEntity: requiredArray,
                                           optionalEntity: optionalArray,
                                           nullableEntity: nullableArray,
                                           allowedValues: (entity: allowedValueArray,
                                                           value: "[\n      10\n    ]"))
    }

    func test_decodeArray() {
        // TODO:
    }

    func test_encodeArrayWithItemsDefinition() {
        // TODO:
    }

    func test_decodeArrayWithItemsDefinition() {
        // TODO:
    }

    func test_encodeArrayWithUniqueItems() {
        // TODO:
    }

    func test_decodeArrayWithUniqueItems() {
        // TODO:
    }

    func test_encodeArrayWithMaxItems() {
        // TODO:
    }

    func test_decodeArrayWithMaxItems() {
        // TODO:
    }

    func test_encodeArrayWithMinItems() {
        // TODO:
    }

    func test_decodeArrayWithMinItems() {
        // TODO:
    }

    func test_encodeNumber() {
        let requiredNumber = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
        let optionalNumber = JSONSchemaObject.number(.init(format: .unspecified, required: false), .init())
        let nullableNumber = JSONSchemaObject.number(.init(format: .unspecified, required: true, nullable: true), .init())
        let allowedValueNumber = JSONSchemaObject.number(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [10.5])

        testAllSharedSimpleContextEncoding(typeName: "number",
                                           requiredEntity: requiredNumber,
                                           optionalEntity: optionalNumber,
                                           nullableEntity: nullableNumber,
                                           allowedValues: (entity: allowedValueNumber,
                                                           value: "10.5"))
    }

    func test_decodeNumber() {
        // TODO:
    }

    func test_encodeFloatNumber() {
        let requiredNumber = JSONSchemaObject.number(.init(format: .float, required: true), .init())
        let optionalNumber = JSONSchemaObject.number(.init(format: .float, required: false), .init())
        let nullableNumber = JSONSchemaObject.number(.init(format: .float, required: true, nullable: true), .init())
        let allowedValueNumber = JSONSchemaObject.number(.init(format: .float, required: true), .init())
            .with(allowedValues: [11.5])

        testAllSharedFormattedContextEncoding(typeName: "number",
                                              formatName: "float",
                                              requiredEntity: requiredNumber,
                                              optionalEntity: optionalNumber,
                                              nullableEntity: nullableNumber,
                                              allowedValues: (entity: allowedValueNumber,
                                                              value: "11.5"))
    }

    func test_decodeFloatNumber() {
        // TODO:
    }

    func test_encodeDoubleNumber() {
        let requiredNumber = JSONSchemaObject.number(.init(format: .double, required: true), .init())
        let optionalNumber = JSONSchemaObject.number(.init(format: .double, required: false), .init())
        let nullableNumber = JSONSchemaObject.number(.init(format: .double, required: true, nullable: true), .init())
        let allowedValueNumber = JSONSchemaObject.number(.init(format: .double, required: true), .init())
            .with(allowedValues: [12.5])

        testAllSharedFormattedContextEncoding(typeName: "number",
                                              formatName: "double",
                                              requiredEntity: requiredNumber,
                                              optionalEntity: optionalNumber,
                                              nullableEntity: nullableNumber,
                                              allowedValues: (entity: allowedValueNumber,
                                                              value: "12.5"))
    }

    func test_decodeDoubleNumber() {
        // TODO:
    }

    func test_encodeNumberWithMultipleOf() {
        // TODO:
    }

    func test_decodeNumberWithMultipleOf() {
        // TODO:
    }

    func test_encodeNumberWithMaximum() {
        // TODO:
    }

    func test_decodeNumberWithMaximum() {
        // TODO:
    }

    func test_encodeNumberWithExclusiveMaximum() {
        // TODO:
    }

    func test_decodeNumberWithExclusiveMaximum() {
        // TODO:
    }

    func test_encodeNumberWithMinimum() {
        // TODO:
    }

    func test_decodeNumberWithMinimum() {
        // TODO:
    }

    func test_encodeNumberWithExclusivceMinimum() {
        // TODO:
    }

    func test_decodeNumberWithExclusiveMinimum() {
        // TODO:
    }

    func test_encodeInteger() {
        let requiredInteger = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
        let optionalInteger = JSONSchemaObject.integer(.init(format: .unspecified, required: false), .init())
        let nullableInteger = JSONSchemaObject.integer(.init(format: .unspecified, required: true, nullable: true), .init())
        let allowedValueInteger = JSONSchemaObject.integer(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [10])

        testAllSharedSimpleContextEncoding(typeName: "integer",
                                           requiredEntity: requiredInteger,
                                           optionalEntity: optionalInteger,
                                           nullableEntity: nullableInteger,
                                           allowedValues: (entity: allowedValueInteger,
                                                           value: "10"))
    }

    func test_decodeInteger() {
        // TODO:
    }

    func test_encode32bitInteger() {
        let requiredInteger = JSONSchemaObject.integer(.init(format: .int32, required: true), .init())
        let optionalInteger = JSONSchemaObject.integer(.init(format: .int32, required: false), .init())
        let nullableInteger = JSONSchemaObject.integer(.init(format: .int32, required: true, nullable: true), .init())
        let allowedValueInteger = JSONSchemaObject.integer(.init(format: .int32, required: true), .init())
            .with(allowedValues: [11])

        testAllSharedFormattedContextEncoding(typeName: "integer",
                                              formatName: "int32",
                                              requiredEntity: requiredInteger,
                                              optionalEntity: optionalInteger,
                                              nullableEntity: nullableInteger,
                                              allowedValues: (entity: allowedValueInteger,
                                                              value: "11"))
    }

    func test_decode32bitInteger() {
        // TODO:
    }

    func test_encode64bitInteger() {
        let requiredInteger = JSONSchemaObject.integer(.init(format: .int64, required: true), .init())
        let optionalInteger = JSONSchemaObject.integer(.init(format: .int64, required: false), .init())
        let nullableInteger = JSONSchemaObject.integer(.init(format: .int64, required: true, nullable: true), .init())
        let allowedValueInteger = JSONSchemaObject.integer(.init(format: .int64, required: true), .init())
            .with(allowedValues: [12])

        testAllSharedFormattedContextEncoding(typeName: "integer",
                                              formatName: "int64",
                                              requiredEntity: requiredInteger,
                                              optionalEntity: optionalInteger,
                                              nullableEntity: nullableInteger,
                                              allowedValues: (entity: allowedValueInteger,
                                                              value: "12"))
    }

    func test_decode64bitInteger() {
        // TODO:
    }

    func test_encodeString() {
        let requiredString = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
        let optionalString = JSONSchemaObject.string(.init(format: .unspecified, required: false), .init())
        let nullableString = JSONSchemaObject.string(.init(format: .unspecified, required: true, nullable: true), .init())
        let allowedValueString = JSONSchemaObject.string(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedSimpleContextEncoding(typeName: "string",
                                           requiredEntity: requiredString,
                                           optionalEntity: optionalString,
                                           nullableEntity: nullableString,
                                           allowedValues: (entity: allowedValueString,
                                                           value: "\"hello\""))
    }

    func test_decodeString() {
        // TODO:
    }

    func test_encodeByteString() {
        let requiredString = JSONSchemaObject.string(.init(format: .byte, required: true), .init())
        let optionalString = JSONSchemaObject.string(.init(format: .byte, required: false), .init())
        let nullableString = JSONSchemaObject.string(.init(format: .byte, required: true, nullable: true), .init())
        let allowedValueString = JSONSchemaObject.string(.init(format: .byte, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(typeName: "string",
                                              formatName: "byte",
                                              requiredEntity: requiredString,
                                              optionalEntity: optionalString,
                                              nullableEntity: nullableString,
                                              allowedValues: (entity: allowedValueString,
                                                              value: "\"hello\""))
    }

    func test_decodeByteString() {
        // TODO:
    }

    func test_encodeBinaryString() {
        // TODO:
    }

    func test_decodeBinaryString() {
        // TODO:
    }

    func test_encodeDateString() {
        // TODO:
    }

    func test_decodeDateString() {
        // TODO:
    }

    func test_encodeDateTimeString() {
        // TODO:
    }

    func test_decodeDateTimeString() {
        // TODO:
    }

    func test_encodePasswordString() {
        // TODO:
    }

    func test_decodePasswordString() {
        // TODO:
    }

    func test_encodeStringWithMaxLength() {
        // TODO:
    }

    func test_decodeStringWithMaxLength() {
        // TODO:
    }

    func test_encodeStringWithMinLength() {
        // TODO:
    }

    func test_decodeStringWithMinLength() {
        // TODO:
    }

    func test_encodeStringWithPattern() {
        // TODO:
    }

    func test_decodeStringWithPattern() {
        // TODO:
    }

    func test_encodeAll() {
        // TODO:
    }

    func test_decodeAll() {
        // TODO:
    }

    func test_encodeAny() {
        // TODO:
    }

    func test_decodeAny() {
        // TODO:
    }

    func test_encodeNot() {
        // TODO:
    }

    func test_decodeNot() {
        // TODO:
    }

    func test_encodeFileReference() {
        // TODO:
    }

    func test_decodeFileReference() {
        // TODO:
    }

    func test_encodeNodeReference() {
        // TODO:
    }

    func test_decodeNodeReference() {
        // TODO:
    }
}

private func testAllSharedSimpleContextEncoding<T: Encodable>(
    typeName: String,
    requiredEntity: T,
    optionalEntity: T,
    nullableEntity: T,
    allowedValues: (entity: T, value: String)
    ) {
    XCTAssertEqual(try? testStringFromEncoding(of: requiredEntity),
"""
{
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: optionalEntity),
"""
{
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: nullableEntity),
"""
{
  "nullable" : true,
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: allowedValues.entity),
"""
{
  "enum" : [
    \(allowedValues.value)
  ],
  "type" : "\(typeName)"
}
"""
    )
}

private func testAllSharedFormattedContextEncoding<T: Encodable>(
    typeName: String,
    formatName: String,
    requiredEntity: T,
    optionalEntity: T,
    nullableEntity: T,
    allowedValues: (entity: T, value: String)
    ) {
    XCTAssertEqual(try? testStringFromEncoding(of: requiredEntity),
"""
{
  "format" : "\(formatName)",
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: optionalEntity),
"""
{
  "format" : "\(formatName)",
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: nullableEntity),
"""
{
  "format" : "\(formatName)",
  "nullable" : true,
  "type" : "\(typeName)"
}
"""
    )

    XCTAssertEqual(try? testStringFromEncoding(of: allowedValues.entity),
"""
{
  "enum" : [
    \(allowedValues.value)
  ],
  "format" : "\(formatName)",
  "type" : "\(typeName)"
}
"""
    )
}
