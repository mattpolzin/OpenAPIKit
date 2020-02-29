//
//  GenericOpenAPINodeTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 12/15/19.
//

import XCTest
import OpenAPIKit
import Sampleable

final class GenericOpenAPISchemaTests: XCTestCase {
//    func test_failsAsUnknown() {
//        XCTAssertThrowsError(try FailsAsUnknown.genericOpenAPINode(using: JSONEncoder())) { error in
//            guard let err = error as? OpenAPITypeError,
//                case .unknownNodeType = err else {
//                XCTFail("Expected unknown node type error")
//                return
//            }
//        }
//    }

    func test_emptyObject() throws {
        let node = try EmptyObjectType.genericOpenAPISchemaGuess(using: JSONEncoder())

        XCTAssertEqual(
            node,
            JSONSchema.object(
                properties: [
                    "empty": .object
                ]
            )
        )
    }

    func test_basicTypes() throws {
        let node = try BasicTypes.genericOpenAPISchemaGuess(using: JSONEncoder())

        XCTAssertEqual(
            node,
            JSONSchema.object(
                properties: [
                    "string": .string,
                    "int": .integer,
                    "double": .number(format: .double),
                    "float": .number(format: .float),
                    "bool": .boolean
                ]
            )
       )
    }

    func test_dateType() throws {
        let node = try DateType.genericOpenAPISchemaGuess(using: JSONEncoder())

        XCTAssertEqual(
            node,
            JSONSchema.object(
                properties: [
                    "date": .number(format: .double)
                ]
            )
        )
    }

    func test_dateTypeFormats() throws {
        let e1 = JSONEncoder()
        #if os(Linux)
        e1.dateEncodingStrategy = .iso8601
        #else
        if #available(macOS 10.12, *) {
            e1.dateEncodingStrategy = .iso8601
        }
        #endif

        let node1 = try DateType.genericOpenAPISchemaGuess(using: e1)

        XCTAssertEqual(
            node1,
            JSONSchema.object(
                properties: [
                    "date": .string(format: .dateTime)
                ]
            )
        )

        let e2 = JSONEncoder()
        e2.dateEncodingStrategy = .secondsSince1970
        let e3 = JSONEncoder()
        e3.dateEncodingStrategy = .millisecondsSince1970

        let node2 = try DateType.genericOpenAPISchemaGuess(using: e2)
        let node3 = try DateType.genericOpenAPISchemaGuess(using: e3)

        XCTAssertEqual(node2, node3)
        XCTAssertEqual(
            node2,
            JSONSchema.object(
                properties: [
                    "date": .number(format: .double)
                ]
            )
        )

        let e4 = JSONEncoder()
        let df1 = DateFormatter()
        df1.timeStyle = .none
        e4.dateEncodingStrategy = .formatted(df1)

        let node4 = try DateType.genericOpenAPISchemaGuess(using: e4)

        XCTAssertEqual(
            node4,
            JSONSchema.object(
                properties: [
                    "date": .string(format: .date)
                ]
            )
        )

        let e5 = JSONEncoder()
        let df2 = DateFormatter()
        df2.timeStyle = .full
        e5.dateEncodingStrategy = .formatted(df2)

        let node5 = try DateType.genericOpenAPISchemaGuess(using: e5)

        XCTAssertEqual(
            node5,
            JSONSchema.object(
                properties: [
                    "date": .string(format: .dateTime)
                ]
            )
        )
    }

    func test_nested() throws {
        let node = try Nested.genericOpenAPISchemaGuess(using: JSONEncoder())

        XCTAssertEqual(
            node,
            JSONSchema.object(
                properties: [
                    "array1": .array(items: .string),
                    "array2": .array(items: .number(format: .double)),
                    "array3": .array(items: .number(format: .double)),
                    "dict1": .object(
                        additionalProperties: .init(.string)
                    ),
                    "dict2": .object(
                        additionalProperties: .init(.boolean)
                    ),
                    "dictArray": .object(
                        additionalProperties: .init(.array(items: .integer))
                    ),
                    "arrayDict": .array(
                        items: .object(
                            additionalProperties: .init(.number(format: .double))
                        )
                    ),
                    "structure": .object(
                        properties: [
                            "bool": .boolean,
                            "array": .array(items: .string),
                            "dict": .object(
                                additionalProperties: .init(.integer)
                            )
                        ]
                    )
                ]
            )
        )
    }

    func test_enumTypes() throws {
        let node = try EnumTypes.genericOpenAPISchemaGuess(using: JSONEncoder())

        XCTAssertEqual(node.jsonTypeFormat, .object(.generic))

        guard case .object(_, let ctx) = node else {
            XCTFail("Expected object")
            return
        }

        XCTAssertEqual(ctx.properties["stringEnum"], .string)
        XCTAssertEqual(ctx.properties["intEnum"], .integer)
        XCTAssertEqual(ctx.properties["doubleEnum"], .number(format: .double))
        XCTAssertEqual(ctx.properties["boolEnum"], .boolean)
        XCTAssertEqual(ctx.properties["optionalStringEnum"], .string(required: false))
        XCTAssertEqual(ctx.properties["optionalIntEnum"], .integer(required: false))
        XCTAssertEqual(ctx.properties["optionalDoubleEnum"], .number(format: .double, required: false))
        XCTAssertEqual(ctx.properties["optionalBoolEnum"], .boolean(required: false))
    }

    func test_allowedValues() throws {
        let node = try AllowedValues.genericOpenAPISchemaGuess(using: JSONEncoder())

        guard case let .object(_, objCtx) = node else {
            XCTFail("Expected object")
            return
        }

        guard case let .string(ctx2, _) = objCtx.properties["stringEnum"] else {
            XCTFail("Expected stringEnum property to be a .string")
            return
        }

        XCTAssert(ctx2.allowedValues?.count == 2)
        XCTAssert(ctx2.allowedValues?.contains("hello") ?? false)
        XCTAssert(ctx2.allowedValues?.contains("world") ?? false)

        guard case let .string(ctx3, _) = objCtx.properties["optionalStringEnum"] else {
            XCTFail("Expected optionalStringEnum property to be a .string")
            return
        }

        XCTAssert(ctx3.allowedValues?.count == 2)
        XCTAssert(ctx3.allowedValues?.contains("hello") ?? false)
        XCTAssert(ctx3.allowedValues?.contains("world") ?? false)
        XCTAssertFalse(ctx3.required)

        guard case let .string(ctx4, _) = objCtx.properties["stringStruct"] else {
            XCTFail("Expected stringStruct property to be a .string")
            return
        }

        XCTAssert(ctx4.allowedValues?.count == 2)
        XCTAssert(ctx4.allowedValues?.contains("hi") ?? false)
        XCTAssert(ctx4.allowedValues?.contains("there") ?? false)

        guard case let .string(ctx5, _) = objCtx.properties["optionalStringStruct"] else {
            XCTFail("Expected optionalStringStruct property to be a .string")
            return
        }

        XCTAssert(ctx5.allowedValues?.count == 2)
        XCTAssert(ctx5.allowedValues?.contains("hi") ?? false)
        XCTAssert(ctx5.allowedValues?.contains("there") ?? false)
        XCTAssertFalse(ctx5.required)
    }

    func test_enumDirectly() throws {
        XCTAssertEqual(try AllowedValues.StringEnum.caseIterableOpenAPISchemaGuess(using: JSONEncoder()), .string)

        XCTAssertThrowsError(try CaselessEnum.caseIterableOpenAPISchemaGuess(using: JSONEncoder())) { err in
            XCTAssertEqual(err as? OpenAPI.EncodableError, .exampleNotCodable)
        }
    }

    func test_sampleableInSampleable() throws {
        XCTAssertEqual(
            try SampleableInSampleable.genericOpenAPISchemaGuess(using: JSONEncoder()),
            .object(
                properties: [
                    "sampleable": .string
                ]
            )
        )
    }
}

// MARK: - Test Types

extension GenericOpenAPISchemaTests {
    struct BasicTypes: Codable, Sampleable {
        let string: String
        let int: Int
        let double: Double
        let float: Float
        let bool: Bool

        static let sample: BasicTypes = .init(string: "hello", int: 10, double: 2.3, float: 1.1, bool: true)
    }

    struct DateType: Codable, Sampleable {
        let date: Date

        static let sample: DateType = .init(date: Date())
    }

    struct Nested: Codable, Sampleable {
        let array1: [String]
        let array2: [Double]
        let array3: [Date]

        let dict1: [String: String]
        let dict2: [String: Bool]

        let dictArray: [String: [Int]]

        let arrayDict: [[String: Date]]

        let structure: Structure

        struct Structure: Codable {
            let bool: Bool
            let array: [String]
            let dict: [String: Int]
        }

        static let sample: Nested = .init(
            array1: [],
            array2: [],
            array3: [],
            dict1: [:],
            dict2: [:],
            dictArray: [:],
            arrayDict: [],
            structure: .init(bool: true, array: [], dict: [:])
        )
    }

    struct EnumTypes: Codable, Sampleable {
        let stringEnum: StringEnum
        let intEnum: IntEnum
        let doubleEnum: DoubleEnum
        let boolEnum: BoolEnum

        let optionalStringEnum: StringEnum?
        let optionalIntEnum: IntEnum?
        let optionalDoubleEnum: DoubleEnum?
        let optionalBoolEnum: BoolEnum?

        enum StringEnum: String, Codable, AnyRawRepresentable {
            case hello
            case world
        }

        enum IntEnum: Int, Codable, AnyRawRepresentable {
            case zero
            case one
        }

        enum DoubleEnum: Double, Codable, AnyRawRepresentable {
            case twoPointFive = 2.5
            case onePointTwo = 1.2
        }

        enum BoolEnum: RawRepresentable, Codable, AnyRawRepresentable {
            case `true`
            case `false`

            init?(rawValue: Bool) {
                self = rawValue ? .true : .false
            }

            var rawValue: Bool {
                switch self {
                case .true: return true
                case .false: return false
                }
            }
        }

        static let sample: EnumTypes = .init(
            stringEnum: .hello,
            intEnum: .one,
            doubleEnum: .onePointTwo,
            boolEnum: .true,
            optionalStringEnum: nil,
            optionalIntEnum: nil,
            optionalDoubleEnum: nil,
            optionalBoolEnum: nil
        )
    }

    struct AllowedValues: Codable, Sampleable {
        let stringEnum: StringEnum
        let optionalStringEnum: StringEnum?

        let stringStruct: StringStruct
        let optionalStringStruct: StringStruct?

        enum StringEnum: String, Codable, CaseIterable, AnyJSONCaseIterable {
            case hello
            case world
        }

        struct StringStruct: RawRepresentable, Codable, AnyJSONCaseIterable {

            let val: String

            var rawValue: String { val }

            static func allCases(using encoder: JSONEncoder) -> [AnyCodable] {
                return ["hi", "there"]
            }

            init(val: String) {
                self.val = val
            }

            init?(rawValue: Self.RawValue) {
                self.val = rawValue
            }
        }

        static let sample: AllowedValues = .init(
            stringEnum: .hello,
            optionalStringEnum: nil,
            stringStruct: .init(val: "hi"),
            optionalStringStruct: nil
        )
    }

    struct EmptyObjectType: Codable, Sampleable {
        let empty: EmptyObject

        struct EmptyObject: Codable {}

        static let sample: EmptyObjectType = .init(empty: .init())
    }

    enum CaselessEnum: RawRepresentable, CaseIterable, AnyJSONCaseIterable {
        init?(rawValue: String) {
            return nil
        }
        var rawValue: String { "" }

        typealias RawValue = String

        static func allCases(using encoder: JSONEncoder) -> [AnyCodable] {
            []
        }
    }

    struct SampleableInSampleable: Codable, Sampleable {
        let sampleable: NestedSampleable

        static let sample: Self = .init(sampleable: .sample)

        enum NestedSampleable: String, Codable, CaseIterable, Sampleable, AnyRawRepresentable {
            case one
            case two

            static let sample: Self = .one
        }
    }

//    struct EncodesAsPrimitive: Codable, SampleableOpenAPIType {
//        let asString: AsString
//        let asInt: AsInt
//        let asDouble: AsDouble
//        let asBool: AsBool
//
//        struct AsString: Codable {
//            func encode(to encoder: Encoder) throws {
//                var container = encoder.singleValueContainer()
//
//                try container.encode("hello world")
//            }
//        }
//
//        struct AsInt: Codable {
//            func encode(to encoder: Encoder) throws {
//                var container = encoder.singleValueContainer()
//
//                try container.encode(10)
//            }
//        }
//
//        struct AsDouble: Codable {
//            func encode(to encoder: Encoder) throws {
//                var container = encoder.singleValueContainer()
//
//                try container.encode(5.5)
//            }
//        }
//
//        struct AsBool: Codable {
//            func encode(to encoder: Encoder) throws {
//                var container = encoder.singleValueContainer()
//
//                try container.encode(true)
//            }
//        }
//
//        static let sample: EncodesAsPrimitive = .init(
//            asString: .init(),
//            asInt: .init(),
//            asDouble: .init(),
//            asBool: .init()
//        )
//    }
}
