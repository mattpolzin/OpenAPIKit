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
        func assertNoGeneralProperties(_ fragment: JSONSchema, file: StaticString = #file, line: UInt = #line) {
            XCTAssertNil(fragment.allowedValues, file: (file), line: line)
            XCTAssertEqual(fragment.deprecated, false, file: (file), line: line)
            XCTAssertNil(fragment.description, file: (file), line: line)
            XCTAssertNil(fragment.discriminator, file: (file), line: line)
            XCTAssertTrue(fragment.examples.isEmpty, file: (file), line: line)
            XCTAssertNil(fragment.externalDocs, file: (file), line: line)
            XCTAssertEqual(fragment.formatString ?? "", "", file: (file), line: line)
            XCTAssertEqual(fragment.nullable, false, file: (file), line: line)
            XCTAssertEqual(fragment.readOnly, false, file: (file), line: line)
            XCTAssertEqual(fragment.writeOnly, false, file: (file), line: line)
            XCTAssertNil(fragment.title, file: (file), line: line)
        }

        // minimal
        assertNoGeneralProperties(JSONSchema.fragment(.init()))
        assertNoGeneralProperties(JSONSchema.integer(.init(), .init()))
        assertNoGeneralProperties(JSONSchema.number(.init(), .init()))
        assertNoGeneralProperties(JSONSchema.array(.init(), .init()))
        assertNoGeneralProperties(JSONSchema.object(.init(), .init(properties: [:])))
        assertNoGeneralProperties(JSONSchema.reference(.component(named: "test")))

        func assertSameGeneralProperties(_ fragment: JSONSchema, as properties: JSONSchema.CoreContext<JSONTypeFormat.AnyFormat>, file: StaticString = #file, line: UInt = #line) {
            XCTAssertEqual(fragment.allowedValues, properties.allowedValues, file: (file), line: line)
            XCTAssertEqual(fragment.deprecated, properties.deprecated, file: (file), line: line)
            XCTAssertEqual(fragment.description, properties.description, file: (file), line: line)
            XCTAssertEqual(fragment.discriminator, properties.discriminator, file: (file), line: line)
            XCTAssertEqual(fragment.examples, properties.examples, file: (file), line: line)
            XCTAssertEqual(fragment.externalDocs, properties.externalDocs, file: (file), line: line)
            XCTAssertEqual(fragment.formatString, properties.formatString, file: (file), line: line)
            XCTAssertEqual(fragment.nullable, properties.nullable, file: (file), line: line)
            XCTAssertEqual(fragment.readOnly, properties.readOnly, file: (file), line: line)
            XCTAssertEqual(fragment.title, properties.title, file: (file), line: line)
            XCTAssertEqual(fragment.writeOnly, properties.writeOnly, file: (file), line: line)
        }

        // maximal
        let generalProperties = JSONSchema.CoreContext<JSONTypeFormat.AnyFormat>(format: .other("date"), nullable: false, permissions: .readWrite, deprecated: false, title: "Date", description: "a date", discriminator: .init(propertyName: "test"), externalDocs: .init(url: URL(string: "http://url.com")!), allowedValues: [], examples: ["2020-01-01"])
        let t1 = JSONSchema.fragment(generalProperties)
        assertSameGeneralProperties(t1, as: generalProperties)
        let t2 = JSONSchema.integer(generalProperties.transformed(), .init(multipleOf: 10, maximum: (20, exclusive: false), minimum: (0, exclusive: true)))
        assertSameGeneralProperties(t2, as: generalProperties)
        let t3 = JSONSchema.number(generalProperties.transformed(), .init(multipleOf: 12.5, maximum: (25, exclusive: false), minimum: (0, exclusive: false)))
        assertSameGeneralProperties(t3, as: generalProperties)
        let t4 = JSONSchema.string(generalProperties.transformed(), .init(maxLength: 5, minLength: 1, pattern: ".*"))
        assertSameGeneralProperties(t4, as: generalProperties)
        let t5 = JSONSchema.array(generalProperties.transformed(), .init(items: .string, maxItems: 7, minItems: 2, uniqueItems: true))
        assertSameGeneralProperties(t5, as: generalProperties)
        let t6 = JSONSchema.object(generalProperties.transformed(), .init(properties: ["hello": .string], additionalProperties: .init(.string), maxProperties: 100, minProperties: 0))
        assertSameGeneralProperties(t6, as: generalProperties)
    }

    func test_jsonType() {
        let coreContext = JSONSchema.fragment(.init())
        XCTAssertNil(coreContext.jsonType)
        let booleanContext = JSONSchema.boolean(.init())
        XCTAssertEqual(booleanContext.jsonType, .boolean)
        let integerContext = JSONSchema.integer(.init(), .init())
        XCTAssertEqual(integerContext.jsonType, .integer)
        let numberContext = JSONSchema.number(.init(), .init())
        XCTAssertEqual(numberContext.jsonType, .number)
        let stringContext = JSONSchema.string(.init(), .init())
        XCTAssertEqual(stringContext.jsonType, .string)
        let arrayContext = JSONSchema.array(.init(), .init())
        XCTAssertEqual(arrayContext.jsonType, .array)
        let objectContext = JSONSchema.object(.init(), .init(properties: [:]))
        XCTAssertEqual(objectContext.jsonType, .object)
    }

    func test_IntegerContextFromNumericContext() {
        let numeric1 = JSONSchema.NumericContext(maximum: (5.5, exclusive: false))
        let integer1 = JSONSchema.IntegerContext(from: numeric1)
        XCTAssertNil(integer1)

        let numeric2 = JSONSchema.NumericContext(minimum: (5.5, exclusive: false))
        let integer2 = JSONSchema.IntegerContext(from: numeric2)
        XCTAssertNil(integer2)

        let numeric3 = JSONSchema.NumericContext(multipleOf: 5.5)
        let integer3 = JSONSchema.IntegerContext(from: numeric3)
        XCTAssertNil(integer3)

        let numeric4 = JSONSchema.NumericContext(multipleOf: 10, maximum: (100, exclusive: false), minimum: (0, exclusive: false))
        let integer4 = JSONSchema.IntegerContext(from: numeric4)
        XCTAssertEqual(integer4?.maximum?.exclusive, false)
        XCTAssertEqual(integer4?.minimum?.exclusive, false)
        XCTAssertEqual(integer4?.maximum?.value, 100)
        XCTAssertEqual(integer4?.minimum?.value, 0)
        XCTAssertEqual(integer4?.multipleOf, 10)

        let numeric5 = JSONSchema.NumericContext(maximum: (100, exclusive: true), minimum: (0, exclusive: true))
        let integer5 = JSONSchema.IntegerContext(from: numeric5)
        XCTAssertEqual(integer5?.maximum?.exclusive, true)
        XCTAssertEqual(integer5?.minimum?.exclusive, true)
        XCTAssertEqual(integer5?.maximum?.value, 100)
        XCTAssertEqual(integer5?.minimum?.value, 0)
        XCTAssertNil(integer5?.multipleOf)

        let numeric6 = JSONSchema.NumericContext(multipleOf: 10, minimum: (0, exclusive: false))
        let integer6 = JSONSchema.IntegerContext(from: numeric6)
        XCTAssertEqual(integer6?.minimum?.exclusive, false)
        XCTAssertNil(integer6?.maximum)
        XCTAssertEqual(integer6?.minimum?.value, 0)
        XCTAssertEqual(integer6?.multipleOf, 10)

        let numeric7 = JSONSchema.NumericContext(multipleOf: 10, maximum: (100, exclusive: false), minimum: (0, exclusive: false))
        let integer7 = JSONSchema.IntegerContext(from: numeric7)
        XCTAssertEqual(integer7?.maximum?.exclusive, false)
        XCTAssertEqual(integer7?.minimum?.exclusive, false)
        XCTAssertEqual(integer7?.maximum?.value, 100)
        XCTAssertEqual(integer7?.minimum?.value, 0)
        XCTAssertEqual(integer7?.multipleOf, 10)

        let numeric8 = JSONSchema.NumericContext(multipleOf: 10, maximum: (100, exclusive: false))
        let integer8 = JSONSchema.IntegerContext(from: numeric8)
        XCTAssertEqual(integer8?.maximum?.exclusive, false)
        XCTAssertEqual(integer8?.maximum?.value, 100)
        XCTAssertNil(integer8?.minimum)
        XCTAssertEqual(integer8?.multipleOf, 10)

        let numeric9 = JSONSchema.NumericContext(multipleOf: 10, maximum: (100, exclusive: false), minimum: (0, exclusive: false))
        let integer9 = JSONSchema.IntegerContext(from: numeric9)
        XCTAssertEqual(integer9?.maximum?.exclusive, false)
        XCTAssertEqual(integer9?.minimum?.exclusive, false)
        XCTAssertEqual(integer9?.maximum?.value, 100)
        XCTAssertEqual(integer9?.minimum?.value, 0)
        XCTAssertEqual(integer9?.multipleOf, 10)
    }
}

// MARK: - Codable Tests
extension SchemaFragmentTests {

    func test_decodeWarnsWithConflictingProperties() throws {
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

        let warnResult = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(warnResult.warnings.count, 1)
        XCTAssertEqual(warnResult.warnings.first?.localizedDescription, "Inconsistency encountered when parsing `Schema`: A schema contains properties for multiple types of schemas, namely: [\"array\", \"object\"]..")
        // we are actually at the root path in this test case so the
        // following should be an empty string!
        XCTAssertEqual(warnResult.warnings.first?.codingPathString, "")

        XCTAssertEqual(warnResult.value, .array(.init(), .init(items: .string)))
    }

    func test_decodeWarnsWithTypeAndPropertyConflict() throws {
        let t =
        """
        {
            "type": "object",
            "items": {
                "type" : "string"
            }
        }
        """.data(using: .utf8)!

        let warnResult = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(warnResult.warnings.count, 1)
        XCTAssertEqual(warnResult.warnings.first?.localizedDescription, "Inconsistency encountered when parsing `OpenAPI Schema`: Found schema attributes not consistent with the type specified: object. Specifically, attributes for these other types: [\"array\"].")
        // we are actually at the root path in this test case so the
        // following should be an empty string!
        XCTAssertEqual(warnResult.warnings.first?.codingPathString, "")

        XCTAssertEqual(warnResult.value, .object(.init(), .init(properties: [:])))
    }

    func test_decodeFailsWithIntegerWithFloatingPointMin() {
        let t =
        """
        {
            "type": "integer",
            "minimum": 10.5
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchema.self, from: t))
    }

    func test_decodeWarnsWithInvalidReference() throws {
        let t1 =
        """
        {
            "$ref": "not a ref !@#$%%^"
        }
        """.data(using: .utf8)!

        // should be a schema reference, not a response reference.
        let t2 =
        """
        {
            "$ref": "#/components/responses/test"
        }
        """.data(using: .utf8)!

        let warnResult1 = try orderUnstableDecode(JSONSchema.self, from: t1)

        XCTAssertEqual(warnResult1.warnings.count, 1)
        // NOTE: Not a very informative warning, would like to do better.
        XCTAssertEqual(warnResult1.warnings.first?.localizedDescription, "Inconsistency encountered when parsing `OpenAPI Schema`: Found nothing but unsupported attributes..")
        // we are actually at the root path in this test case so the
        // following should be an empty string!
        XCTAssertEqual(warnResult1.warnings.first?.codingPathString, "")

        let warnResult2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(warnResult2.warnings.count, 1)
        // NOTE: Not a very informative warning, would like to do better.
        XCTAssertEqual(warnResult2.warnings.first?.localizedDescription, "Inconsistency encountered when parsing `OpenAPI Schema`: Found nothing but unsupported attributes..")
        // we are actually at the root path in this test case so the
        // following should be an empty string!
        XCTAssertEqual(warnResult2.warnings.first?.codingPathString, "")
    }

    func test_generalEncode() throws {
        let t = JSONSchema.fragment(.init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {

            }
            """
        )

        let t2 = JSONSchema.fragment(.init(format: .other("date"), permissions: .readOnly, title: "creation date"))

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
        let t1 = "{}".data(using: .utf8)!

        let decoded1 = try orderUnstableDecode(JSONSchema.self, from: t1)

        XCTAssertEqual(decoded1, JSONSchema.fragment(.init()))

        let t2 =
        """
        {
          "format" : "date",
          "readOnly" : true,
          "title" : "creation date"
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(
            decoded2,
            JSONSchema.fragment(.init(format: .other("date"), permissions: .readOnly, title: "creation date"))
        )
    }

    func test_booleanEncode() throws {
        let t = JSONSchema.boolean(.init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "boolean"
            }
            """
        )

        let t2 = JSONSchema.boolean(.init(description: "hello"))

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

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.boolean(.init()))

        let t2 =
        """
        {
            "type": "boolean",
            "description": "hello world"
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.boolean(.init(description: "hello world")))
    }

    func test_integerEncode() throws {
        let t = JSONSchema.integer(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "integer"
            }
            """
        )

        let t2 = JSONSchema.integer(.init(title: "hi"), .init())

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

        let t3 = JSONSchema.integer(.init(), .init(minimum: (10, exclusive: false)))

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

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.integer(.init(), .init()))

        let t2 =
        """
        {
          "title" : "hi",
          "type" : "integer"
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.integer(.init(title: "hi"), .init()))

        let t3 =
        """
        {
          "minimum" : 10,
          "type" : "integer"
        }
        """.data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchema.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchema.integer(.init(), .init(minimum: (10, exclusive: false))))
    }

    func test_numberEncode() throws {
        let t = JSONSchema.number(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "number"
            }
            """
        )

        let t2 = JSONSchema.number(.init(title: "hi"), .init())

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

        let t3 = JSONSchema.number(.init(), .init(minimum: (10, exclusive: false)))

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

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.number(.init(), .init()))

        let t2 =
        """
        {
          "title" : "hi",
          "type" : "number"
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.number(.init(title: "hi"), .init()))

        let t3 =
        """
        {
          "minimum" : 10,
          "type" : "number"
        }
        """.data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchema.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchema.number(.init(), .init(minimum: (10, exclusive: false))))

        let t4 =
        """
        {
          "minimum" : 10.5
        }
        """.data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchema.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchema.number(.init(), .init(minimum: (10.5, exclusive: false))))
    }

    func test_stringEncode() throws {
        let t = JSONSchema.string(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "string"
            }
            """
        )

        let t2 = JSONSchema.string(.init(permissions: nil), .init())

        let encoded2 = try orderUnstableTestStringFromEncoding(of: t2)

        assertJSONEquivalent(
            encoded2,
            """
            {
              "type" : "string"
            }
            """
        )

        let t3 = JSONSchema.string(.init(), .init(maxLength: 3))

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

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.string(.init(), .init()))

        let t2 =
        """
        {
          "type" : "string",
          "writeOnly" : false
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.string(.init(permissions: .readWrite), .init()))

        let t3 =
        """
        {
          "maxLength" : 3,
          "type" : "string"
        }
        """.data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchema.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchema.string(.init(), .init(maxLength: 3)))

        let t4 =
        """
        {
          "minLength" : 7
        }
        """.data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchema.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchema.string(.init(), .init(minLength: 7)))
    }

    func test_arrayEncode() throws {
        let t = JSONSchema.array(.init(), .init())

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "array"
            }
            """
        )

        let t2 = JSONSchema.array(.init(permissions: .writeOnly), .init())

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

        let t3 = JSONSchema.array(.init(), .init(uniqueItems: true))

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

        let t4 = JSONSchema.array(.init(), .init(items: .string))

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

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.array(.init(), .init()))

        let t2 =
        """
        {
          "type" : "array",
          "writeOnly" : true
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.array(.init(permissions: .writeOnly), .init()))

        let t3 =
        """
        {
          "maxItems" : 3,
          "type" : "array"
        }
        """.data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchema.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchema.array(.init(), .init(maxItems: 3)))

        let t4 =
        """
        {
          "minItems" : 7
        }
        """.data(using: .utf8)!

        let decoded4 = try orderUnstableDecode(JSONSchema.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchema.array(.init(), .init(minItems: 7)))

        let t5 =
        """
        {
          "items" : {
            "type" : "string"
          }
        }
        """.data(using: .utf8)!

        let decoded5 = try orderUnstableDecode(JSONSchema.self, from: t5)

        XCTAssertEqual(decoded5, JSONSchema.array(.init(), .init(items: .string)))

        let t6 =
        """
        {
          "items" : {
            "type" : "string"
          },
          "prefixItems": [
            {
              "type" : "integer"
            }
          ]
        }
        """.data(using: .utf8)!

        let decoded6 = try orderUnstableDecode(JSONSchema.self, from: t6)

        XCTAssertEqual(decoded6, JSONSchema.array(.init(), .init(items: .string, prefixItems: [.integer])))
    }

    func test_objectEncode() throws {
        let t = JSONSchema.object(.init(), .init(properties: [:]))

        let encoded = try orderUnstableTestStringFromEncoding(of: t)

        assertJSONEquivalent(
            encoded,
            """
            {
              "type" : "object"
            }
            """
        )

        let t2 = JSONSchema.object(.init(permissions: .writeOnly), .init(properties: [:]))

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

        let t3 = JSONSchema.object(.init(), .init(properties: ["hello": .fragment(.init(required: true))]))

        let encoded3 = try orderUnstableTestStringFromEncoding(of: t3)

        assertJSONEquivalent(
            encoded3,
            """
            {
              "properties" : {
                "hello" : {

                }
              },
              "required" : [
                "hello"
              ],
              "type" : "object"
            }
            """
        )

        let t4 = JSONSchema.object(.init(), .init(properties: ["hello": .string(required: false)]))

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

    func test_objectDecode() throws {
        let t =
        """
        {
          "type" : "object"
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t)

        XCTAssertEqual(decoded, JSONSchema.object(.init(), .init(properties: [:])))

        let t2 =
        """
        {
          "type" : "object",
          "writeOnly" : true
        }
        """.data(using: .utf8)!

        let decoded2 = try orderUnstableDecode(JSONSchema.self, from: t2)

        XCTAssertEqual(decoded2, JSONSchema.object(.init(permissions: .writeOnly), .init(properties: [:])))

        // t3 tests that a required array without any properties will decode as
        // an object with a required property by the given name that is a fragment
        // with nothing specified about it other than it is required.
        let t3 =
        """
        {
          "required" : [
            "hello"
          ],
          "type" : "object"
        }
        """.data(using: .utf8)!

        let decoded3 = try orderUnstableDecode(JSONSchema.self, from: t3)

        XCTAssertEqual(decoded3, JSONSchema.object(.init(), .init(properties: ["hello": .fragment(.init(required: true, _inferred: true))])))
        XCTAssertEqual(decoded3.objectContext?.properties["hello"]?.inferred, true)

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

        let decoded4 = try orderUnstableDecode(JSONSchema.self, from: t4)

        XCTAssertEqual(decoded4, JSONSchema.object(.init(), .init(properties: ["hello": .string(required: false)])))

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

        let decoded5 = try orderUnstableDecode(JSONSchema.self, from: t5)

        XCTAssertEqual(decoded5, JSONSchema.object(.init(), .init(properties: ["hello": .string(required: false)])))
    }

    func test_referenceEncode() throws {
        let t1 = JSONSchema.reference(.component(named: "test"))

        let encoded = try orderUnstableTestStringFromEncoding(of: t1)

        assertJSONEquivalent(
            encoded,
            """
            {
              "$ref" : "#\\/components\\/schemas\\/test"
            }
            """
        )
    }

    func test_referenceDecode() throws {
        let t1 =
        """
        {
          "$ref": "#/components/schemas/test"
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: t1)

        XCTAssertEqual(decoded, .reference(.component(named: "test")))
    }
}
