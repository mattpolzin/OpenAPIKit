//
//  SchemaFragmentTests.swift
//  
//
//  Created by Mathew Polzin on 4/21/20.
//

import Foundation
import OpenAPIKit
import XCTest

final class SchemaFragmentTests: XCTestCase {
    func test_init() {
        func assertNoGeneralProperties(_ fragment: JSONSchemaFragment, file: StaticString = #file, line: UInt = #line) {
            XCTAssertNil(fragment.allowedValues, file: file, line: line)
            XCTAssertNil(fragment.deprecated, file: file, line: line)
            XCTAssertNil(fragment.description, file: file, line: line)
            XCTAssertNil(fragment.example, file: file, line: line)
            XCTAssertNil(fragment.externalDocs, file: file, line: line)
            XCTAssertNil(fragment.format, file: file, line: line)
            XCTAssertNil(fragment.nullable, file: file, line: line)
            XCTAssertNil(fragment.readOnly, file: file, line: line)
            XCTAssertNil(fragment.title, file: file, line: line)
            XCTAssertNil(fragment.writeOnly, file: file, line: line)
        }

        // minimal
        assertNoGeneralProperties(JSONSchemaFragment.general(.init()))
        assertNoGeneralProperties(JSONSchemaFragment.integer(.init(), .init()))
        assertNoGeneralProperties(JSONSchemaFragment.number(.init(), .init()))
        assertNoGeneralProperties(JSONSchemaFragment.array(.init(), .init()))
        assertNoGeneralProperties(JSONSchemaFragment.object(.init(), .init()))

        func assertSameGeneralProperties(_ fragment: JSONSchemaFragment, as properties: JSONSchemaFragment.GeneralContext, file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual(fragment.allowedValues, properties.allowedValues, file: file, line: line)
            XCTAssertEqual(fragment.deprecated, properties.deprecated, file: file, line: line)
            XCTAssertEqual(fragment.description, properties.description, file: file, line: line)
            XCTAssertEqual(fragment.example, properties.example, file: file, line: line)
            XCTAssertEqual(fragment.externalDocs, properties.externalDocs, file: file, line: line)
            XCTAssertEqual(fragment.format, properties.format, file: file, line: line)
            XCTAssertEqual(fragment.nullable, properties.nullable, file: file, line: line)
            XCTAssertEqual(fragment.readOnly, properties.readOnly, file: file, line: line)
            XCTAssertEqual(fragment.title, properties.title, file: file, line: line)
            XCTAssertEqual(fragment.writeOnly, properties.writeOnly, file: file, line: line)
        }

        // maximal
        let generalProperties = JSONSchemaFragment.GeneralContext(format: "date", description: "a date", title: "Date", nullable: false, deprecated: false, externalDocs: .init(url: URL(string: "http://url.com")!), allowedValues: [], example: "2020-01-01", readOnly: false, writeOnly: false)
        let t1 = JSONSchemaFragment.general(generalProperties)
        assertSameGeneralProperties(t1, as: generalProperties)
        let t2 = JSONSchemaFragment.integer(generalProperties, .init(multipleOf: 10, maximum: 20, exclusiveMaximum: false, minimum: 0, exclusiveMinimum: true))
        assertSameGeneralProperties(t2, as: generalProperties)
        let t3 = JSONSchemaFragment.number(generalProperties, .init(multipleOf: 12.5, maximum: 25, exclusiveMaximum: false, minimum: 0, exclusiveMinimum: false))
        assertSameGeneralProperties(t3, as: generalProperties)
        let t4 = JSONSchemaFragment.string(generalProperties, .init(maxLength: 5, minLength: 1, pattern: ".*"))
        assertSameGeneralProperties(t4, as: generalProperties)
        let t5 = JSONSchemaFragment.array(generalProperties, .init(items: .string, maxItems: 7, minItems: 2, uniqueItems: true))
        assertSameGeneralProperties(t5, as: generalProperties)
        let t6 = JSONSchemaFragment.object(generalProperties, .init(maxProperties: 100, minProperties: 0, properties: ["hello": .string], additionalProperties: .init(.string), required: ["hello"]))
        assertSameGeneralProperties(t6, as: generalProperties)
    }

    func test_IntegerContextFromNumericContext() {
        let numeric1 = JSONSchemaFragment.NumericContext(maximum: 5.5)
        let integer1 = JSONSchemaFragment.IntegerContext(from: numeric1)
        XCTAssertNil(integer1)

        let numeric2 = JSONSchemaFragment.NumericContext(minimum: 5.5)
        let integer2 = JSONSchemaFragment.IntegerContext(from: numeric2)
        XCTAssertNil(integer2)

        let numeric3 = JSONSchemaFragment.NumericContext(multipleOf: 5.5)
        let integer3 = JSONSchemaFragment.IntegerContext(from: numeric3)
        XCTAssertNil(integer3)

        let numeric4 = JSONSchemaFragment.NumericContext(multipleOf: 10, maximum: 100, exclusiveMaximum: false, minimum: 0, exclusiveMinimum: false)
        let integer4 = JSONSchemaFragment.IntegerContext(from: numeric4)
        XCTAssertEqual(integer4?.exclusiveMaximum, false)
        XCTAssertEqual(integer4?.exclusiveMinimum, false)
        XCTAssertEqual(integer4?.maximum, 100)
        XCTAssertEqual(integer4?.minimum, 0)
        XCTAssertEqual(integer4?.multipleOf, 10)

        let numeric5 = JSONSchemaFragment.NumericContext(maximum: 100, exclusiveMaximum: true, minimum: 0, exclusiveMinimum: true)
        let integer5 = JSONSchemaFragment.IntegerContext(from: numeric5)
        XCTAssertEqual(integer5?.exclusiveMaximum, true)
        XCTAssertEqual(integer5?.exclusiveMinimum, true)
        XCTAssertEqual(integer5?.maximum, 100)
        XCTAssertEqual(integer5?.minimum, 0)
        XCTAssertNil(integer5?.multipleOf)

        let numeric6 = JSONSchemaFragment.NumericContext(multipleOf: 10, exclusiveMaximum: false, minimum: 0, exclusiveMinimum: false)
        let integer6 = JSONSchemaFragment.IntegerContext(from: numeric6)
        XCTAssertEqual(integer6?.exclusiveMaximum, false)
        XCTAssertEqual(integer6?.exclusiveMinimum, false)
        XCTAssertNil(integer6?.maximum)
        XCTAssertEqual(integer6?.minimum, 0)
        XCTAssertEqual(integer6?.multipleOf, 10)

        let numeric7 = JSONSchemaFragment.NumericContext(multipleOf: 10, maximum: 100, minimum: 0, exclusiveMinimum: false)
        let integer7 = JSONSchemaFragment.IntegerContext(from: numeric7)
        XCTAssertNil(integer7?.exclusiveMaximum)
        XCTAssertEqual(integer7?.exclusiveMinimum, false)
        XCTAssertEqual(integer7?.maximum, 100)
        XCTAssertEqual(integer7?.minimum, 0)
        XCTAssertEqual(integer7?.multipleOf, 10)

        let numeric8 = JSONSchemaFragment.NumericContext(multipleOf: 10, maximum: 100, exclusiveMaximum: false, exclusiveMinimum: false)
        let integer8 = JSONSchemaFragment.IntegerContext(from: numeric8)
        XCTAssertEqual(integer8?.exclusiveMaximum, false)
        XCTAssertEqual(integer8?.exclusiveMinimum, false)
        XCTAssertEqual(integer8?.maximum, 100)
        XCTAssertNil(integer8?.minimum)
        XCTAssertEqual(integer8?.multipleOf, 10)

        let numeric9 = JSONSchemaFragment.NumericContext(multipleOf: 10, maximum: 100, exclusiveMaximum: false, minimum: 0)
        let integer9 = JSONSchemaFragment.IntegerContext(from: numeric9)
        XCTAssertEqual(integer9?.exclusiveMaximum, false)
        XCTAssertNil(integer9?.exclusiveMinimum)
        XCTAssertEqual(integer9?.maximum, 100)
        XCTAssertEqual(integer9?.minimum, 0)
        XCTAssertEqual(integer9?.multipleOf, 10)
    }
}

// MARK: - Codable Tests
extension SchemaFragmentTests {
    func test_decodeFailsWithNoProperties() {
        let t = "{}".data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchemaFragment.self, from: t))
    }

    func test_decodeFailsWithConflictingProperties() {
        let t =
"""
{
    "properties" : {
        "hello": { "type": "string" }
    },
    "items": {
        "type" : "string"
    }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchemaFragment.self, from: t))
    }

    func test_decodeFailsWithTypeAndPropertyConflict() {
        let t =
"""
{
    "type": "object",
    "items": {
        "type" : "string"
    }
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchemaFragment.self, from: t))
    }

    func test_decodeFailsWithIntegerWithFloatingPointMin() {
        let t =
"""
{
    "type": "integer",
    "minimum": 10.5
}
""".data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchemaFragment.self, from: t))
    }

    func test_generalEncode() throws {
        let t = JSONSchemaFragment.general(.init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{

}
"""
        )

        let t2 = JSONSchemaFragment.general(.init(format: "date", title: "creation date", readOnly: true))

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "format" : "date",
  "readOnly" : true,
  "title" : "creation date"
}
"""
        )
    }

    func test_generalDecode() throws {
        let t =
"""
{
  "format" : "date",
  "readOnly" : true,
  "title" : "creation date"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(
            decoded,
            JSONSchemaFragment.general(.init(format: "date", title: "creation date", readOnly: true))
        )
    }

    func test_booleanEncode() throws {
        let t = JSONSchemaFragment.boolean(.init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "boolean"
}
"""
        )

        let t2 = JSONSchemaFragment.boolean(.init(description: "hello"))

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "description" : "hello",
  "type" : "boolean"
}
"""
        )
    }

    func test_booleanDecode() throws {
        let t =
"""
{
    "type": "boolean"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.boolean(.init()))

        let t2 =
"""
{
    "type": "boolean",
    "description": "hello world"
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.boolean(.init(description: "hello world")))
    }

    func test_integerEncode() throws {
        let t = JSONSchemaFragment.integer(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "integer"
}
"""
        )

        let t2 = JSONSchemaFragment.integer(.init(title: "hi"), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "title" : "hi",
  "type" : "integer"
}
"""
        )

        let t3 = JSONSchemaFragment.integer(.init(), .init(minimum: 10))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
"""
{
  "minimum" : 10,
  "type" : "integer"
}
"""
        )
    }

    func test_integerDecode() throws {
        let t =
"""
{
  "type" : "integer"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.integer(.init(), .init()))

        let t2 =
"""
{
  "title" : "hi",
  "type" : "integer"
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.integer(.init(title: "hi"), .init()))

        let t3 =
"""
{
  "minimum" : 10,
  "type" : "integer"
}
""".data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchemaFragment.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchemaFragment.integer(.init(), .init(minimum: 10)))
    }

    func test_numberEncode() throws {
        let t = JSONSchemaFragment.number(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "number"
}
"""
        )

        let t2 = JSONSchemaFragment.number(.init(title: "hi"), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "title" : "hi",
  "type" : "number"
}
"""
        )

        let t3 = JSONSchemaFragment.number(.init(), .init(minimum: 10))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
"""
{
  "minimum" : 10,
  "type" : "number"
}
"""
        )
    }

    func test_numberDecode() throws {
        let t =
"""
{
  "type" : "number"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.number(.init(), .init()))

        let t2 =
"""
{
  "title" : "hi",
  "type" : "number"
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.number(.init(title: "hi"), .init()))

        let t3 =
"""
{
  "minimum" : 10,
  "type" : "number"
}
""".data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchemaFragment.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchemaFragment.number(.init(), .init(minimum: 10)))

        let t4 =
"""
{
  "minimum" : 10.5
}
""".data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchemaFragment.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchemaFragment.number(.init(), .init(minimum: 10.5)))
    }

    func test_stringEncode() throws {
        let t = JSONSchemaFragment.string(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "string"
}
"""
        )

        let t2 = JSONSchemaFragment.string(.init(writeOnly: false), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "type" : "string",
  "writeOnly" : false
}
"""
        )

        let t3 = JSONSchemaFragment.string(.init(), .init(maxLength: 3))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
"""
{
  "maxLength" : 3,
  "type" : "string"
}
"""
        )
    }

    func test_stringDecode() throws {
        let t =
"""
{
  "type" : "string"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.string(.init(), .init()))

        let t2 =
"""
{
  "type" : "string",
  "writeOnly" : false
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.string(.init(writeOnly: false), .init()))

        let t3 =
"""
{
  "maxLength" : 3,
  "type" : "string"
}
""".data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchemaFragment.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchemaFragment.string(.init(), .init(maxLength: 3)))

        let t4 =
"""
{
  "minLength" : 7
}
""".data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchemaFragment.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchemaFragment.string(.init(), .init(minLength: 7)))
    }

    func test_arrayEncode() throws {
        let t = JSONSchemaFragment.array(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "array"
}
"""
        )

        let t2 = JSONSchemaFragment.array(.init(writeOnly: true), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "type" : "array",
  "writeOnly" : true
}
"""
        )

        let t3 = JSONSchemaFragment.array(.init(), .init(uniqueItems: true))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
"""
{
  "type" : "array",
  "uniqueItems" : true
}
"""
        )

        let t4 = JSONSchemaFragment.array(.init(), .init(items: .string))

        let encoded4 = try orderUnstableTestStringFromEncoding(of: t4)

        assertJSONEquivalent(
            encoded4,
"""
{
  "items" : {
    "type" : "string"
  },
  "type" : "array"
}
"""
        )
    }

    func test_arrayDecode() throws {
        let t =
"""
{
  "type" : "array"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.array(.init(), .init()))

        let t2 =
"""
{
  "type" : "array",
  "writeOnly" : true
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.array(.init(writeOnly: true), .init()))

        let t3 =
"""
{
  "maxItems" : 3,
  "type" : "array"
}
""".data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchemaFragment.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchemaFragment.array(.init(), .init(maxItems: 3)))

        let t4 =
"""
{
  "minItems" : 7
}
""".data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchemaFragment.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchemaFragment.array(.init(), .init(minItems: 7)))

        let t5 =
"""
{
  "items" : {
    "type" : "string"
  }
}
""".data(using: .utf8)!

        let decoded5 = try orderUnstableDecode(JSONSchemaFragment.self, from: t5)

        XCTAssertEqual(decoded5, JSONSchemaFragment.array(.init(), .init(items: .string(required: false))))
    }

    func test_objectEncode() throws {
        let t = JSONSchemaFragment.object(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
"""
{
  "type" : "object"
}
"""
        )

        let t2 = JSONSchemaFragment.object(.init(writeOnly: true), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
"""
{
  "type" : "object",
  "writeOnly" : true
}
"""
        )

        let t3 = JSONSchemaFragment.object(.init(), .init(required: ["hello"]))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
"""
{
  "required" : [
    "hello"
  ],
  "type" : "object"
}
"""
        )

        let t4 = JSONSchemaFragment.object(.init(), .init(properties: ["hello": .string]))

        let encoded4 = try orderUnstableTestStringFromEncoding(of: t4)

        assertJSONEquivalent(
            encoded4,
"""
{
  "properties" : {
    "hello" : {
      "type" : "string"
    }
  },
  "type" : "object"
}
"""
        )
    }

    func test_minimalObjectDecode() throws {
        let t =
"""
{
  "type" : "object"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchemaFragment.self, from: t)

        XCTAssertEqual(decoded, JSONSchemaFragment.object(.init(), .init()))

        let t2 =
"""
{
  "type" : "object",
  "writeOnly" : true
}
""".data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchemaFragment.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchemaFragment.object(.init(writeOnly: true), .init()))

        let t3 =
"""
{
  "required" : [
    "hello"
  ],
  "type" : "object"
}
""".data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchemaFragment.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchemaFragment.object(.init(), .init(required: ["hello"])))

        let t4 =
"""
{
  "properties" : {
    "hello" : {
      "type" : "string"
    }
  },
  "type" : "object"
}
""".data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchemaFragment.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchemaFragment.object(.init(), .init(properties: ["hello": .string(required: false)])))

        let t5 =
"""
{
  "properties" : {
    "hello" : {
      "type" : "string"
    }
  }
}
""".data(using: .utf8)!

        let decoded5 = try orderUnstableDecode(JSONSchemaFragment.self, from: t5)

        XCTAssertEqual(decoded5, JSONSchemaFragment.object(.init(), .init(properties: ["hello": .string(required: false)])))
    }
}
