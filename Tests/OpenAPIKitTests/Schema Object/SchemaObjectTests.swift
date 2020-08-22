//
//  SchemaObjectTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/19.
//

import Foundation
import XCTest
import OpenAPIKit

final class SchemaObjectTests: XCTestCase {
    func test_jsonTypeFormat() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let floatNumber = JSONSchema.number(.init(format: .float, required: true), .init())
        let doubleNumber = JSONSchema.number(.init(format: .double, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let integer32 = JSONSchema.integer(.init(format: .int32, required: true), .init())
        let integer64 = JSONSchema.integer(.init(format: .int64, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let byteString = JSONSchema.string(.init(format: .byte, required: true), .init())
        let binaryString = JSONSchema.string(.init(format: .binary, required: true), .init())
        let dateString = JSONSchema.string(.init(format: .date, required: true), .init())
        let dateTimeString = JSONSchema.string(.init(format: .dateTime, required: true), .init())
        let passwordString = JSONSchema.string(.init(format: .password, required: true), .init())
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        // JSONTypeFormat
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
        XCTAssertNil(undefined.jsonTypeFormat)

        // JSONType
        XCTAssertEqual(boolean.jsonTypeFormat?.jsonType, .boolean)
        XCTAssertEqual(object.jsonTypeFormat?.jsonType, .object)
        XCTAssertEqual(array.jsonTypeFormat?.jsonType, .array)
        XCTAssertEqual(number.jsonTypeFormat?.jsonType, .number)
        XCTAssertEqual(floatNumber.jsonTypeFormat?.jsonType, .number)
        XCTAssertEqual(doubleNumber.jsonTypeFormat?.jsonType, .number)
        XCTAssertEqual(integer.jsonTypeFormat?.jsonType, .integer)
        XCTAssertEqual(integer32.jsonTypeFormat?.jsonType, .integer)
        XCTAssertEqual(integer64.jsonTypeFormat?.jsonType, .integer)
        XCTAssertEqual(string.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(byteString.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(binaryString.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(dateString.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(dateTimeString.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(passwordString.jsonTypeFormat?.jsonType, .string)
        XCTAssertEqual(boolean.jsonType, .boolean)
        XCTAssertEqual(object.jsonType, .object)
        XCTAssertEqual(array.jsonType, .array)
        XCTAssertEqual(number.jsonType, .number)
        XCTAssertEqual(floatNumber.jsonType, .number)
        XCTAssertEqual(doubleNumber.jsonType, .number)
        XCTAssertEqual(integer.jsonType, .integer)
        XCTAssertEqual(integer32.jsonType, .integer)
        XCTAssertEqual(integer64.jsonType, .integer)
        XCTAssertEqual(string.jsonType, .string)
        XCTAssertEqual(byteString.jsonType, .string)
        XCTAssertEqual(binaryString.jsonType, .string)
        XCTAssertEqual(dateString.jsonType, .string)
        XCTAssertEqual(dateTimeString.jsonType, .string)
        XCTAssertEqual(passwordString.jsonType, .string)

        // SwiftType
        XCTAssert(boolean.jsonTypeFormat?.swiftType == Bool.self)
        XCTAssert(object.jsonTypeFormat?.swiftType == AnyCodable.self)
        XCTAssert(array.jsonTypeFormat?.swiftType == [AnyCodable].self)
        XCTAssert(number.jsonTypeFormat?.swiftType == Double.self)
        XCTAssert(floatNumber.jsonTypeFormat?.swiftType == Double.self)
        XCTAssert(doubleNumber.jsonTypeFormat?.swiftType == Double.self)
        XCTAssert(integer.jsonTypeFormat?.swiftType == Int.self)
        XCTAssert(integer32.jsonTypeFormat?.swiftType == Int.self)
        XCTAssert(integer64.jsonTypeFormat?.swiftType == Int.self)
        XCTAssert(string.jsonTypeFormat?.swiftType == String.self)
        XCTAssert(byteString.jsonTypeFormat?.swiftType == String.self)
        XCTAssert(binaryString.jsonTypeFormat?.swiftType == String.self)
        XCTAssert(dateString.jsonTypeFormat?.swiftType == String.self)
        XCTAssert(dateTimeString.jsonTypeFormat?.swiftType == String.self)
        XCTAssert(passwordString.jsonTypeFormat?.swiftType == String.self)
    }

    func test_required() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))


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
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: false))
        let object = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: false), .init(items: .boolean(.init(format: .unspecified, required: false))))
        let number = JSONSchema.number(.init(format: .unspecified, required: false), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: false), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: false), .init())
        let undefined = JSONSchema.fragment(.init(required: false, description: nil))

        XCTAssertFalse(boolean.required)
        XCTAssertFalse(object.required)
        XCTAssertFalse(array.required)
        XCTAssertFalse(number.required)
        XCTAssertFalse(integer.required)
        XCTAssertFalse(string.required)
        XCTAssertFalse(undefined.required)
    }

    func test_nullable() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, nullable: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, nullable: true), .init())

        XCTAssertTrue(boolean.nullable)
        XCTAssertTrue(object.nullable)
        XCTAssertTrue(array.nullable)
        XCTAssertTrue(number.nullable)
        XCTAssertTrue(integer.nullable)
        XCTAssertTrue(string.nullable)

    }

    func test_notNullable() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

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
        XCTAssertFalse(undefined.nullable)
    }

    func test_readableAndWritable() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

        XCTAssertFalse(boolean.readOnly)
        XCTAssertFalse(boolean.writeOnly)
        XCTAssertFalse(object.readOnly)
        XCTAssertFalse(object.writeOnly)
        XCTAssertFalse(array.readOnly)
        XCTAssertFalse(array.writeOnly)
        XCTAssertFalse(number.readOnly)
        XCTAssertFalse(number.writeOnly)
        XCTAssertFalse(integer.readOnly)
        XCTAssertFalse(integer.writeOnly)
        XCTAssertFalse(string.readOnly)
        XCTAssertFalse(string.writeOnly)

        XCTAssertFalse(allOf.readOnly)
        XCTAssertFalse(allOf.writeOnly)
        XCTAssertFalse(anyOf.readOnly)
        XCTAssertFalse(anyOf.writeOnly)
        XCTAssertFalse(oneOf.readOnly)
        XCTAssertFalse(oneOf.writeOnly)
        XCTAssertFalse(not.readOnly)
        XCTAssertFalse(not.writeOnly)
        XCTAssertFalse(reference.readOnly)
        XCTAssertFalse(reference.writeOnly)
        XCTAssertFalse(undefined.readOnly)
        XCTAssertFalse(undefined.writeOnly)
    }

    func test_readOnly() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, permissions: .readOnly))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, permissions: .readOnly), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, permissions: .readOnly), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, permissions: .readOnly), .init())

        XCTAssertTrue(boolean.readOnly)
        XCTAssertFalse(boolean.writeOnly)
        XCTAssertTrue(object.readOnly)
        XCTAssertFalse(object.writeOnly)
        XCTAssertTrue(array.readOnly)
        XCTAssertFalse(array.writeOnly)
        XCTAssertTrue(number.readOnly)
        XCTAssertFalse(number.writeOnly)
        XCTAssertTrue(integer.readOnly)
        XCTAssertFalse(integer.writeOnly)
        XCTAssertTrue(string.readOnly)
        XCTAssertFalse(string.writeOnly)
    }

    func test_writeOnly() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, permissions: .writeOnly))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, permissions: .writeOnly), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, permissions: .writeOnly), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())

        XCTAssertFalse(boolean.readOnly)
        XCTAssertTrue(boolean.writeOnly)
        XCTAssertFalse(object.readOnly)
        XCTAssertTrue(object.writeOnly)
        XCTAssertFalse(array.readOnly)
        XCTAssertTrue(array.writeOnly)
        XCTAssertFalse(number.readOnly)
        XCTAssertTrue(number.writeOnly)
        XCTAssertFalse(integer.readOnly)
        XCTAssertTrue(integer.writeOnly)
        XCTAssertFalse(string.readOnly)
        XCTAssertTrue(string.writeOnly)
    }

    func test_notDeprecated() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

        XCTAssertFalse(boolean.deprecated)
        XCTAssertFalse(object.deprecated)
        XCTAssertFalse(array.deprecated)
        XCTAssertFalse(number.deprecated)
        XCTAssertFalse(integer.deprecated)
        XCTAssertFalse(string.deprecated)

        XCTAssertFalse(allOf.deprecated)
        XCTAssertFalse(anyOf.deprecated)
        XCTAssertFalse(oneOf.deprecated)
        XCTAssertFalse(not.deprecated)
        XCTAssertFalse(reference.deprecated)
        XCTAssertFalse(undefined.deprecated)
    }

    func test_deprecated() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, deprecated: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, deprecated: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, deprecated: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, deprecated: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, deprecated: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, deprecated: true), .init())

        XCTAssertTrue(boolean.deprecated)
        XCTAssertTrue(object.deprecated)
        XCTAssertTrue(array.deprecated)
        XCTAssertTrue(number.deprecated)
        XCTAssertTrue(integer.deprecated)
        XCTAssertTrue(string.deprecated)
    }

    func test_title() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, title: "hello"))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, title: "hello"), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, title: "hello"), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, title: "hello"), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, title: "hello"), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, title: "hello"), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

        XCTAssertEqual(boolean.title, "hello")
        XCTAssertEqual(object.title, "hello")
        XCTAssertEqual(array.title, "hello")
        XCTAssertEqual(number.title, "hello")
        XCTAssertEqual(integer.title, "hello")
        XCTAssertEqual(string.title, "hello")

        XCTAssertNil(allOf.title)
        XCTAssertNil(anyOf.title)
        XCTAssertNil(oneOf.title)
        XCTAssertNil(not.title)
        XCTAssertNil(reference.title)
        XCTAssertNil(undefined.title)
    }

    func test_description() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, description: "hello"))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, description: "hello"), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, description: "hello"), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, description: "hello"), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, description: "hello"), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, description: "hello"), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))
        let undefinedWithDescription = JSONSchema.fragment(.init(description: "hello"))

        XCTAssertEqual(boolean.description, "hello")
        XCTAssertEqual(object.description, "hello")
        XCTAssertEqual(array.description, "hello")
        XCTAssertEqual(number.description, "hello")
        XCTAssertEqual(integer.description, "hello")
        XCTAssertEqual(string.description, "hello")
        XCTAssertEqual(undefinedWithDescription.description, "hello")

        XCTAssertNil(allOf.description)
        XCTAssertNil(anyOf.description)
        XCTAssertNil(oneOf.description)
        XCTAssertNil(not.description)
        XCTAssertNil(reference.description)
        XCTAssertNil(undefined.description)
    }

    func test_discriminator() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "name")), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())], discriminator: .init(propertyName: "name"))
        let anyOf = JSONSchema.any(of: [boolean], discriminator: .init(propertyName: "name"))
        let oneOf = JSONSchema.one(of: [boolean], discriminator: .init(propertyName: "name"))
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))
        let undefinedWithDescription = JSONSchema.fragment(.init(description: "hello"))

        XCTAssertEqual(boolean.discriminator?.propertyName, "name")
        XCTAssertEqual(object.discriminator?.propertyName, "name")
        XCTAssertEqual(array.discriminator?.propertyName, "name")
        XCTAssertEqual(number.discriminator?.propertyName, "name")
        XCTAssertEqual(integer.discriminator?.propertyName, "name")
        XCTAssertEqual(string.discriminator?.propertyName, "name")
        XCTAssertEqual(allOf.discriminator?.propertyName, "name")
        XCTAssertEqual(anyOf.discriminator?.propertyName, "name")
        XCTAssertEqual(oneOf.discriminator?.propertyName, "name")

        XCTAssertNil(undefinedWithDescription.discriminator)
        XCTAssertNil(not.discriminator)
        XCTAssertNil(reference.discriminator)
        XCTAssertNil(undefined.discriminator)
    }

    func test_externalDocs() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

        XCTAssertEqual(boolean.externalDocs, .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(object.externalDocs, .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(array.externalDocs, .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(number.externalDocs, .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(integer.externalDocs, .init(url: URL(string: "http://google.com")!))
        XCTAssertEqual(string.externalDocs, .init(url: URL(string: "http://google.com")!))

        XCTAssertNil(allOf.externalDocs)
        XCTAssertNil(anyOf.externalDocs)
        XCTAssertNil(oneOf.externalDocs)
        XCTAssertNil(not.externalDocs)
        XCTAssertNil(reference.externalDocs)
        XCTAssertNil(undefined.externalDocs)
    }

    func test_coreContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: nil))

        XCTAssertNotNil(boolean.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.BooleanFormat>)
        XCTAssertNotNil(object.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.ObjectFormat>)
        XCTAssertNotNil(array.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.ArrayFormat>)
        XCTAssertNotNil(number.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.NumberFormat>)
        XCTAssertNotNil(integer.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.IntegerFormat>)
        XCTAssertNotNil(string.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.StringFormat>)
        XCTAssertNotNil(undefined.coreContext as? JSONSchema.CoreContext<JSONTypeFormat.AnyFormat>)

        XCTAssertNil(allOf.coreContext)
        XCTAssertNil(anyOf.coreContext)
        XCTAssertNil(oneOf.coreContext)
        XCTAssertNil(not.coreContext)
        XCTAssertNil(reference.coreContext)
    }

    func test_objectContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [ "hello": .string]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        XCTAssertNil(boolean.objectContext)
        XCTAssertEqual(object.objectContext, .init(properties: ["hello": .string]))
        XCTAssertNil(array.objectContext)
        XCTAssertNil(number.objectContext)
        XCTAssertNil(integer.objectContext)
        XCTAssertNil(string.objectContext)

        XCTAssertNil(allOf.objectContext)
        XCTAssertNil(anyOf.objectContext)
        XCTAssertNil(oneOf.objectContext)
        XCTAssertNil(not.objectContext)
        XCTAssertNil(reference.objectContext)
        XCTAssertNil(undefined.objectContext)
    }

    func test_arrayContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        XCTAssertNil(boolean.arrayContext)
        XCTAssertNil(object.arrayContext)
        XCTAssertEqual(array.arrayContext, .init(items: .boolean))
        XCTAssertNil(number.arrayContext)
        XCTAssertNil(integer.arrayContext)
        XCTAssertNil(string.arrayContext)

        XCTAssertNil(allOf.arrayContext)
        XCTAssertNil(anyOf.arrayContext)
        XCTAssertNil(oneOf.arrayContext)
        XCTAssertNil(not.arrayContext)
        XCTAssertNil(reference.arrayContext)
        XCTAssertNil(undefined.arrayContext)
    }

    func test_numberContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init(multipleOf: 22.3))
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        XCTAssertNil(boolean.numberContext)
        XCTAssertNil(object.numberContext)
        XCTAssertNil(array.numberContext)
        XCTAssertEqual(number.numberContext, .init(multipleOf: 22.3))
        XCTAssertNil(integer.numberContext)
        XCTAssertNil(string.numberContext)

        XCTAssertNil(allOf.numberContext)
        XCTAssertNil(anyOf.numberContext)
        XCTAssertNil(oneOf.numberContext)
        XCTAssertNil(not.numberContext)
        XCTAssertNil(reference.numberContext)
        XCTAssertNil(undefined.numberContext)
    }

    func test_integerContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init(multipleOf: 3))
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        XCTAssertNil(boolean.integerContext)
        XCTAssertNil(object.integerContext)
        XCTAssertNil(array.integerContext)
        XCTAssertNil(number.integerContext)
        XCTAssertEqual(integer.integerContext, .init(multipleOf: 3))
        XCTAssertNil(string.integerContext)

        XCTAssertNil(allOf.integerContext)
        XCTAssertNil(anyOf.integerContext)
        XCTAssertNil(oneOf.integerContext)
        XCTAssertNil(not.integerContext)
        XCTAssertNil(reference.integerContext)
        XCTAssertNil(undefined.integerContext)
    }

    func test_stringContextAccessor() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean))
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init(maxLength: 5))

        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
        let anyOf = JSONSchema.any(of: [boolean])
        let oneOf = JSONSchema.one(of: [boolean])
        let not = JSONSchema.not(boolean)
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
        let undefined = JSONSchema.fragment(.init(description: "hello world"))

        XCTAssertNil(boolean.stringContext)
        XCTAssertNil(object.stringContext)
        XCTAssertNil(array.stringContext)
        XCTAssertNil(number.stringContext)
        XCTAssertNil(integer.stringContext)
        XCTAssertEqual(string.stringContext, .init(maxLength: 5))

        XCTAssertNil(allOf.stringContext)
        XCTAssertNil(anyOf.stringContext)
        XCTAssertNil(oneOf.stringContext)
        XCTAssertNil(not.stringContext)
        XCTAssertNil(reference.stringContext)
        XCTAssertNil(undefined.stringContext)
    }

    func test_numericContextFromIntegerContext() {
        let i1 = JSONSchema.IntegerContext(multipleOf: 2)
        let i2 = JSONSchema.IntegerContext(maximum: (10, exclusive: false))
        let i3 = JSONSchema.IntegerContext(maximum: (10, exclusive: true))
        let i4 = JSONSchema.IntegerContext(minimum: (3, exclusive: false))
        let i5 = JSONSchema.IntegerContext(minimum: (3, exclusive: true))

        XCTAssertEqual(
            i1.numericContext,
            JSONSchema.NumericContext(multipleOf: 2)
        )
        XCTAssertEqual(
            i2.numericContext,
            JSONSchema.NumericContext(maximum: (10, exclusive: false))
        )
        XCTAssertEqual(
            i3.numericContext,
            JSONSchema.NumericContext(maximum: (10, exclusive: true))
        )
        XCTAssertEqual(
            i4.numericContext,
            JSONSchema.NumericContext(minimum: (3, exclusive: false))
        )
        XCTAssertEqual(
            i5.numericContext,
            JSONSchema.NumericContext(minimum: (3, exclusive: true))
        )
    }

    func test_requiredToOptional() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
            .optionalSchemaObject()
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .optionalSchemaObject()
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
            .optionalSchemaObject()
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
            .optionalSchemaObject()
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
            .optionalSchemaObject()
        let anyOf = JSONSchema.any(of: [boolean])
            .optionalSchemaObject()
        let oneOf = JSONSchema.one(of: [boolean])
            .optionalSchemaObject()
        let not = JSONSchema.not(boolean)
            .optionalSchemaObject()
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
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
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: false))
            .requiredSchemaObject()
        let object = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [:]))
            .requiredSchemaObject()
        let array = JSONSchema.array(.init(format: .unspecified, required: false), .init(items: .boolean(.init(format: .unspecified, required: false))))
            .requiredSchemaObject()
        let number = JSONSchema.number(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()
        let integer = JSONSchema.integer(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()
        let string = JSONSchema.string(.init(format: .unspecified, required: false), .init())
            .requiredSchemaObject()
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
            .requiredSchemaObject()
        let anyOf = JSONSchema.any(of: [boolean])
            .requiredSchemaObject()
        let oneOf = JSONSchema.one(of: [boolean])
            .requiredSchemaObject()
        let not = JSONSchema.not(boolean)
            .requiredSchemaObject()
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
            .requiredSchemaObject()

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

    func test_notNullableToNullable() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
            .nullableSchemaObject()
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .nullableSchemaObject()
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
            .nullableSchemaObject()
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
            .nullableSchemaObject()
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
            .nullableSchemaObject()
        let anyOf = JSONSchema.any(of: [boolean])
            .nullableSchemaObject()
        let oneOf = JSONSchema.one(of: [boolean])
            .nullableSchemaObject()
        let not = JSONSchema.not(boolean)
            .nullableSchemaObject()
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
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
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true, allowedValues: [false]))
        let object = JSONSchema.object(.init(format: .unspecified, required: true, allowedValues: [[:]]), .init(properties: [:]))
        let array = JSONSchema.array(.init(format: .unspecified, required: true, allowedValues: [[false]]), .init(items: .boolean(.init(format: .unspecified, required: true))))
        let number = JSONSchema.number(.init(format: .unspecified, required: true, allowedValues: [2.5]), .init())
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true, allowedValues: [5]), .init())
        let string = JSONSchema.string(.init(format: .unspecified, required: true, allowedValues: ["hello"]), .init())

        XCTAssertEqual(boolean.allowedValues, [false])
        XCTAssertEqual(object.allowedValues, [[:]])
        XCTAssertEqual(array.allowedValues?[0].value as! [Bool], [false])
        XCTAssertEqual(number.allowedValues, [2.5])
        XCTAssertEqual(integer.allowedValues, [5])
        XCTAssertEqual(string.allowedValues, ["hello"])
    }

    func test_withAddedAllowedValues() {
        let boolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
            .with(allowedValues: [false])
        let object = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .with(allowedValues: [[:]])
        let array = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: true))))
            .with(allowedValues: [[false]])
        let number = JSONSchema.number(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [2.5])
        let integer = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [5])
        let string = JSONSchema.string(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: ["hello"])

        // nonesense:
        let allOf = JSONSchema.all(of: [.string(.init(), .init())])
            .with(allowedValues: ["hello"])
        let anyOf = JSONSchema.any(of: [boolean])
            .with(allowedValues: ["hello"])
        let oneOf = JSONSchema.one(of: [boolean])
            .with(allowedValues: ["hello"])
        let not = JSONSchema.not(boolean)
            .with(allowedValues: ["hello"])
        let reference = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
            .with(allowedValues: ["hello"])

        XCTAssertEqual(boolean.allowedValues, [false])
        XCTAssertEqual(object.allowedValues, [AnyCodable([:])])
        XCTAssertEqual(array.allowedValues?[0].value as! [Bool], [false])
        XCTAssertEqual(number.allowedValues, [2.5])
        XCTAssertEqual(integer.allowedValues, [5])
        XCTAssertEqual(string.allowedValues, ["hello"])

        XCTAssertNil(allOf.allowedValues)
        XCTAssertNil(anyOf.allowedValues)
        XCTAssertNil(oneOf.allowedValues)
        XCTAssertNil(not.allowedValues)
        XCTAssertNil(reference.allowedValues)
    }

    func test_withInitialExample() {
        let object = JSONSchema.object(.init(format: .unspecified, required: true, example: [:]), .init(properties: [:]))

        // nonsense
        let all = JSONSchema.all(of: [])
        let one = JSONSchema.one(of: [])
        let any = JSONSchema.any(of: [])
        let not = JSONSchema.not(.string)
        let ref = JSONSchema.reference(.external(URL(string: "hello.yml")!))

        XCTAssertEqual(object.example?.value as? [String:String], [:])

        XCTAssertNil(all.example)
        XCTAssertNil(one.example)
        XCTAssertNil(any.example)
        XCTAssertNil(not.example)
        XCTAssertNil(ref.example)
    }

    func test_withAddedExample() {
        let object = try! JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:]))
            .with(example: AnyCodable([String: String]()))
        let array = try! JSONSchema.array(.init(), .init())
            .with(example: ["hello"])

        let boolean = try! JSONSchema.boolean(.init(format: .unspecified, required: true))
            .with(example: true)
        let double = try! JSONSchema.number
            .with(example: 10.5)
        let float = try! JSONSchema.number
            .with(example: AnyCodable(Float(2.5)))
        let integer = try! JSONSchema.integer
            .with(example: 3)
        let string = try! JSONSchema.string
            .with(example: "hello world")

        // nonsense:
        XCTAssertThrowsError(try JSONSchema.all(of: [.string(.init(), .init())])
            .with(example: ["hello"])) { error in
                XCTAssertEqual(String(describing: error), "examples not supported for `.allOf`, `.oneOf`, `.anyOf`, `.not` or for JSON references ($ref).")
        }
        XCTAssertThrowsError(try JSONSchema.any(of: [object])
            .with(example: ["hello"]))
        XCTAssertThrowsError(try JSONSchema.one(of: [object])
            .with(example: ["hello"]))
        XCTAssertThrowsError(try JSONSchema.not(object)
            .with(example: ["hello"]))
        XCTAssertThrowsError(try JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))
            .with(example: ["hello"]))

        XCTAssertEqual(object.example?.value as? [String: String], [:])
        XCTAssertEqual(array.example?.value as? [String], ["hello"])

        XCTAssertEqual(boolean.example?.value as? Bool, true)
        XCTAssertEqual(double.example?.value as? Double, 10.5)
        XCTAssertEqual(float.example?.value as? Float, 2.5 as Float)
        XCTAssertEqual(integer.example?.value as? Int, 3)
        XCTAssertEqual(string.example?.value as? String, "hello world")
    }

    func test_minObjectProperties() {
        let obj1 = JSONSchema.ObjectContext(
            properties: [:],
            additionalProperties: .init(true),
            minProperties: 2
        )

        XCTAssertEqual(obj1.minProperties, 2)

        let obj2 = JSONSchema.ObjectContext(
            properties: [:],
            additionalProperties: .init(true)
        )

        XCTAssertEqual(obj2.minProperties, 0)

        let obj3 = JSONSchema.ObjectContext(
            properties: [
                "hello": .string
            ],
            additionalProperties: .init(true)
        )

        XCTAssertEqual(obj3.minProperties, 1)

        let obj4 = JSONSchema.ObjectContext(
            properties: [
                "hello": .string(required: false)
            ],
            additionalProperties: .init(true)
        )

        XCTAssertEqual(obj4.minProperties, 0)

        let obj5 = JSONSchema.ObjectContext(
            properties: [
                "hello": .string
            ],
            additionalProperties: .init(true),
            minProperties: 3
        )

        XCTAssertEqual(obj5.minProperties, 3)

        let obj6 = JSONSchema.ObjectContext(
            properties: [
                "hello": .string,
                "world": .boolean
            ],
            additionalProperties: .init(true),
            minProperties: 1
        )

        XCTAssertEqual(obj6.minProperties, 2)
    }
}

// MARK: - Codable
extension SchemaObjectTests {

    func test_decodeingFailsForTypo() {
        let oneOfData = """
        {
            "oneOff": [
                { "type": "string" },
                { "type": "boolean" }
            ]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchema.self, from: oneOfData))
    }

    func test_decodingFailsForReadOnlyAndWriteOnly() {
        let readOnlyWriteOnlyData = """
        {
            "type": "string",
            "readOnly": true,
            "writeOnly": true
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchema.self, from: readOnlyWriteOnlyData))
    }

    func test_decodingFailsForTypeAndPropertyConflict() {
        // has type "string" but "items" property that belongs with the "array" type.
        let badSchema = """
        {
            "type": "object",
            "items": {
                "type" : "string"
            }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try orderUnstableDecode(JSONSchema.self, from: badSchema))
    }

    func test_decodeExampleFragment() throws {
        let exampleSchema = """
        {
            "example" : "hello"
        }
        """.data(using: .utf8)!

        XCTAssertEqual(
            try orderUnstableDecode(JSONSchema.self, from: exampleSchema),
            .fragment(.init(example: "hello"))
        )
    }

    func test_encodeExampleFragment() throws {
        let fragment = JSONSchema.fragment(.init(example: "hello"))

        let encoded = try orderUnstableTestStringFromEncoding(of: fragment)

        assertJSONEquivalent(
            encoded,
"""
{
  "example" : "hello"
}
"""
        )
    }

    func test_decodeUndefined() throws {
        let undefinedData = """
        {}
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: undefinedData)

        XCTAssertEqual(decoded, .fragment(.init(description: nil)))
    }

    func test_encodeUndefined() throws {
        let undefined = JSONSchema.fragment(.init(description: nil))

        let encoded = try orderUnstableTestStringFromEncoding(of: undefined)

        assertJSONEquivalent(
            encoded,
"""
{

}
"""
        )
    }

    func test_decodeUndefinedWithDescription() throws {
        let undefinedWithDescriptionData = """
        {
          "description": "hello world"
        }
        """.data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: undefinedWithDescriptionData)

        XCTAssertEqual(decoded, .fragment(.init(description: "hello world")))
    }

    func test_encodeUndefinedWithDescription() throws {
        let undefinedWithDescription = JSONSchema.fragment(.init(description: "hello world"))

        let encoded = try orderUnstableTestStringFromEncoding(of: undefinedWithDescription)

        assertJSONEquivalent(
            encoded,
"""
{
  "description" : "hello world"
}
"""
        )
    }

    func test_encodeBoolean() {
        let requiredBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
        let optionalBoolean = JSONSchema.boolean(.init(format: .unspecified, required: false))
        let nullableBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true, nullable: true))
        let readOnlyBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true, permissions: .readOnly))
        let writeOnlyBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true, permissions: .writeOnly))
        let deprecatedBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true, deprecated: true))
        let allowedValueBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true))
            .with(allowedValues: [true])
        let discriminatorBoolean = JSONSchema.boolean(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")))

        testAllSharedSimpleContextEncoding(
            typeName: "boolean",
            requiredEntity: requiredBoolean,
            optionalEntity: optionalBoolean,
            nullableEntity: nullableBoolean,
            readOnlyEntity: readOnlyBoolean,
            writeOnlyEntity: writeOnlyBoolean,
            deprecatedEntity: deprecatedBoolean,
            allowedValues: (
                entity: allowedValueBoolean,
                value: "true"
            ),
            discriminator: (
                entity: discriminatorBoolean,
                name: "hello"
            )
        )
    }

    func test_decodeBoolean() throws {
        let booleanData = #"{"type": "boolean"}"#.data(using: .utf8)!
        let nullableBooleanData = #"{"type": "boolean", "nullable": true}"#.data(using: .utf8)!
        let readOnlyBooleanData = #"{"type": "boolean", "readOnly": true}"#.data(using: .utf8)!
        let writeOnlyBooleanData = #"{"type": "boolean", "writeOnly": true}"#.data(using: .utf8)!
        let deprecatedBooleanData = #"{"type": "boolean", "deprecated": true}"#.data(using: .utf8)!
        let allowedValueBooleanData = #"{"type": "boolean", "enum": [false]}"#.data(using: .utf8)!
        let discriminatorBooleanData = #"{"type": "boolean", "discriminator": { "propertyName": "hello" }}"#.data(using: .utf8)!

        let boolean = try orderUnstableDecode(JSONSchema.self, from: booleanData)
        let nullableBoolean = try orderUnstableDecode(JSONSchema.self, from: nullableBooleanData)
        let readOnlyBoolean = try orderUnstableDecode(JSONSchema.self, from: readOnlyBooleanData)
        let writeOnlyBoolean = try orderUnstableDecode(JSONSchema.self, from: writeOnlyBooleanData)
        let deprecatedBoolean = try orderUnstableDecode(JSONSchema.self, from: deprecatedBooleanData)
        let allowedValueBoolean = try orderUnstableDecode(JSONSchema.self, from: allowedValueBooleanData)
        let discriminatorBoolean = try orderUnstableDecode(JSONSchema.self, from: discriminatorBooleanData)

        XCTAssertEqual(boolean, JSONSchema.boolean(.init(format: .generic)))
        XCTAssertEqual(nullableBoolean, JSONSchema.boolean(.init(format: .generic, nullable: true)))
        XCTAssertEqual(readOnlyBoolean, JSONSchema.boolean(.init(format: .generic, permissions: .readOnly)))
        XCTAssertEqual(writeOnlyBoolean, JSONSchema.boolean(.init(format: .generic, permissions: .writeOnly)))
        XCTAssertEqual(deprecatedBoolean, JSONSchema.boolean(.init(format: .generic, deprecated: true)))
        XCTAssertEqual(allowedValueBoolean, JSONSchema.boolean(.init(format: .generic, allowedValues: [false])))
        XCTAssertEqual(discriminatorBoolean, JSONSchema.boolean(.init(format: .generic, discriminator: .init(propertyName: "hello"))))
    }

    func test_encodeObject() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let readOnlyObject = JSONSchema.object(.init(format: .unspecified, required: true, permissions: .readOnly), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let writeOnlyObject = JSONSchema.object(.init(format: .unspecified, required: true, permissions: .writeOnly), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let deprecatedObject = JSONSchema.object(.init(format: .unspecified, required: true, deprecated: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])
        let discriminatorObject = JSONSchema.object(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")), .init(properties: [:]))

        testEncodingPropertyLines(
            entity: requiredObject,
            propertyLines: [
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: optionalObject,
            propertyLines: [
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: nullableObject,
            propertyLines: [
                "\"nullable\" : true,",
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: readOnlyObject,
            propertyLines: [
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"readOnly\" : true,",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: writeOnlyObject,
            propertyLines: [
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\",",
                "\"writeOnly\" : true"
            ]
        )

        testEncodingPropertyLines(
            entity: deprecatedObject,
            propertyLines: [
                "\"deprecated\" : true,",
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: allowedValueObject,
            propertyLines: [
                "\"enum\" : [",
                "  {",
                "    \"hello\" : false",
                "  }",
                "],",
                "\"properties\" : {",
                "  \"hello\" : {",
                "    \"type\" : \"boolean\"",
                "  }",
                "},",
                "\"type\" : \"object\""
            ]
        )

        testEncodingPropertyLines(
            entity: discriminatorObject,
            propertyLines: [
                "\"discriminator\" : {",
                "  \"propertyName\" : \"hello\"",
                "},",
                "\"type\" : \"object\""
            ]
        )
    }

    func test_decodeObject() throws {
        let objectData = """
        {
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let readOnlyObjectData = """
        {
            "type": "object",
            "readOnly": true
        }
        """.data(using: .utf8)!
        let writeOnlyObjectData = """
        {
            "type": "object",
            "writeOnly": true
        }
        """.data(using: .utf8)!
        let deprecatedObjectData = """
        {
            "type": "object",
            "deprecated": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!
        let discriminatorObjectData = """
        {
            "type": "object",
            "discriminator": {"propertyName": "hello"}
        }
        """.data(using: .utf8)!

        let object = try orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let readOnlyObject = try orderUnstableDecode(JSONSchema.self, from: readOnlyObjectData)
        let writeOnlyObject = try orderUnstableDecode(JSONSchema.self, from: writeOnlyObjectData)
        let deprecatedObject = try orderUnstableDecode(JSONSchema.self, from: deprecatedObjectData)
        let allowedValueObject = try orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)
        let discriminatorObject = try orderUnstableDecode(JSONSchema.self, from: discriminatorObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: [:])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: [:])))
        XCTAssertEqual(readOnlyObject, JSONSchema.object(.init(format: .generic, permissions: .readOnly), .init(properties: [:])))
        XCTAssertEqual(writeOnlyObject, JSONSchema.object(.init(format: .generic, permissions: .writeOnly), .init(properties: [:])))
        XCTAssertEqual(deprecatedObject, JSONSchema.object(.init(format: .generic, deprecated: true), .init(properties: [:])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))
        XCTAssertEqual(discriminatorObject, JSONSchema.object(discriminator: .init(propertyName: "hello")))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
    }

    func test_decodeObjectWithTypeInferred() throws {
        let objectData =
"""
{
    "properties": {
        "hello": {
            "type": "boolean"
        }
    }
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: objectData)

        XCTAssertEqual(
            decoded,
            JSONSchema.object(properties: ["hello": .boolean(required: false)])
        )
    }

    func test_encodeObjectWithTitle() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true, title: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false, title: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true, title: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true, title: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"title\" : \"hello\",",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"title\" : \"hello\",",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"title\" : \"hello\",",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"title\" : \"hello\",",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithTitle() {
        let objectData = """
        {
            "title": "hello",
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "title": "hello",
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "title": "hello",
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic, title: "hello"), .init(properties: [:])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true, title: "hello"), .init(properties: [:])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))
        XCTAssertEqual(allowedValueObject.title, "hello")

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
    }

    func test_encodeObjectWithDescription() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true, description: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false, description: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true, description: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true, description: "hello"), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"description\" : \"hello\",",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"description\" : \"hello\",",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"description\" : \"hello\",",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"description\" : \"hello\",",
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithDescription() {
        let objectData = """
        {
            "description": "hello",
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "description": "hello",
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "description": "hello",
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic, description: "hello"), .init(properties: [:])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true, description: "hello"), .init(properties: [:])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))
        XCTAssertEqual(allowedValueObject.description, "hello")

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
    }

    func test_encodeObjectWithExternalDocs() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"externalDocs\" : {",
                                    "  \"url\" : \"http:\\/\\/google.com\"",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"externalDocs\" : {",
                                    "  \"url\" : \"http:\\/\\/google.com\"",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"externalDocs\" : {",
                                    "  \"url\" : \"http:\\/\\/google.com\"",
                                    "},",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"externalDocs\" : {",
                                    "  \"url\" : \"http:\\/\\/google.com\"",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithExternalDocs() {
        let objectData = """
        {
            "externalDocs": { "url": "http://google.com" },
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "externalDocs": { "url": "http://google.com" },
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "externalDocs": { "url": "http://google.com" },
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [:])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true, externalDocs: .init(url: URL(string: "http://google.com")!)), .init(properties: [:])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))
        XCTAssertEqual(allowedValueObject.externalDocs, .init(url: URL(string: "http://google.com")!))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
    }

    func test_encodeObjectWithMaxProperties() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], maxProperties: 2))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], maxProperties: 2))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], maxProperties: 2))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], maxProperties: 2))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"maxProperties\" : 2,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"maxProperties\" : 2,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"maxProperties\" : 2,",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"maxProperties\" : 2,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithMaxProperties() {
        let objectData = """
        {
            "maxProperties": 1,
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "maxProperties": 1,
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "maxProperties": 1,
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: [:], maxProperties: 1)))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: [:], maxProperties: 1)))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))], maxProperties: 1))
    }

    func test_encodeObjectWithMinProperties() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], minProperties: 1))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], minProperties: 1))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], minProperties: 1))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], minProperties: 1))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithMinProperties() {
        let objectData = """
        {
            "minProperties": 1,
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "minProperties": 1,
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "minProperties": 1,
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: [:], minProperties: 1)))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: [:], minProperties: 1)))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))], minProperties: 1))
    }

    func test_encodeObjectWithAdditionalPropertiesBoolean() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(true)))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(true)))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(true)))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(true)))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : true,",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : true,",
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithAdditionalPropertiesBoolean() {
        let objectData = """
        {
            "additionalProperties": true,
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "additionalProperties": true,
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "additionalProperties": true,
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: [:], additionalProperties: .init(true))))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: [:], additionalProperties: .init(true))))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))], additionalProperties: .init(true)))
        XCTAssertEqual(contextB.additionalProperties?.booleanValue, true)
    }

    func test_encodeObjectWithAdditionalPropertiesObject() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithAdditionalPropertiesObject() {
        let objectData = """
        {
            "additionalProperties": { "type": "string" },
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "additionalProperties": { "type": "string" },
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "additionalProperties": { "type": "string" },
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: [:], additionalProperties: .init(.string))))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: [:], additionalProperties: .init(.string))))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))], additionalProperties: .init(.string)))
    }

    func test_encodeObjectWithExample() {
        let string = try! JSONSchema.string(.init(format: .unspecified, required: true), .init())
            .with(example: "hello")
        let requiredObject = try! JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(example: AnyCodable(["hello": true]))
        let optionalObject = try! JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(example: AnyCodable(["hello": true]))
        let nullableObject = try! JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(example: AnyCodable(["hello": true]))
        let allowedValueObject = try! JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: false))
        ]))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])
            .with(example: AnyCodable(["hello": true]))

        if case let .object(_, objectContext) = requiredObject {
            XCTAssertEqual(objectContext.requiredProperties, [])
            XCTAssertEqual(objectContext.optionalProperties, ["hello"])
        }

        testEncodingPropertyLines(entity: string,
                                  propertyLines: [
                                    "\"example\" : \"hello\",",
                                    "\"type\" : \"string\""
        ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"example\" : {",
                                    "  \"hello\" : true",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"example\" : {",
                                    "  \"hello\" : true",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"example\" : {",
                                    "  \"hello\" : true",
                                    "},",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"example\" : {",
                                    "  \"hello\" : true",
                                    "},",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithExample() throws {
        let stringData = """
        {
            "example": "hello",
            "type": "string"
        }
        """.data(using: .utf8)!
        let objectData = """
        {
            "example": {
                "hello" : true
            },
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "example": {
                "hello" : true
            },
            "type": "object",
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "example": {
                "hello" : true
            },
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let string = try orderUnstableDecode(JSONSchema.self, from: stringData)
        let object = try orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .unspecified, example: "hello"), .init()))
        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic, example: AnyCodable(["hello": true])), .init(properties: [:])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true, example: AnyCodable(["hello": true])), .init(properties: [:])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))
        XCTAssertEqual(allowedValueObject.example, ["hello" : true])

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
    }

    func test_encodeObjectWithNoPropertiesAndAdditionalPropertiesObject() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [:], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [:], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [:], additionalProperties: .init(.boolean(.init(format: .unspecified, required: false)))))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"additionalProperties\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"type\" : \"object\""
        ])
    }

    func test_encodeObjectWithRequiredProperties() {
        let requiredObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: true))
        ], minProperties: 1))
        let optionalObject = JSONSchema.object(.init(format: .unspecified, required: false), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: true))
        ], minProperties: 1))
        let nullableObject = JSONSchema.object(.init(format: .unspecified, required: true, nullable: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: true))
        ], minProperties: 1))
        let allowedValueObject = JSONSchema.object(.init(format: .unspecified, required: true), .init(properties: [
            "hello": .boolean(.init(format: .unspecified, required: true))
        ], minProperties: 1))
            .with(allowedValues: [
                AnyCodable(["hello": false])
            ])

        if case let .object(_, objectContext) = requiredObject {
            XCTAssertEqual(objectContext.requiredProperties, ["hello"])
            XCTAssertEqual(objectContext.optionalProperties, [])
        }

        testEncodingPropertyLines(entity: requiredObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"required\" : [",
                                    "  \"hello\"",
                                    "],",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: optionalObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"required\" : [",
                                    "  \"hello\"",
                                    "],",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: nullableObject,
                                  propertyLines: [
                                    "\"minProperties\" : 1,",
                                    "\"nullable\" : true,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"required\" : [",
                                    "  \"hello\"",
                                    "],",
                                    "\"type\" : \"object\""
        ])

        testEncodingPropertyLines(entity: allowedValueObject,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  {",
                                    "    \"hello\" : false",
                                    "  }",
                                    "],",
                                    "\"minProperties\" : 1,",
                                    "\"properties\" : {",
                                    "  \"hello\" : {",
                                    "    \"type\" : \"boolean\"",
                                    "  }",
                                    "},",
                                    "\"required\" : [",
                                    "  \"hello\"",
                                    "],",
                                    "\"type\" : \"object\""
        ])
    }

    func test_decodeObjectWithRequiredProperties() {
        let objectData = """
        {
            "required": ["hello"],
            "properties": {"hello": { "type": "boolean"}},
            "type": "object"
        }
        """.data(using: .utf8)!
        let nullableObjectData = """
        {
            "required": ["hello"],
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "nullable": true
        }
        """.data(using: .utf8)!
        let allowedValueObjectData = """
        {
            "required": ["hello"],
            "type": "object",
            "properties": {"hello": { "type": "boolean"}},
            "enum": [{"hello": false}]
        }
        """.data(using: .utf8)!

        let object = try! orderUnstableDecode(JSONSchema.self, from: objectData)
        let nullableObject = try! orderUnstableDecode(JSONSchema.self, from: nullableObjectData)
        let allowedValueObject = try! orderUnstableDecode(JSONSchema.self, from: allowedValueObjectData)

        XCTAssertEqual(object, JSONSchema.object(.init(format: .generic), .init(properties: ["hello": .boolean(.init(format: .generic))])))
        XCTAssertEqual(nullableObject, JSONSchema.object(.init(format: .generic, nullable: true), .init(properties: ["hello": .boolean(.init(format: .generic))])))
        XCTAssertEqual(allowedValueObject.allowedValues?[0].value as! [String: Bool], ["hello": false])
        XCTAssertEqual(allowedValueObject.jsonTypeFormat, .object(.generic))

        guard case let .object(_, contextB) = allowedValueObject else {
            XCTFail("expected object to be parsed as object")
            return
        }
        XCTAssertEqual(contextB, .init(properties: ["hello": .boolean(.init(format: .generic))]))
    }

    func test_encodeArray() {
        let requiredArray = JSONSchema.array(.init(format: .unspecified, required: true), .init())
        let optionalArray = JSONSchema.array(.init(format: .unspecified, required: false), .init())
        let nullableArray = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init())
        let readOnlyArray = JSONSchema.array(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let writeOnlyArray = JSONSchema.array(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let deprecatedArray = JSONSchema.array(.init(format: .unspecified, required: true, deprecated: true), .init())
        let allowedValueArray = JSONSchema.array(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [[10]])
        let discriminatorArray = JSONSchema.array(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")), .init())

        testAllSharedSimpleContextEncoding(
            typeName: "array",
            requiredEntity: requiredArray,
            optionalEntity: optionalArray,
            nullableEntity: nullableArray,
            readOnlyEntity: readOnlyArray,
            writeOnlyEntity: writeOnlyArray,
            deprecatedEntity: deprecatedArray,
            allowedValues: (
                entity: allowedValueArray,
                value: "[\n      10\n    ]"
            ),
            discriminator: (
                entity: discriminatorArray,
                name: "hello"
            )
        )
    }

    func test_decodeArray() throws {
        let arrayData = #"{"type": "array"}"#.data(using: .utf8)!
        let nullableArrayData = #"{"type": "array", "nullable": true}"#.data(using: .utf8)!
        let readOnlyArrayData = #"{"type": "array", "readOnly": true}"#.data(using: .utf8)!
        let writeOnlyArrayData = #"{"type": "array", "writeOnly": true}"#.data(using: .utf8)!
        let deprecatedArrayData = #"{"type": "array", "deprecated": true}"#.data(using: .utf8)!
        let allowedValueArrayData = #"{"type": "array", "items": { "type": "boolean" }, "enum": [[false]]}"#.data(using: .utf8)!
        let discriminatorArrayData = #"{"type": "array", "discriminator": {"propertyName": "hello"}}"#.data(using: .utf8)!

        let array = try orderUnstableDecode(JSONSchema.self, from: arrayData)
        let nullableArray = try orderUnstableDecode(JSONSchema.self, from: nullableArrayData)
        let readOnlyArray = try orderUnstableDecode(JSONSchema.self, from: readOnlyArrayData)
        let writeOnlyArray = try orderUnstableDecode(JSONSchema.self, from: writeOnlyArrayData)
        let deprecatedArray = try orderUnstableDecode(JSONSchema.self, from: deprecatedArrayData)
        let allowedValueArray = try orderUnstableDecode(JSONSchema.self, from: allowedValueArrayData)
        let discriminatorArray = try orderUnstableDecode(JSONSchema.self, from: discriminatorArrayData)

        XCTAssertEqual(array, JSONSchema.array(.init(format: .generic), .init()))
        XCTAssertEqual(nullableArray, JSONSchema.array(.init(format: .generic, nullable: true), .init()))
        XCTAssertEqual(readOnlyArray, JSONSchema.array(.init(format: .generic, permissions: .readOnly), .init()))
        XCTAssertEqual(writeOnlyArray, JSONSchema.array(.init(format: .generic, permissions: .writeOnly), .init()))
        XCTAssertEqual(deprecatedArray, JSONSchema.array(.init(format: .generic, deprecated: true), .init()))
        XCTAssertEqual(allowedValueArray.allowedValues?[0].value as! [Bool], [false])
        XCTAssertEqual(discriminatorArray, JSONSchema.array(discriminator: .init(propertyName: "hello")))

        guard case let .array(_, contextB) = allowedValueArray else {
            XCTFail("expected array")
            return
        }
        XCTAssertEqual(contextB, .init(items: .boolean(.init(format: .generic))))
    }

    func test_decodeArrayWithTypeInferred() throws {
        let objectData =
"""
{
    "items": {
        "type": "boolean"
    }
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: objectData)

        XCTAssertEqual(
            decoded,
            JSONSchema.array(items: .boolean)
        )
    }

    func test_encodeArrayWithItemsDefinition() {
        let requiredArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: false))))
        let optionalArray = JSONSchema.array(.init(format: .unspecified, required: false), .init(items: .boolean(.init(format: .unspecified, required: false))))
        let nullableArray = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init(items: .boolean(.init(format: .unspecified, required: false))))
        let allowedValueArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(items: .boolean(.init(format: .unspecified, required: false))))
            .with(allowedValues: [[10]])

        testEncodingPropertyLines(entity: requiredArray,
                                  propertyLines: [
                                    "\"items\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: optionalArray,
                                  propertyLines: [
                                    "\"items\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: nullableArray,
                                  propertyLines: [
                                    "\"items\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: allowedValueArray,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  [",
                                    "    10",
                                    "  ]",
                                    "],",
                                    "\"items\" : {",
                                    "  \"type\" : \"boolean\"",
                                    "},",
                                    "\"type\" : \"array\""
        ])
    }

    func test_decodeArrayWithItemsDefinition() {
        let arrayData = #"{"type": "array", "items": { "type": "boolean" }}"#.data(using: .utf8)!
        let nullableArrayData = #"{"type": "array", "items": { "type": "boolean" }, "nullable": true}"#.data(using: .utf8)!
        let allowedValueArrayData = #"{"type": "array", "items": { "type": "boolean" }, "enum": [[false]]}"#.data(using: .utf8)!

        let array = try! orderUnstableDecode(JSONSchema.self, from: arrayData)
        let nullableArray = try! orderUnstableDecode(JSONSchema.self, from: nullableArrayData)
        let allowedValueArray = try! orderUnstableDecode(JSONSchema.self, from: allowedValueArrayData)

        XCTAssertEqual(array, JSONSchema.array(.init(format: .generic), .init(items: .boolean(.init(format: .generic)))))
        XCTAssertEqual(nullableArray, JSONSchema.array(.init(format: .generic, nullable: true), .init(items: .boolean(.init(format: .generic)))))
        XCTAssertEqual(allowedValueArray.allowedValues?[0].value as! [Bool], [false])

        guard case let .array(_, contextB) = allowedValueArray else {
            XCTFail("expected array")
            return
        }
        XCTAssertEqual(contextB, .init(items: .boolean(.init(format: .generic))))
    }

    func test_encodeArrayWithAdditionalItemsDefinition() {
        // NOTE: NOT SUPPORTED BY OPENAPI SPEC

        // UNIMPLEMENTED
    }

    func test_decodeArrayWithAdditionalItemsDefinition() {
        // NOTE: NOT SUPPORTED BY OPENAPI SPEC

        // UNIMPLEMENTED
    }

    func test_encodeArrayWithUniqueItems() {
        let requiredArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(uniqueItems: true))
        let optionalArray = JSONSchema.array(.init(format: .unspecified, required: false), .init(uniqueItems: true))
        let nullableArray = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init(uniqueItems: true))
        let allowedValueArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(uniqueItems: true))
            .with(allowedValues: [[10]])

        testEncodingPropertyLines(entity: requiredArray,
                                  propertyLines: [
                                    "\"type\" : \"array\",",
                                    "\"uniqueItems\" : true"
        ])

        testEncodingPropertyLines(entity: optionalArray,
                                  propertyLines: [
                                    "\"type\" : \"array\",",
                                    "\"uniqueItems\" : true"
        ])

        testEncodingPropertyLines(entity: nullableArray,
                                  propertyLines: [
                                    "\"nullable\" : true,",
                                    "\"type\" : \"array\",",
                                    "\"uniqueItems\" : true"
        ])

        testEncodingPropertyLines(entity: allowedValueArray,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  [",
                                    "    10",
                                    "  ]",
                                    "],",
                                    "\"type\" : \"array\",",
                                    "\"uniqueItems\" : true"
        ])
    }

    func test_decodeArrayWithUniqueItems() {
        let arrayData = #"{"type": "array", "uniqueItems": true}"#.data(using: .utf8)!
        let nullableArrayData = #"{"type": "array", "uniqueItems": true, "nullable": true}"#.data(using: .utf8)!
        let allowedValueArrayData = #"{"type": "array", "uniqueItems": true, "items": { "type": "boolean" }, "enum": [[false]]}"#.data(using: .utf8)!

        let array = try! orderUnstableDecode(JSONSchema.self, from: arrayData)
        let nullableArray = try! orderUnstableDecode(JSONSchema.self, from: nullableArrayData)
        let allowedValueArray = try! orderUnstableDecode(JSONSchema.self, from: allowedValueArrayData)

        XCTAssertEqual(array, JSONSchema.array(.init(format: .generic), .init(uniqueItems: true)))
        XCTAssertEqual(nullableArray, JSONSchema.array(.init(format: .generic, nullable: true), .init(uniqueItems: true)))
        XCTAssertEqual(allowedValueArray.allowedValues?[0].value as! [Bool], [false])

        guard case let .array(_, contextB) = allowedValueArray else {
            XCTFail("expected array")
            return
        }
        XCTAssertEqual(contextB, .init(items: .boolean(.init(format: .generic)), uniqueItems: true))
    }

    func test_encodeArrayWithMaxItems() {
        let requiredArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(maxItems: 2))
        let optionalArray = JSONSchema.array(.init(format: .unspecified, required: false), .init(maxItems: 2))
        let nullableArray = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init(maxItems: 2))
        let allowedValueArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(maxItems: 2))
            .with(allowedValues: [[10]])

        testEncodingPropertyLines(entity: requiredArray,
                                  propertyLines: [
                                    "\"maxItems\" : 2,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: optionalArray,
                                  propertyLines: [
                                    "\"maxItems\" : 2,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: nullableArray,
                                  propertyLines: [
                                    "\"maxItems\" : 2,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: allowedValueArray,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  [",
                                    "    10",
                                    "  ]",
                                    "],",
                                    "\"maxItems\" : 2,",
                                    "\"type\" : \"array\""
        ])
    }

    func test_decodeArrayWithMaxItems() {
        let arrayData = #"{"type": "array", "maxItems": 3}"#.data(using: .utf8)!
        let nullableArrayData = #"{"type": "array", "maxItems": 3, "nullable": true}"#.data(using: .utf8)!
        let allowedValueArrayData = #"{"type": "array", "maxItems": 3, "items": { "type": "boolean" }, "enum": [[false]]}"#.data(using: .utf8)!

        let array = try! orderUnstableDecode(JSONSchema.self, from: arrayData)
        let nullableArray = try! orderUnstableDecode(JSONSchema.self, from: nullableArrayData)
        let allowedValueArray = try! orderUnstableDecode(JSONSchema.self, from: allowedValueArrayData)

        XCTAssertEqual(array, JSONSchema.array(.init(format: .generic), .init(maxItems: 3)))
        XCTAssertEqual(nullableArray, JSONSchema.array(.init(format: .generic, nullable: true), .init(maxItems: 3)))
        XCTAssertEqual(allowedValueArray.allowedValues?[0].value as! [Bool], [false])

        guard case let .array(_, contextB) = allowedValueArray else {
            XCTFail("expected array")
            return
        }
        XCTAssertEqual(contextB, .init(items: .boolean(.init(format: .generic)), maxItems: 3))
    }

    func test_encodeArrayWithMinItems() {
        let requiredArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(minItems: 2))
        let optionalArray = JSONSchema.array(.init(format: .unspecified, required: false), .init(minItems: 2))
        let nullableArray = JSONSchema.array(.init(format: .unspecified, required: true, nullable: true), .init(minItems: 2))
        let allowedValueArray = JSONSchema.array(.init(format: .unspecified, required: true), .init(minItems: 2))
            .with(allowedValues: [[10]])

        testEncodingPropertyLines(entity: requiredArray,
                                  propertyLines: [
                                    "\"minItems\" : 2,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: optionalArray,
                                  propertyLines: [
                                    "\"minItems\" : 2,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: nullableArray,
                                  propertyLines: [
                                    "\"minItems\" : 2,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"array\""
        ])

        testEncodingPropertyLines(entity: allowedValueArray,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  [",
                                    "    10",
                                    "  ]",
                                    "],",
                                    "\"minItems\" : 2,",
                                    "\"type\" : \"array\""
        ])
    }

    func test_decodeArrayWithMinItems() {
        let arrayData = #"{"type": "array", "minItems": 2}"#.data(using: .utf8)!
        let nullableArrayData = #"{"type": "array", "minItems": 2, "nullable": true}"#.data(using: .utf8)!
        let allowedValueArrayData = #"{"type": "array", "minItems": 2, "items": { "type": "boolean" }, "enum": [[false]]}"#.data(using: .utf8)!

        let array = try! orderUnstableDecode(JSONSchema.self, from: arrayData)
        let nullableArray = try! orderUnstableDecode(JSONSchema.self, from: nullableArrayData)
        let allowedValueArray = try! orderUnstableDecode(JSONSchema.self, from: allowedValueArrayData)

        XCTAssertEqual(array, JSONSchema.array(.init(format: .generic), .init(minItems: 2)))
        XCTAssertEqual(nullableArray, JSONSchema.array(.init(format: .generic, nullable: true), .init(minItems: 2)))
        XCTAssertEqual(allowedValueArray.allowedValues?[0].value as! [Bool], [false])

        guard case let .array(_, contextB) = allowedValueArray else {
            XCTFail("expected array")
            return
        }
        XCTAssertEqual(contextB, .init(items: .boolean(.init(format: .generic)), minItems: 2))
    }

    func test_encodeNumber() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init())
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init())
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init())
        let readOnlyNumber = JSONSchema.number(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let writeOnlyNumber = JSONSchema.number(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let deprecatedNumber = JSONSchema.number(.init(format: .unspecified, required: true, deprecated: true), .init())
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [10.5])
        let discriminatorNumber = JSONSchema.number(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")), .init())

        testAllSharedSimpleContextEncoding(
            typeName: "number",
            requiredEntity: requiredNumber,
            optionalEntity: optionalNumber,
            nullableEntity: nullableNumber,
            readOnlyEntity: readOnlyNumber,
            writeOnlyEntity: writeOnlyNumber,
            deprecatedEntity: deprecatedNumber,
            allowedValues: (
                entity: allowedValueNumber,
                value: "10.5"
            ),
            discriminator: (
                entity: discriminatorNumber,
                name: "hello"
            )
        )
    }

    func test_decodeNumber() throws {
        let numberData = #"{"type": "number"}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "nullable": true}"#.data(using: .utf8)!
        let readOnlyNumberData = #"{"type": "number", "readOnly": true}"#.data(using: .utf8)!
        let writeOnlyNumberData = #"{"type": "number", "writeOnly": true}"#.data(using: .utf8)!
        let deprecatedNumberData = #"{"type": "number", "deprecated": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "enum": [1, 2]}"#.data(using: .utf8)!
        let discriminatorNumberData = #"{"type": "number", "discriminator": {"propertyName": "hello"}}"#.data(using: .utf8)!

        let number = try orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let readOnlyNumber = try orderUnstableDecode(JSONSchema.self, from: readOnlyNumberData)
        let writeOnlyNumber = try orderUnstableDecode(JSONSchema.self, from: writeOnlyNumberData)
        let deprecatedNumber = try orderUnstableDecode(JSONSchema.self, from: deprecatedNumberData)
        let allowedValueNumber = try orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)
        let discriminatorNumber = try orderUnstableDecode(JSONSchema.self, from: discriminatorNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init()))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init()))
        XCTAssertEqual(readOnlyNumber, JSONSchema.number(.init(format: .generic, permissions: .readOnly), .init()))
        XCTAssertEqual(writeOnlyNumber, JSONSchema.number(.init(format: .generic, permissions: .writeOnly), .init()))
        XCTAssertEqual(deprecatedNumber, JSONSchema.number(.init(format: .generic, deprecated: true), .init()))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [1, 2]), .init()))
        XCTAssertEqual(discriminatorNumber, JSONSchema.number(discriminator: .init(propertyName: "hello")))
    }

    func test_decodeNumberWithTypeInferred() throws {
        let objectData =
"""
{
    "maximum": 10
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: objectData)

        XCTAssertEqual(
            decoded,
            JSONSchema.number(maximum: (10, exclusive: false))
        )
    }

    func test_encodeFloatNumber() {
        let requiredNumber = JSONSchema.number(.init(format: .float, required: true), .init())
        let optionalNumber = JSONSchema.number(.init(format: .float, required: false), .init())
        let nullableNumber = JSONSchema.number(.init(format: .float, required: true, nullable: true), .init())
        let readOnlyNumber = JSONSchema.number(.init(format: .float, required: true, permissions: .readOnly), .init())
        let writeOnlyNumber = JSONSchema.number(.init(format: .float, required: true, permissions: .writeOnly), .init())
        let deprecatedNumber = JSONSchema.number(.init(format: .float, required: true, deprecated: true), .init())
        let allowedValueNumber = JSONSchema.number(.init(format: .float, required: true), .init())
            .with(allowedValues: [11.5])

        testAllSharedFormattedContextEncoding(typeName: "number",
                                              formatName: "float",
                                              requiredEntity: requiredNumber,
                                              optionalEntity: optionalNumber,
                                              nullableEntity: nullableNumber,
                                              readOnlyEntity: readOnlyNumber,
                                              writeOnlyEntity: writeOnlyNumber,
                                              deprecatedEntity: deprecatedNumber,
                                              allowedValues: (entity: allowedValueNumber,
                                                              value: "11.5"))
    }

    func test_decodeFloatNumber() {
        let numberData = #"{"type": "number", "format": "float"}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "format": "float", "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "format": "float", "enum": [1, 2.5]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .float), .init()))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .float, nullable: true), .init()))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .float, allowedValues: [1, 2.5]), .init()))
    }

    func test_encodeDoubleNumber() {
        let requiredNumber = JSONSchema.number(.init(format: .double, required: true), .init())
        let optionalNumber = JSONSchema.number(.init(format: .double, required: false), .init())
        let nullableNumber = JSONSchema.number(.init(format: .double, required: true, nullable: true), .init())
        let readOnlyNumber = JSONSchema.number(.init(format: .double, required: true, permissions: .readOnly), .init())
        let writeOnlyNumber = JSONSchema.number(.init(format: .double, required: true, permissions: .writeOnly), .init())
        let deprecatedNumber = JSONSchema.number(.init(format: .double, required: true, deprecated: true), .init())
        let allowedValueNumber = JSONSchema.number(.init(format: .double, required: true), .init())
            .with(allowedValues: [12.5])

        testAllSharedFormattedContextEncoding(typeName: "number",
                                              formatName: "double",
                                              requiredEntity: requiredNumber,
                                              optionalEntity: optionalNumber,
                                              nullableEntity: nullableNumber,
                                              readOnlyEntity: readOnlyNumber,
                                              writeOnlyEntity: writeOnlyNumber,
                                              deprecatedEntity: deprecatedNumber,
                                              allowedValues: (entity: allowedValueNumber,
                                                              value: "12.5"))
    }

    func test_decodeDoubleNumber() {
        let numberData = #"{"type": "number", "format": "double"}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "format": "double", "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "format": "double", "enum": [1, 2]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .double), .init()))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .double, nullable: true), .init()))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .double, allowedValues: [1, 2]), .init()))
    }

    func test_encodeNumberWithMultipleOf() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(multipleOf: 11))
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init(multipleOf: 11))
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init(multipleOf: 11))
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(multipleOf: 11))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredNumber,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"number\"",
        ])

        testEncodingPropertyLines(entity: optionalNumber,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: nullableNumber,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: allowedValueNumber,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"number\""
        ])
    }

    func test_decodeNumberWithMultipleOf() {
        let numberData = #"{"type": "number", "multipleOf": 2.2}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "multipleOf": 2.2, "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "multipleOf": 2.2, "enum": [2.2, 4.4]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init(multipleOf: 2.2)))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init(multipleOf: 2.2)))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [2.2, 4.4]), .init(multipleOf: 2.2)))
    }

    func test_encodeNumberWithMaximum() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(maximum: (11.5, exclusive: false)))
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init(maximum: (11.5, exclusive: false)))
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init(maximum: (11.5, exclusive: false)))
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(maximum: (11.5, exclusive: false)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredNumber,
                                  propertyLines: [
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\"",
        ])

        testEncodingPropertyLines(entity: optionalNumber,
                                  propertyLines: [
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: nullableNumber,
                                  propertyLines: [
                                    "\"maximum\" : 11.5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: allowedValueNumber,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\""
        ])
    }

    func test_decodeNumberWithMaximum() {
        let numberData = #"{"type": "number", "maximum": 2.2}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "maximum": 2.2, "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "maximum": 2.2, "enum": [2.2, 1.2]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init(maximum: (2.2, exclusive:false))))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init(maximum: (2.2, exclusive:false))))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [2.2, 1.2]), .init(maximum: (2.2, exclusive:false))))
    }

    func test_encodeNumberWithExclusiveMaximum() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(maximum: (11.5, exclusive: true)))
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init(maximum: (11.5, exclusive: true)))
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init(maximum: (11.5, exclusive: true)))
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(maximum: (11.5, exclusive: true)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredNumber,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\"",
        ])

        testEncodingPropertyLines(entity: optionalNumber,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: nullableNumber,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11.5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: allowedValueNumber,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11.5,",
                                    "\"type\" : \"number\""
        ])
    }

    func test_decodeNumberWithExclusiveMaximum() {
        let numberData = #"{"type": "number", "maximum": 2.2, "exclusiveMaximum": true}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "maximum": 2.2, "exclusiveMaximum": true, "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "maximum": 2.2, "exclusiveMaximum": true, "enum": [2.1, 1.2]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init(maximum: (2.2, exclusive:true))))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init(maximum: (2.2, exclusive:true))))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [2.1, 1.2]), .init(maximum: (2.2, exclusive:true))))
    }

    func test_encodeNumberWithMinimum() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(minimum: (0.5, exclusive: false)))
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init(minimum: (0.5, exclusive: false)))
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init(minimum: (0.5, exclusive: false)))
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(minimum: (0.5, exclusive: false)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredNumber,
                                  propertyLines: [
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\"",
        ])

        testEncodingPropertyLines(entity: optionalNumber,
                                  propertyLines: [
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: nullableNumber,
                                  propertyLines: [
                                    "\"minimum\" : 0.5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: allowedValueNumber,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\""
        ])
    }

    func test_decodeNumberWithMinimum() {
        let numberData = #"{"type": "number", "minimum": 1.1}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "minimum": 1.1, "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "minimum": 1.1, "enum": [2.1, 1.2]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init(minimum: (1.1, exclusive:false))))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init(minimum: (1.1, exclusive:false))))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [2.1, 1.2]), .init(minimum: (1.1, exclusive:false))))
    }

    func test_encodeNumberWithExclusivceMinimum() {
        let requiredNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(minimum: (0.5, exclusive: true)))
        let optionalNumber = JSONSchema.number(.init(format: .unspecified, required: false), .init(minimum: (0.5, exclusive: true)))
        let nullableNumber = JSONSchema.number(.init(format: .unspecified, required: true, nullable: true), .init(minimum: (0.5, exclusive: true)))
        let allowedValueNumber = JSONSchema.number(.init(format: .unspecified, required: true), .init(minimum: (0.5, exclusive: true)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredNumber,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\"",
        ])

        testEncodingPropertyLines(entity: optionalNumber,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: nullableNumber,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 0.5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"number\""
        ])

        testEncodingPropertyLines(entity: allowedValueNumber,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 0.5,",
                                    "\"type\" : \"number\""
        ])
    }

    func test_decodeNumberWithExclusiveMinimum() {
        let numberData = #"{"type": "number", "minimum": 1.1, "exclusiveMinimum": true}"#.data(using: .utf8)!
        let nullableNumberData = #"{"type": "number", "minimum": 1.1, "exclusiveMinimum": true, "nullable": true}"#.data(using: .utf8)!
        let allowedValueNumberData = #"{"type": "number", "minimum": 1.1, "exclusiveMinimum": true, "enum": [2.1, 1.2]}"#.data(using: .utf8)!

        let number = try! orderUnstableDecode(JSONSchema.self, from: numberData)
        let nullableNumber = try! orderUnstableDecode(JSONSchema.self, from: nullableNumberData)
        let allowedValueNumber = try! orderUnstableDecode(JSONSchema.self, from: allowedValueNumberData)

        XCTAssertEqual(number, JSONSchema.number(.init(format: .generic), .init(minimum: (1.1, exclusive:true))))
        XCTAssertEqual(nullableNumber, JSONSchema.number(.init(format: .generic, nullable: true), .init(minimum: (1.1, exclusive:true))))
        XCTAssertEqual(allowedValueNumber, JSONSchema.number(.init(format: .generic, allowedValues: [2.1, 1.2]), .init(minimum: (1.1, exclusive:true))))
    }

    func test_encodeInteger() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init())
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init())
        let readOnlyInteger = JSONSchema.integer(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let writeOnlyInteger = JSONSchema.integer(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let deprecatedInteger = JSONSchema.integer(.init(format: .unspecified, required: true, deprecated: true), .init())
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: [10])
        let discriminatorInteger = JSONSchema.integer(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")), .init())

        testAllSharedSimpleContextEncoding(
            typeName: "integer",
            requiredEntity: requiredInteger,
            optionalEntity: optionalInteger,
            nullableEntity: nullableInteger,
            readOnlyEntity: readOnlyInteger,
            writeOnlyEntity: writeOnlyInteger,
            deprecatedEntity: deprecatedInteger,
            allowedValues: (
                entity: allowedValueInteger,
                value: "10"
            ),
            discriminator: (
                entity: discriminatorInteger,
                name: "hello"
            )
        )
    }

    func test_decodeInteger() throws {
        let integerData = #"{"type": "integer"}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "nullable": true}"#.data(using: .utf8)!
        let readOnlyIntegerData = #"{"type": "integer", "readOnly": true}"#.data(using: .utf8)!
        let writeOnlyIntegerData = #"{"type": "integer", "writeOnly": true}"#.data(using: .utf8)!
        let deprecatedIntegerData = #"{"type": "integer", "deprecated": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "enum": [1, 2]}"#.data(using: .utf8)!
        let discriminatorIntegerData = #"{"type": "integer", "discriminator": {"propertyName": "hello"}}"#.data(using: .utf8)!

        let integer = try orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let readOnlyInteger = try orderUnstableDecode(JSONSchema.self, from: readOnlyIntegerData)
        let writeOnlyInteger = try orderUnstableDecode(JSONSchema.self, from: writeOnlyIntegerData)
        let deprecatedInteger = try orderUnstableDecode(JSONSchema.self, from: deprecatedIntegerData)
        let allowedValueInteger = try orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)
        let discriminatorInteger = try orderUnstableDecode(JSONSchema.self, from: discriminatorIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init()))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init()))
        XCTAssertEqual(readOnlyInteger, JSONSchema.integer(.init(format: .generic, permissions: .readOnly), .init()))
        XCTAssertEqual(writeOnlyInteger, JSONSchema.integer(.init(format: .generic, permissions: .writeOnly), .init()))
        XCTAssertEqual(deprecatedInteger, JSONSchema.integer(.init(format: .generic, deprecated: true), .init()))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [1, 2]), .init()))
        XCTAssertEqual(discriminatorInteger, JSONSchema.integer(discriminator: .init(propertyName: "hello")))
    }

    func test_encode32bitInteger() {
        let requiredInteger = JSONSchema.integer(.init(format: .int32, required: true), .init())
        let optionalInteger = JSONSchema.integer(.init(format: .int32, required: false), .init())
        let nullableInteger = JSONSchema.integer(.init(format: .int32, required: true, nullable: true), .init())
        let readOnlyInteger = JSONSchema.integer(.init(format: .int32, required: true, permissions: .readOnly), .init())
        let writeOnlyInteger = JSONSchema.integer(.init(format: .int32, required: true, permissions: .writeOnly), .init())
        let deprecatedInteger = JSONSchema.integer(.init(format: .int32, required: true, deprecated: true), .init())
        let allowedValueInteger = JSONSchema.integer(.init(format: .int32, required: true), .init())
            .with(allowedValues: [11])

        testAllSharedFormattedContextEncoding(typeName: "integer",
                                              formatName: "int32",
                                              requiredEntity: requiredInteger,
                                              optionalEntity: optionalInteger,
                                              nullableEntity: nullableInteger,
                                              readOnlyEntity: readOnlyInteger,
                                              writeOnlyEntity: writeOnlyInteger,
                                              deprecatedEntity: deprecatedInteger,
                                              allowedValues: (entity: allowedValueInteger,
                                                              value: "11"))
    }

    func test_decode32bitInteger() {
        let integerData = #"{"type": "integer", "format": "int32"}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "format": "int32", "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "format": "int32", "enum": [1, 2]}"#.data(using: .utf8)!

        let integer = try! orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try! orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try! orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .int32), .init()))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .int32, nullable: true), .init()))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .int32, allowedValues: [1, 2]), .init()))
    }

    func test_encode64bitInteger() {
        let requiredInteger = JSONSchema.integer(.init(format: .int64, required: true), .init())
        let optionalInteger = JSONSchema.integer(.init(format: .int64, required: false), .init())
        let nullableInteger = JSONSchema.integer(.init(format: .int64, required: true, nullable: true), .init())
        let readOnlyInteger = JSONSchema.integer(.init(format: .int64, required: true, permissions: .readOnly), .init())
        let writeOnlyInteger = JSONSchema.integer(.init(format: .int64, required: true, permissions: .writeOnly), .init())
        let deprecatedInteger = JSONSchema.integer(.init(format: .int64, required: true, deprecated: true), .init())
        let allowedValueInteger = JSONSchema.integer(.init(format: .int64, required: true), .init())
            .with(allowedValues: [12])

        testAllSharedFormattedContextEncoding(typeName: "integer",
                                              formatName: "int64",
                                              requiredEntity: requiredInteger,
                                              optionalEntity: optionalInteger,
                                              nullableEntity: nullableInteger,
                                              readOnlyEntity: readOnlyInteger,
                                              writeOnlyEntity: writeOnlyInteger,
                                              deprecatedEntity: deprecatedInteger,
                                              allowedValues: (entity: allowedValueInteger,
                                                              value: "12"))
    }

    func test_decode64bitInteger() {
        let integerData = #"{"type": "integer", "format": "int64"}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "format": "int64", "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "format": "int64", "enum": [1, 2]}"#.data(using: .utf8)!

        let integer = try! orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try! orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try! orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .int64), .init()))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .int64, nullable: true), .init()))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .int64, allowedValues: [1, 2]), .init()))
    }

    func test_encodeIntegerWithMultipleOf() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(multipleOf: 11))
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init(multipleOf: 11))
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init(multipleOf: 11))
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(multipleOf: 11))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredInteger,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"integer\"",
            ])

        testEncodingPropertyLines(entity: optionalInteger,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: nullableInteger,
                                  propertyLines: [
                                    "\"multipleOf\" : 11,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: allowedValueInteger,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"multipleOf\" : 11,",
                                    "\"type\" : \"integer\""
            ])
    }

    func test_decodeIntegerWithMultipleOf() {
        let integerData = #"{"type": "integer", "multipleOf": 2}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "multipleOf": 2, "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "multipleOf": 2, "enum": [4]}"#.data(using: .utf8)!

        let integer = try! orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try! orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try! orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init(multipleOf: 2)))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init(multipleOf: 2)))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [4]), .init(multipleOf: 2)))
    }

    func test_encodeIntegerWithMaximum() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(maximum: (11, exclusive: false)))
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init(maximum: (11, exclusive: false)))
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init(maximum: (11, exclusive: false)))
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(maximum: (11, exclusive: false)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredInteger,
                                  propertyLines: [
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\"",
            ])

        testEncodingPropertyLines(entity: optionalInteger,
                                  propertyLines: [
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: nullableInteger,
                                  propertyLines: [
                                    "\"maximum\" : 11,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: allowedValueInteger,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\""
            ])
    }

    func test_decodeIntegerWithMaximum() throws {
        let integerData = #"{"type": "integer", "maximum": 1}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "maximum": 1, "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "maximum": 2, "enum": [1, 2]}"#.data(using: .utf8)!
        let integerWithWholeNumberFloatData = #"{"type": "integer", "maximum": 1.0}"#.data(using: .utf8)!

        let integer = try orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)
        let integerWithWholeNumberFloat = try orderUnstableDecode(JSONSchema.self, from: integerWithWholeNumberFloatData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init(maximum: (1, exclusive:false))))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init(maximum: (1, exclusive:false))))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [1, 2]), .init(maximum: (2, exclusive:false))))
        XCTAssertEqual(integerWithWholeNumberFloat, JSONSchema.integer(maximum: (1, exclusive: false)))
    }

    func test_encodeIntegerWithExclusiveMaximum() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(maximum: (11, exclusive: true)))
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init(maximum: (11, exclusive: true)))
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init(maximum: (11, exclusive: true)))
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(maximum: (11, exclusive: true)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredInteger,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\"",
            ])

        testEncodingPropertyLines(entity: optionalInteger,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: nullableInteger,
                                  propertyLines: [
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: allowedValueInteger,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"exclusiveMaximum\" : true,",
                                    "\"maximum\" : 11,",
                                    "\"type\" : \"integer\""
            ])
    }

    func test_decodeIntegerWithExclusiveMaximum() {
        let integerData = #"{"type": "integer", "maximum": 1, "exclusiveMaximum": true}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "maximum": 1, "exclusiveMaximum": true, "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "maximum": 5, "exclusiveMaximum": true, "enum": [2, 3]}"#.data(using: .utf8)!

        let integer = try! orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try! orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try! orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init(maximum: (1, exclusive:true))))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init(maximum: (1, exclusive:true))))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [2, 3]), .init(maximum: (5, exclusive:true))))
    }

    func test_encodeIntegerWithMinimum() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(minimum: (5, exclusive: false)))
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init(minimum: (5, exclusive: false)))
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init(minimum: (5, exclusive: false)))
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(minimum: (5, exclusive: false)))
            .with(allowedValues: [5])

        testEncodingPropertyLines(entity: requiredInteger,
                                  propertyLines: [
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\"",
            ])

        testEncodingPropertyLines(entity: optionalInteger,
                                  propertyLines: [
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: nullableInteger,
                                  propertyLines: [
                                    "\"minimum\" : 5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: allowedValueInteger,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  5",
                                    "],",
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\""
            ])
    }

    func test_decodeIntegerWithMinimum() throws {
        let integerData = #"{"type": "integer", "minimum": 1}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "minimum": 1, "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "minimum": 1, "enum": [1, 2]}"#.data(using: .utf8)!
        let integerWithWholeNumberFloatData = #"{"type": "integer", "minimum": 1.0}"#.data(using: .utf8)!

        let integer = try orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)
        let integerWithWholeNumberFloat = try orderUnstableDecode(JSONSchema.self, from: integerWithWholeNumberFloatData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init(minimum: (1, exclusive:false))))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init(minimum: (1, exclusive:false))))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [1, 2]), .init(minimum: (1, exclusive:false))))
        XCTAssertEqual(integerWithWholeNumberFloat, JSONSchema.integer(minimum: (1, exclusive: false)))
    }

    func test_encodeIntegerWithExclusiveMinimum() {
        let requiredInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(minimum: (5, exclusive: true)))
        let optionalInteger = JSONSchema.integer(.init(format: .unspecified, required: false), .init(minimum: (5, exclusive: true)))
        let nullableInteger = JSONSchema.integer(.init(format: .unspecified, required: true, nullable: true), .init(minimum: (5, exclusive: true)))
        let allowedValueInteger = JSONSchema.integer(.init(format: .unspecified, required: true), .init(minimum: (5, exclusive: true)))
            .with(allowedValues: [10])

        testEncodingPropertyLines(entity: requiredInteger,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\"",
            ])

        testEncodingPropertyLines(entity: optionalInteger,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: nullableInteger,
                                  propertyLines: [
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 5,",
                                    "\"nullable\" : true,",
                                    "\"type\" : \"integer\""
            ])

        testEncodingPropertyLines(entity: allowedValueInteger,
                                  propertyLines: [
                                    "\"enum\" : [",
                                    "  10",
                                    "],",
                                    "\"exclusiveMinimum\" : true,",
                                    "\"minimum\" : 5,",
                                    "\"type\" : \"integer\""
            ])
    }

    func test_decodeIntegerWithExclusiveMinimum() {
        let integerData = #"{"type": "integer", "minimum": 1, "exclusiveMinimum": true}"#.data(using: .utf8)!
        let nullableIntegerData = #"{"type": "integer", "minimum": 1, "exclusiveMinimum": true, "nullable": true}"#.data(using: .utf8)!
        let allowedValueIntegerData = #"{"type": "integer", "minimum": 1, "exclusiveMinimum": true, "enum": [2, 3]}"#.data(using: .utf8)!

        let integer = try! orderUnstableDecode(JSONSchema.self, from: integerData)
        let nullableInteger = try! orderUnstableDecode(JSONSchema.self, from: nullableIntegerData)
        let allowedValueInteger = try! orderUnstableDecode(JSONSchema.self, from: allowedValueIntegerData)

        XCTAssertEqual(integer, JSONSchema.integer(.init(format: .generic), .init(minimum: (1, exclusive:true))))
        XCTAssertEqual(nullableInteger, JSONSchema.integer(.init(format: .generic, nullable: true), .init(minimum: (1, exclusive:true))))
        XCTAssertEqual(allowedValueInteger, JSONSchema.integer(.init(format: .generic, allowedValues: [2, 3]), .init(minimum: (1, exclusive:true))))
    }

    func test_encodeString() {
        let requiredString = JSONSchema.string(.init(format: .unspecified, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .unspecified, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .unspecified, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .unspecified, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .unspecified, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .unspecified, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .unspecified, required: true), .init())
            .with(allowedValues: ["hello"])
        let discriminatorString = JSONSchema.string(.init(format: .unspecified, required: true, discriminator: .init(propertyName: "hello")), .init())

        testAllSharedSimpleContextEncoding(
            typeName: "string",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            ),
            discriminator: (
                entity: discriminatorString,
                name: "hello"
            )
        )
    }

    func test_decodeString() throws {
        let stringData = #"{"type": "string"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "nullable": true}"#.data(using: .utf8)!
        let readOnlyStringData = #"{"type": "string", "readOnly": true}"#.data(using: .utf8)!
        let writeOnlyStringData = #"{"type": "string", "writeOnly": true}"#.data(using: .utf8)!
        let deprecatedStringData = #"{"type": "string", "deprecated": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "enum": ["hello"]}"#.data(using: .utf8)!
        let discriminatorStringData = #"{"type": "string", "discriminator": {"propertyName": "hello"}}"#.data(using: .utf8)!

        let string = try orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let readOnlyString = try orderUnstableDecode(JSONSchema.self, from: readOnlyStringData)
        let writeOnlyString = try orderUnstableDecode(JSONSchema.self, from: writeOnlyStringData)
        let deprecatedString = try orderUnstableDecode(JSONSchema.self, from: deprecatedStringData)
        let allowedValueString = try orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)
        let discriminatorString = try orderUnstableDecode(JSONSchema.self, from: discriminatorStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .generic), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .generic, nullable: true), .init()))
        XCTAssertEqual(readOnlyString, JSONSchema.string(.init(format: .generic, permissions: .readOnly), .init()))
        XCTAssertEqual(writeOnlyString, JSONSchema.string(.init(format: .generic, permissions: .writeOnly), .init()))
        XCTAssertEqual(deprecatedString, JSONSchema.string(.init(format: .generic, deprecated: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .generic, allowedValues: ["hello"]), .init()))
        XCTAssertEqual(discriminatorString, JSONSchema.string(discriminator: .init(propertyName: "hello")))
    }

    func test_decodeStringWithTypeInferred() throws {
        let objectData =
"""
{
    "pattern": ".*"
}
""".data(using: .utf8)!

        let decoded = try orderUnstableDecode(JSONSchema.self, from: objectData)

        XCTAssertEqual(
            decoded,
            JSONSchema.string(pattern: ".*")
        )
    }

    func test_encodeByteString() {
        let requiredString = JSONSchema.string(.init(format: .byte, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .byte, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .byte, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .byte, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .byte, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .byte, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .byte, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(
            typeName: "string",
            formatName: "byte",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            )
        )
    }

    func test_decodeByteString() {
        let stringData = #"{"type": "string", "format": "byte"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "format": "byte", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "format": "byte", "enum": ["hello"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .byte), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .byte, nullable: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .byte, allowedValues: ["hello"]), .init()))
    }

    func test_encodeBinaryString() {
        let requiredString = JSONSchema.string(.init(format: .binary, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .binary, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .binary, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .binary, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .binary, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .binary, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .binary, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(
            typeName: "string",
            formatName: "binary",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            )
        )
    }

    func test_decodeBinaryString() {
        let stringData = #"{"type": "string", "format": "binary"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "format": "binary", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "format": "binary", "enum": ["hello"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .binary), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .binary, nullable: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .binary, allowedValues: ["hello"]), .init()))
    }

    func test_encodeDateString() {
        let requiredString = JSONSchema.string(.init(format: .date, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .date, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .date, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .date, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .date, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .date, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .date, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(
            typeName: "string",
            formatName: "date",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            )
        )
    }

    func test_decodeDateString() {
        let stringData = #"{"type": "string", "format": "date"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "format": "date", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "format": "date", "enum": ["hello"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .date), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .date, nullable: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .date, allowedValues: ["hello"]), .init()))
    }

    func test_encodeDateTimeString() {
        let requiredString = JSONSchema.string(.init(format: .dateTime, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .dateTime, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .dateTime, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .dateTime, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .dateTime, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .dateTime, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .dateTime, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(
            typeName: "string",
            formatName: "date-time",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            )
        )
    }

    func test_decodeDateTimeString() {
        let stringData = #"{"type": "string", "format": "date-time"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "format": "date-time", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "format": "date-time", "enum": ["hello"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .dateTime), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .dateTime, nullable: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .dateTime, allowedValues: ["hello"]), .init()))
    }

    func test_encodePasswordString() {
        let requiredString = JSONSchema.string(.init(format: .password, required: true), .init())
        let optionalString = JSONSchema.string(.init(format: .password, required: false), .init())
        let nullableString = JSONSchema.string(.init(format: .password, required: true, nullable: true), .init())
        let readOnlyString = JSONSchema.string(.init(format: .password, required: true, permissions: .readOnly), .init())
        let writeOnlyString = JSONSchema.string(.init(format: .password, required: true, permissions: .writeOnly), .init())
        let deprecatedString = JSONSchema.string(.init(format: .password, required: true, deprecated: true), .init())
        let allowedValueString = JSONSchema.string(.init(format: .password, required: true), .init())
            .with(allowedValues: ["hello"])

        testAllSharedFormattedContextEncoding(
            typeName: "string",
            formatName: "password",
            requiredEntity: requiredString,
            optionalEntity: optionalString,
            nullableEntity: nullableString,
            readOnlyEntity: readOnlyString,
            writeOnlyEntity: writeOnlyString,
            deprecatedEntity: deprecatedString,
            allowedValues: (
                entity: allowedValueString,
                value: "\"hello\""
            )
        )
    }

    func test_decodePasswordString() {
        let stringData = #"{"type": "string", "format": "password"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "format": "password", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "format": "password", "enum": ["hello"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .password), .init()))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .password, nullable: true), .init()))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .password, allowedValues: ["hello"]), .init()))
    }

    func test_encodeStringWithMaxLength() {
        let requiredString = JSONSchema.string(.init(format: .unspecified, required: true), .init(maxLength: 10))
        let optionalString = JSONSchema.string(.init(format: .unspecified, required: false), .init(maxLength: 10))
        let nullableString = JSONSchema.string(.init(format: .unspecified, required: true, nullable: true), .init(maxLength: 10))
        let allowedValueString = JSONSchema.string(.init(format: .unspecified, required: true), .init(maxLength: 10))
            .with(allowedValues: ["hello"])

        testEncodingPropertyLines(
            entity: requiredString,
            propertyLines: [
                "\"maxLength\" : 10,",
                "\"type\" : \"string\"",
            ]
        )

        testEncodingPropertyLines(
            entity: optionalString,
            propertyLines: [
                "\"maxLength\" : 10,",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: nullableString,
            propertyLines: [
                "\"maxLength\" : 10,",
                "\"nullable\" : true,",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: allowedValueString,
            propertyLines: [
                "\"enum\" : [",
                "  \"hello\"",
                "],",
                "\"maxLength\" : 10,",
                "\"type\" : \"string\""
            ]
        )
    }

    func test_decodeStringWithMaxLength() {
        let stringData = #"{"type": "string", "maxLength": 5}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "maxLength": 5, "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "maxLength": 5, "enum": ["hello", "world"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .generic), .init(maxLength: 5)))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .generic, nullable: true), .init(maxLength: 5)))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .generic, allowedValues: ["hello", "world"]), .init(maxLength: 5)))
    }

    func test_encodeStringWithMinLength() {
        let requiredString = JSONSchema.string(.init(format: .unspecified, required: true), .init(minLength: 5))
        let optionalString = JSONSchema.string(.init(format: .unspecified, required: false), .init(minLength: 5))
        let nullableString = JSONSchema.string(.init(format: .unspecified, required: true, nullable: true), .init(minLength: 5))
        let allowedValueString = JSONSchema.string(.init(format: .unspecified, required: true), .init(minLength: 5))
            .with(allowedValues: ["hello"])

        testEncodingPropertyLines(
            entity: requiredString,
            propertyLines: [
                "\"minLength\" : 5,",
                "\"type\" : \"string\"",
            ]
        )

        testEncodingPropertyLines(
            entity: optionalString,
            propertyLines: [
                "\"minLength\" : 5,",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: nullableString,
            propertyLines: [
                "\"minLength\" : 5,",
                "\"nullable\" : true,",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: allowedValueString,
            propertyLines: [
                "\"enum\" : [",
                "  \"hello\"",
                "],",
                "\"minLength\" : 5,",
                "\"type\" : \"string\""
            ]
        )
    }

    func test_decodeStringWithMinLength() {
        let stringData = #"{"type": "string", "minLength": 3}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "minLength": 3, "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "minLength": 3, "enum": ["hello", "world"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .generic), .init(minLength: 3)))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .generic, nullable: true), .init(minLength: 3)))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .generic, allowedValues: ["hello", "world"]), .init(minLength: 3)))
    }

    func test_encodeStringWithPattern() {
        let requiredString = JSONSchema.string(.init(format: .unspecified, required: true), .init(pattern: ".*hello [wW]orld"))
        let optionalString = JSONSchema.string(.init(format: .unspecified, required: false), .init(pattern: ".*hello [wW]orld"))
        let nullableString = JSONSchema.string(.init(format: .unspecified, required: true, nullable: true), .init(pattern: ".*hello [wW]orld"))
        let allowedValueString = JSONSchema.string(.init(format: .unspecified, required: true), .init(pattern: ".*hello [wW]orld"))
            .with(allowedValues: ["hello World"])

        testEncodingPropertyLines(
            entity: requiredString,
            propertyLines: [
                "\"pattern\" : \".*hello [wW]orld\",",
                "\"type\" : \"string\"",
            ]
        )

        testEncodingPropertyLines(
            entity: optionalString,
            propertyLines: [
                "\"pattern\" : \".*hello [wW]orld\",",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: nullableString,
            propertyLines: [
                "\"nullable\" : true,",
                "\"pattern\" : \".*hello [wW]orld\",",
                "\"type\" : \"string\""
            ]
        )

        testEncodingPropertyLines(
            entity: allowedValueString,
            propertyLines: [
                "\"enum\" : [",
                "  \"hello World\"",
                "],",
                "\"pattern\" : \".*hello [wW]orld\",",
                "\"type\" : \"string\""
            ]
        )
    }

    func test_decodeStringWithPattern() {
        let stringData = #"{"type": "string", "pattern": ".*"}"#.data(using: .utf8)!
        let nullableStringData = #"{"type": "string", "pattern": ".*", "nullable": true}"#.data(using: .utf8)!
        let allowedValueStringData = #"{"type": "string", "pattern": ".*", "enum": ["hello", "world"]}"#.data(using: .utf8)!

        let string = try! orderUnstableDecode(JSONSchema.self, from: stringData)
        let nullableString = try! orderUnstableDecode(JSONSchema.self, from: nullableStringData)
        let allowedValueString = try! orderUnstableDecode(JSONSchema.self, from: allowedValueStringData)

        XCTAssertEqual(string, JSONSchema.string(.init(format: .generic), .init(pattern: ".*")))
        XCTAssertEqual(nullableString, JSONSchema.string(.init(format: .generic, nullable: true), .init(pattern: ".*")))
        XCTAssertEqual(allowedValueString, JSONSchema.string(.init(format: .generic, allowedValues: ["hello", "world"]), .init(pattern: ".*")))
    }

    func test_encodeAll() {
        let allOf = JSONSchema.all(
            of: [
                .object(.init(), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(), .init(properties: [:]))
            ]
        )
        let allOfWithDisciminator = JSONSchema.all(
            of: [
                .object(.init(), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(), .init(properties: [:]))
            ],
            discriminator: .init(propertyName: "hello")
        )
        let allOfWithReference = JSONSchema.all(
            of: [
                .object(.init(), .init(properties: [:])),
                .reference(.component(named: "test"))
            ]
        )

        testEncodingPropertyLines(entity: allOf, propertyLines: [
            "\"allOf\" : [",
            "  {",
            "    \"properties\" : {",
            "      \"hello\" : {",
            "        \"type\" : \"string\"",
            "      }",
            "    },",
            "    \"type\" : \"object\"",
            "  },",
            "  {",
            "    \"type\" : \"object\"",
            "  }",
            "]"
        ])

        testEncodingPropertyLines(entity: allOfWithDisciminator, propertyLines: [
            "\"allOf\" : [",
            "  {",
            "    \"properties\" : {",
            "      \"hello\" : {",
            "        \"type\" : \"string\"",
            "      }",
            "    },",
            "    \"type\" : \"object\"",
            "  },",
            "  {",
            "    \"type\" : \"object\"",
            "  }",
            "],",
            "\"discriminator\" : {",
            "  \"propertyName\" : \"hello\"",
            "}"
        ])

        testEncodingPropertyLines(entity: allOfWithReference, propertyLines: [
            "\"allOf\" : [",
            "  {",
            "    \"type\" : \"object\"",
            "  },",
            "  {",
            "    \"$ref\" : \"#\\/components\\/schemas\\/test\"",
            "  }",
            "]"
        ])
    }

    func test_decodeAll() throws {
        let allData = """
        {
            "allOf": [
                { "type": "object" },
                { "properties": { "hello": { "type": "boolean" } } }
            ]
        }
        """.data(using: .utf8)!

        let allWithDiscriminatorData = """
        {
            "allOf": [
                { "type": "object" },
                { "properties": { "hello": { "type": "boolean" } } }
            ],
            "discriminator": { "propertyName": "hello" }
        }
        """.data(using: .utf8)!
        let allWithReferenceData = """
        {
            "allOf": [
                { "type": "object" },
                { "$ref": "#/components/schemas/test" }
            ]
        }
        """.data(using: .utf8)!

        let all = try orderUnstableDecode(JSONSchema.self, from: allData)
        let allWithDiscriminator = try orderUnstableDecode(JSONSchema.self, from: allWithDiscriminatorData)
        let allWithReference = try orderUnstableDecode(JSONSchema.self, from: allWithReferenceData)

        XCTAssertEqual(
            all,
            JSONSchema.all(
                of: [
                    .object(.init(), .init(properties: [:])),
                    .object(.init(), .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
                ]
            )
        )

        XCTAssertEqual(
            allWithDiscriminator,
            JSONSchema.all(
                of: [
                    .object(.init(), .init(properties: [:])),
                    .object(.init(), .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
                ],
                discriminator: .init(propertyName: "hello")
            )
        )

        XCTAssertEqual(
            allWithReference,
            JSONSchema.all(
                of: [
                    .object(.init(), .init(properties: [:])),
                    .reference(.component(named: "test"))
                ]
            )
        )
    }

    func test_encodeOne() {
        let oneOf = JSONSchema.one(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(format: .unspecified, required: true), .init(properties: ["world": .boolean(.init(format: .generic, required: false))]))
            ]
        )

        let oneOfWithDiscriminator = JSONSchema.one(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(format: .unspecified, required: true), .init(properties: ["world": .boolean(.init(format: .generic, required: false))]))
            ],
            discriminator: .init(propertyName: "hello")
        )
        let oneOfWithReference = JSONSchema.one(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .reference(.component(named: "test"))
            ]
        )

        testEncodingPropertyLines(
            entity: oneOf,
            propertyLines: [
                "\"oneOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"properties\" : {",
                "      \"world\" : {",
                "        \"type\" : \"boolean\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  }",
                "]"
            ]
        )

        testEncodingPropertyLines(
            entity: oneOfWithDiscriminator,
            propertyLines: [
                "\"discriminator\" : {",
                "  \"propertyName\" : \"hello\"",
                "},",
                "\"oneOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"properties\" : {",
                "      \"world\" : {",
                "        \"type\" : \"boolean\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  }",
                "]"
            ]
        )

        testEncodingPropertyLines(
            entity: oneOfWithReference,
            propertyLines: [
                "\"oneOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"$ref\" : \"#\\/components\\/schemas\\/test\"",
                "  }",
                "]"
            ]
        )
    }

    func test_decodeOne() throws {
        let oneData = """
        {
            "oneOf": [
                { "type": "object" },
                { "type": "object", "properties": { "hello": { "type": "boolean" } } }
            ]
        }
        """.data(using: .utf8)!

        let oneWithDiscriminatorData = """
        {
            "oneOf": [
                { "type": "object" },
                { "type": "object", "properties": { "hello": { "type": "boolean" } } }
            ],
            "discriminator": { "propertyName": "hello" }
        }
        """.data(using: .utf8)!

        let oneWithReferenceData = """
        {
            "oneOf": [
                { "type": "object" },
                { "$ref": "#/components/schemas/test" }
            ]
        }
        """.data(using: .utf8)!

        let one = try orderUnstableDecode(JSONSchema.self, from: oneData)
        let oneWithDiscriminator = try orderUnstableDecode(JSONSchema.self, from: oneWithDiscriminatorData)
        let oneWithReference = try orderUnstableDecode(JSONSchema.self, from: oneWithReferenceData)

        XCTAssertEqual(
            one,
            JSONSchema.one(
                of: [
                    .object(.init(format: .generic), .init(properties: [:])),
                    .object(.init(format: .generic), .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
                ]
            )
        )

        XCTAssertEqual(
            oneWithDiscriminator,
            JSONSchema.one(
                of: [
                    .object(.init(format: .generic), .init(properties: [:])),
                    .object(.init(format: .generic), .init(properties: ["hello": .boolean(.init(format: .generic, required: false))]))
                ],
                discriminator: .init(propertyName: "hello")
            )
        )

        XCTAssertEqual(
            oneWithReference,
            JSONSchema.one(
                of: [
                    .object(.init(format: .generic), .init(properties: [:])),
                    .reference(.component(named: "test"))
                ]
            )
        )
    }

    func test_encodeAny() {
        let anyOf = JSONSchema.any(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(format: .unspecified, required: true), .init(properties: ["world": .boolean(.init(format: .generic, required: false))]))
            ]
        )

        let anyOfWithDiscriminator = JSONSchema.any(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .object(.init(format: .unspecified, required: true), .init(properties: ["world": .boolean(.init(format: .generic, required: false))]))
            ],
            discriminator: .init(propertyName: "hello")
        )

        let anyOfWithReference = JSONSchema.any(
            of: [
                .object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])),
                .reference(.component(named: "test"))
            ]
        )

        testEncodingPropertyLines(
            entity: anyOf,
            propertyLines: [
                "\"anyOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"properties\" : {",
                "      \"world\" : {",
                "        \"type\" : \"boolean\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  }",
                "]"
            ]
        )

        testEncodingPropertyLines(
            entity: anyOfWithDiscriminator,
            propertyLines: [
                "\"anyOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"properties\" : {",
                "      \"world\" : {",
                "        \"type\" : \"boolean\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  }",
                "],",
                "\"discriminator\" : {",
                "  \"propertyName\" : \"hello\"",
                "}"
            ]
        )

        testEncodingPropertyLines(
            entity: anyOfWithReference,
            propertyLines: [
                "\"anyOf\" : [",
                "  {",
                "    \"properties\" : {",
                "      \"hello\" : {",
                "        \"type\" : \"string\"",
                "      }",
                "    },",
                "    \"type\" : \"object\"",
                "  },",
                "  {",
                "    \"$ref\" : \"#\\/components\\/schemas\\/test\"",
                "  }",
                "]"
            ]
        )
    }

    func test_decodeAny() throws {
        let anyData = """
        {
            "anyOf": [
                { "type": "boolean" },
                { "type": "object" }
            ]
        }
        """.data(using: .utf8)!

        let anyWithDiscriminatorData = """
        {
            "anyOf": [
                { "type": "boolean" },
                { "type": "object" }
            ],
            "discriminator": { "propertyName": "hello" }
        }
        """.data(using: .utf8)!

        let anyWithReferenceData = """
        {
            "anyOf": [
                { "type": "boolean" },
                { "$ref": "#/components/schemas/test" }
            ]
        }
        """.data(using: .utf8)!

        let any = try orderUnstableDecode(JSONSchema.self, from: anyData)
        let anyWithDiscriminator = try orderUnstableDecode(JSONSchema.self, from: anyWithDiscriminatorData)
        let anyWithReference = try orderUnstableDecode(JSONSchema.self, from: anyWithReferenceData)

        XCTAssertEqual(
            any,
            JSONSchema.any(
                of: [
                    .boolean(.init(format: .generic)),
                    .object(.init(format: .generic), .init(properties: [:]))
                ]
            )
        )

        XCTAssertEqual(
            anyWithDiscriminator,
            JSONSchema.any(
                of: [
                    .boolean(.init(format: .generic)),
                    .object(.init(format: .generic), .init(properties: [:]))
                ],
                discriminator: .init(propertyName: "hello")
            )
        )

        XCTAssertEqual(
            anyWithReference,
            JSONSchema.any(
                of: [
                    .boolean(.init(format: .generic)),
                    .reference(.component(named: "test"))
                ]
            )
        )
    }

    func test_encodeNot() {
        let not = JSONSchema.not(.object(.init(format: .unspecified, required: true), .init(properties: ["hello": .string(.init(format: .generic, required: false), .init())])))

        testEncodingPropertyLines(entity: not, propertyLines: [
            "\"not\" : {",
            "  \"properties\" : {",
            "    \"hello\" : {",
            "      \"type\" : \"string\"",
            "    }",
            "  },",
            "  \"type\" : \"object\"",
            "}"
        ])
    }

    func test_decodeNot() throws {
        let notData = """
        {
            "not": {
                "type": "boolean"
            }
        }
        """.data(using: .utf8)!

        let not = try orderUnstableDecode(JSONSchema.self, from: notData)

        XCTAssertEqual(not, JSONSchema.not(.boolean(.init(format: .generic))))
    }

    func test_encodeFileReference() {
        let fileRef = JSONSchema.reference(.external(URL(string: "hello/world.json#/hello")!))

        testEncodingPropertyLines(entity: fileRef, propertyLines: [
            "\"$ref\" : \"hello\\/world.json#\\/hello\""
        ])
    }

    func test_decodeFileReference() throws {
        let fileRefData = #"{ "$ref": "./other_file.json#/hello" }"#.data(using: .utf8)!

        let fileRef = try orderUnstableDecode(JSONSchema.self, from: fileRefData)

        XCTAssertEqual(fileRef, JSONSchema.reference(.external(URL(string: "./other_file.json#/hello")!)))
    }

    func test_encodeNodeReference() {
        let nodeRef = JSONSchema.reference(.component(named: "requiredBool"))

        testEncodingPropertyLines(entity: nodeRef, propertyLines: [
            "\"$ref\" : \"#\\/components\\/schemas\\/requiredBool\""
        ])
    }

    func test_decodeNodeReference() throws {
        let nodeRefData = ##"{ "$ref": "#/components/schemas/requiredBool" }"##.data(using: .utf8)!

        let nodeRef = try orderUnstableDecode(JSONSchema.self, from: nodeRefData)

        XCTAssertEqual(
            nodeRef,
            JSONSchema.reference(.component(named: "requiredBool"))
        )
    }
}

private func testEncodingPropertyLines<T: Encodable>(entity: T, propertyLines: [String], file: StaticString = #file, line: UInt = #line) {
    var expectedString = "{\n"
    for line in propertyLines {
        expectedString += "  " + line + "\n"
    }
    expectedString += "}"

    assertJSONEquivalent(try? orderUnstableTestStringFromEncoding(of: entity), expectedString, file: file, line: line)
}

private func testAllSharedSimpleContextEncoding<T: Encodable>(
    typeName: String,
    requiredEntity: T,
    optionalEntity: T,
    nullableEntity: T,
    readOnlyEntity: T,
    writeOnlyEntity: T,
    deprecatedEntity: T,
    allowedValues: (entity: T, value: String),
    discriminator: (entity: T, name: String)
    ) {
    testEncodingPropertyLines(
        entity: requiredEntity,
        propertyLines: ["\"type\" : \"\(typeName)\""]
    )

    testEncodingPropertyLines(
        entity: optionalEntity,
        propertyLines: ["\"type\" : \"\(typeName)\""]
    )

    testEncodingPropertyLines(
        entity: nullableEntity,
        propertyLines: [
            "\"nullable\" : true,",
            "\"type\" : \"\(typeName)\""
        ]
    )

    testEncodingPropertyLines(
        entity: readOnlyEntity,
        propertyLines: [
            "\"readOnly\" : true,",
            "\"type\" : \"\(typeName)\""
        ]
    )

    testEncodingPropertyLines(
        entity: writeOnlyEntity,
        propertyLines: [
            "\"type\" : \"\(typeName)\",",
            "\"writeOnly\" : true"
        ]
    )

    testEncodingPropertyLines(
        entity: deprecatedEntity,
        propertyLines: [
            "\"deprecated\" : true,",
            "\"type\" : \"\(typeName)\""
        ]
    )

    testEncodingPropertyLines(
        entity: allowedValues.entity,
        propertyLines: [
            "\"enum\" : [",
            "  \(allowedValues.value)",
            "],",
            "\"type\" : \"\(typeName)\""
        ]
    )

    testEncodingPropertyLines(
        entity: discriminator.entity,
        propertyLines: [
            "\"discriminator\" : {",
            "  \"propertyName\" : \"\(discriminator.name)\"",
            "},",
            "\"type\" : \"\(typeName)\""
        ]
    )
}

private func testAllSharedFormattedContextEncoding<T: Encodable>(
    typeName: String,
    formatName: String,
    requiredEntity: T,
    optionalEntity: T,
    nullableEntity: T,
    readOnlyEntity: T,
    writeOnlyEntity: T,
    deprecatedEntity: T,
    allowedValues: (entity: T, value: String)
    ) {
    testEncodingPropertyLines(entity: requiredEntity,
                              propertyLines: [
                                "\"format\" : \"\(formatName)\",",
                                "\"type\" : \"\(typeName)\""
    ])

    testEncodingPropertyLines(entity: optionalEntity,
                              propertyLines: [
                                "\"format\" : \"\(formatName)\",",
                                "\"type\" : \"\(typeName)\""
    ])

    testEncodingPropertyLines(entity: nullableEntity,
                              propertyLines: [
                                "\"format\" : \"\(formatName)\",",
                                "\"nullable\" : true,",
                                "\"type\" : \"\(typeName)\""
    ])

    testEncodingPropertyLines(entity: readOnlyEntity,
                              propertyLines: [
                                "\"format\" : \"\(formatName)\",",
                                "\"readOnly\" : true,",
                                "\"type\" : \"\(typeName)\""
    ])

    testEncodingPropertyLines(entity: writeOnlyEntity,
                              propertyLines: [
                                "\"format\" : \"\(formatName)\",",
                                "\"type\" : \"\(typeName)\",",
                                "\"writeOnly\" : true"
    ])

    testEncodingPropertyLines(entity: deprecatedEntity,
                              propertyLines: [
                                "\"deprecated\" : true,",
                                "\"format\" : \"\(formatName)\",",
                                "\"type\" : \"\(typeName)\""
    ])

    testEncodingPropertyLines(entity: allowedValues.entity,
                              propertyLines: [
                                "\"enum\" : [",
                                "  \(allowedValues.value)",
                                "],",
                                "\"format\" : \"\(formatName)\",",
                                "\"type\" : \"\(typeName)\""
    ])
}

// MARK: - Building

extension SchemaObjectTests {
    func test_boolean() {
        let _: JSONSchema = .boolean
        let _ = JSONSchema.boolean(
            required: true,
            nullable: true
        )
        let _ = JSONSchema.boolean(
            required: false,
            nullable: false,
            allowedValues: [
                true,
                false
            ]
        )

        let t1 = JSONSchema.boolean(format: .generic)
        XCTAssertEqual(t1, JSONSchema.boolean(format: .init(rawValue: "")))

        let t2 = JSONSchema.boolean(format: .other("integer"))
        XCTAssertEqual(t2, JSONSchema.boolean(format: .init(rawValue: "integer")))
    }

    func test_number() {
        let _: JSONSchema = .number
        let t1 = JSONSchema.number(
            required: true,
            nullable: true
        )
        let t2 = JSONSchema.number
            .requiredSchemaObject()
            .nullableSchemaObject()
        XCTAssertEqual(t1, t2)
        let _ = JSONSchema.number(
            required: false,
            nullable: false,
            description: "A small number",
            multipleOf: 9.5 / 2
        )
        let _ = JSONSchema.number(
            maximum: (9.5, exclusive: false),
            minimum: (2, exclusive: true)
        )
        let _ = JSONSchema.number(
            format: .double,
            allowedValues: 5.5
        )

        let t3 = JSONSchema.number(format: .generic)
        XCTAssertEqual(t3, JSONSchema.number(format: .init(rawValue: "")))

        let t4 = JSONSchema.number(format: .other("Float80"))
        XCTAssertEqual(t4, JSONSchema.number(format: .init(rawValue: "Float80")))
    }

    func test_integer() {
        let _: JSONSchema = .integer
        let _ = JSONSchema.integer(
            required: true,
            nullable: true
        )
        let _ = JSONSchema.integer(
            required: false,
            nullable: false,
            title: "count",
            multipleOf: 3
        )
        let _ = JSONSchema.integer(
            maximum: (10, exclusive: true),
            minimum: (3, exclusive: false)
        )
        let _ = JSONSchema.integer(
            required: true,
            allowedValues: 1, 2, 3
        )

        let t1 = JSONSchema.integer(format: .extended(.uint32))
        XCTAssertEqual(t1, JSONSchema.integer(format: .other("uint32")))
        XCTAssertEqual(t1, JSONSchema.integer(format: .init(rawValue: "uint32")))

        let t2 = JSONSchema.integer(format: .extended(.uint64))
        XCTAssertEqual(t2, JSONSchema.integer(format: .other("uint64")))
        XCTAssertEqual(t2, JSONSchema.integer(format: .init(rawValue: "uint64")))

        let t3 = JSONSchema.integer(format: .generic)
        XCTAssertEqual(t3, JSONSchema.integer(format: .init(rawValue: "")))
    }

    func test_string() {
        let _: JSONSchema = .string
        let _ = JSONSchema.string(
            required: true,
            nullable: true
        )
        let _ = JSONSchema.string(
            required: false,
            nullable: false,
            pattern: "ab..efgh"
        )
        let _ = JSONSchema.string(
            allowedValues: "hello", "world"
        )

        let t1 = JSONSchema.string(format: .extended(.uuid))
        XCTAssertEqual(t1, JSONSchema.string(format: .other("uuid")))
        XCTAssertEqual(t1, JSONSchema.string(format: .init(rawValue: "uuid")))

        let t2 = JSONSchema.string(format: .extended(.email))
        XCTAssertEqual(t2, JSONSchema.string(format: .other("email")))
        XCTAssertEqual(t2, JSONSchema.string(format: .init(rawValue: "email")))

        let t3 = JSONSchema.string(format: .generic)
        XCTAssertEqual(t3, JSONSchema.string(format: .init(rawValue: "")))
    }

    func test_object() {
        let _: JSONSchema = .object
        let _ = JSONSchema.object(
            required: true,
            nullable: true
        )
        let _ = JSONSchema.object(
            required: true,
            nullable: false,
            properties: [
                "hello": .boolean
            ],
            allowedValues: [
                [ "hello": true],
                [ "hello": false]
            ]
        )
        let addProp1 = JSONSchema.object(
            additionalProperties: .init(true)
        )
        let addProp2 = JSONSchema.object(
            additionalProperties: .init(.boolean)
        )
        let addProp3 = JSONSchema.object(
            additionalProperties: .boolean(true)
        )
        let addProp4 = JSONSchema.object(
            additionalProperties: .schema(.boolean)
        )
        XCTAssertEqual(addProp1, addProp3)
        XCTAssertEqual(addProp2, addProp4)

        // a little respect paid to JSON:API
        let _ = JSONSchema.object(
            properties: [
                "data": .object(
                    properties: [
                        "id": .string,
                        "type": .string(allowedValues: ["user"]),
                        "attributes": .object(
                            properties: [
                                "first_name": .string,
                                "last_name": .string,
                                "email": .string,
                                "created_at": .string(format: .dateTime),
                                "bio": .string(nullable: true)
        ])])])

        let t1 = JSONSchema.object(format: .generic)
        XCTAssertEqual(t1, JSONSchema.object(format: .init(rawValue: "")))

        let t2 = JSONSchema.object(format: .other("weird"))
        XCTAssertEqual(t2, JSONSchema.object(format: .init(rawValue: "weird")))
    }

    func test_array() {

        let t1 = JSONSchema.array(format: .generic)
        XCTAssertEqual(t1, JSONSchema.array(format: .init(rawValue: "")))

        let t2 = JSONSchema.array(format: .other("weird"))
        XCTAssertEqual(t2, JSONSchema.array(format: .init(rawValue: "weird")))
    }

    func test_allOf() {
        let t1: JSONSchema = .all(of:
            .object(.init(), .init(properties: ["hello": .string])),
            .object(.init(), .init(properties: ["world": .boolean]))
        )
        let t2: JSONSchema = .all(
            of: [
                .object(.init(), .init(properties: ["hello": .string])),
                .object(.init(), .init(properties: ["world": .boolean]))
            ]
        )

        XCTAssertEqual(t1, t2)
    }

    func test_oneOf() {
        let t1: JSONSchema = .one(of:
            .object(properties: ["hello": .string]),
            .object(properties: ["world": .boolean])
        )
        let t2: JSONSchema = .one(of: [
            .object(properties: ["hello": .string]),
            .object(properties: ["world": .boolean])
            ]
        )

        XCTAssertEqual(t1, t2)
    }

    func test_anyOf() {
        let t1: JSONSchema = .any(of:
            .object(properties: ["hello": .string]),
            .object(properties: ["world": .boolean])
        )
        let t2: JSONSchema = .any(of: [
            .object(properties: ["hello": .string]),
            .object(properties: ["world": .boolean])
            ]
        )

        XCTAssertEqual(t1, t2)
    }
}
