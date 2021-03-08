//
//  SchemaFragmentCombiningTests.swift
//  
//
//  Created by Mathew Polzin on 8/2/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class SchemaFragmentCombiningTests: XCTestCase {
    // MARK: - Empty
    func test_resolveEmptyFragmentsList() throws {
        let fragments: [JSONSchema] = []
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .fragment(.init())
        )
    }

    // MARK: - Single Fragment
    func test_resolvingSingleDescription() {
        let fragments: [JSONSchema] = [
            .fragment(.init(description: "hello world"))
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .fragment(.init(description: "hello world"))
        )
    }

    func test_resolvingSingleNull() {
        let fragments: [JSONSchema] = [
            .null
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .null
        )
    }

    func test_resolvingSingleBoolean() {
        let fragments: [JSONSchema] = [
            .boolean(.init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .boolean(.init())
        )
    }

    func test_resolvingSingleInteger() {
        let fragments: [JSONSchema] = [
            .integer(.init(), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .integer(.init(), .init())
        )
    }

    func test_resolvingSingleNumber() {
        let fragments: [JSONSchema] = [
            .number(.init(), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .number(.init(), .init())
        )
    }

    func test_resolveSingleString() {
        let fragments: [JSONSchema] = [
            .string(.init(), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .string(.init(), .init())
        )
    }

    func test_resolvingSingleArray() {
        let fragments: [JSONSchema] = [
            .array(.init(), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .array(.init(), DereferencedJSONSchema.ArrayContext(JSONSchema.ArrayContext())!)
        )
    }

    func test_resolvingSingleObject() {
        let fragments: [JSONSchema] = [
            .object(.init(), .init(properties: [:]))
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .object(.init(), DereferencedJSONSchema.ObjectContext(JSONSchema.ObjectContext(properties: [:]))!)
        )
    }

    func test_resolvingSingleObjectReadOnly() {
        let fragments: [JSONSchema] = [
            .object(.init(permissions: .readOnly), .init(properties: [:]))
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .object(.init(permissions: .readOnly), DereferencedJSONSchema.ObjectContext(JSONSchema.ObjectContext(properties: [:]))!)
        )
    }

    func test_resolvingSingleObjectWriteOnly() {
        let fragments: [JSONSchema] = [
            .object(.init(permissions: .writeOnly), .init(properties: [:]))
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .object(.init(permissions: .writeOnly), DereferencedJSONSchema.ObjectContext(JSONSchema.ObjectContext(properties: [:]))!)
        )
    }

    func test_rootObjectRequired() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .object(.init(), .init(properties: [:]))
            ],
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: [:]))!)
        )
    }

    func test_rootObjectPropertiesRequired() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .object(.init(), .init(properties: ["test": .string]))
            ],
            .object(
                .init(),
                DereferencedJSONSchema.ObjectContext(
                    .init(properties: ["test": .string])
                )!
            )
        )
    }

    func test_rootObjectPropertiesOptional() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .object(.init(), .init(properties: ["test": .string(required: false)]))
            ],
            .object(
                .init(),
                DereferencedJSONSchema.ObjectContext(
                    .init(properties: ["test": .string(required: false)])
                )!
            )
        )
    }

    // MARK: - Formats
    func test_resolvingSingleIntegerWithFormat() {
        let fragments: [JSONSchema] = [
            .integer(.init(format: .int32), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .integer(.init(format: .int32), .init())
        )
    }

    func test_resolvingSingleNumberWithFormat() {
        let fragments: [JSONSchema] = [
            .number(.init(format: .double), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .number(.init(format: .double), .init())
        )
    }

    func test_resolveSingleStringWithFormat() {
        let fragments: [JSONSchema] = [
            .string(.init(format: .binary), .init())
        ]
        XCTAssertEqual(
            try fragments.combined(resolvingAgainst: .noComponents),
            .string(.init(format: .binary), .init())
        )
    }

    // MARK: - Fragment Combinations
    func assertOrderIndependentCombinedEqual(_ fragments: [JSONSchema], _ schema: DereferencedJSONSchema, file: StaticString = #file, line: UInt = #line) throws {
        let resolved1 = try fragments.combined(resolvingAgainst: .noComponents)
        let schemaString = try orderUnstableTestStringFromEncoding(of: schema.jsonSchema)
        let resolvedSchemaString = try orderUnstableTestStringFromEncoding(of: resolved1.jsonSchema)
        XCTAssertEqual(
            resolved1,
            schema,
            "\n\n\(resolvedSchemaString ?? "nil") \n!=\n \(schemaString ?? "nil")",
            file: (file),
            line: line
        )
        let resolved2 = try fragments.reversed().combined(resolvingAgainst: .noComponents)
        XCTAssertEqual(
            resolved2,
            schema,
            "\n\n\(resolvedSchemaString ?? "nil") \n!=\n \(schemaString ?? "nil")",
            file: (file),
            line: line
        )
    }

    func test_resolveAnyFragmentAndDisciminatorFragment() throws {
        let fragmentsAndResults: [(JSONSchema, DereferencedJSONSchema)] = [
            (.boolean(.init()), .boolean(.init(discriminator: .init(propertyName: "test")))),
            (.integer(.init(), .init()), .integer(.init(discriminator: .init(propertyName: "test")), .init())),
            (.number(.init(), .init()), .number(.init(discriminator: .init(propertyName: "test")), .init())),
            (.string(.init(), .init()), .string(.init(discriminator: .init(propertyName: "test")), .init())),
            (.array(.init(), .init()), .array(.init(discriminator: .init(propertyName: "test")), DereferencedJSONSchema.ArrayContext(.init())!)),
            (.object(.init(), .init(properties: [:])), .object(.init(discriminator: .init(propertyName: "test")), DereferencedJSONSchema.ObjectContext(.init(properties: [:]))!))
        ]

        for (fragment, result) in fragmentsAndResults {
            try assertOrderIndependentCombinedEqual(
                [
                    fragment,
                    .fragment(.init(discriminator: .init(propertyName: "test")))
                ],
                result
            )
        }
    }

    func test_resolveStringFragmentAndFormatFragment() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(.init(), .init()),
                .fragment(.init(format: .other("binary")))
            ],
            .string(.init(format: .binary), .init())
        )
    }

    func test_threeStringFragments() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(.init(description: "test"), .init(minLength: 2)),
                .string(.init(format: .byte), .init(maxLength: 5)),
                .string(.init(description: "test"), .init())
            ],
            .string(.init(format: .byte, description: "test"), .init(maxLength: 5, minLength: 2))
        )
    }

    func test_nullAndBoolean() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .boolean(nullable: false)
            ],
            .boolean(.init(nullable: true))
        )
    }

    func test_nullAndInteger() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .integer(nullable: false)
            ],
            .integer(.init(nullable: true), .init())
        )
    }

    func test_nullAndNumber() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .number(nullable: false)
            ],
            .number(.init(nullable: true), .init())
        )
    }

    func test_nullAndString() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .string(nullable: false)
            ],
            .string(.init(nullable: true), .init())
        )
    }

    func test_nullAndArray() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .array(nullable: false)
            ],
            .array(.init(nullable: true), DereferencedJSONSchema.ArrayContext.init(.init())!)
        )
    }

    func test_nullAndObject() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .null,
                .object(nullable: false)
            ],
            .object(.init(nullable: true), DereferencedJSONSchema.ObjectContext.init(.init(properties: [:]))!)
        )
    }

    func test_optionalAndOptional() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(required: false),
                .string(required: false)
            ],
            .string(.init(required: false), .init())
        )
    }

    func test_requiredAndOptional() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(required: false),
                .string(required: true)
            ],
            .string(.init(), .init())
        )
    }

    func test_requiredAndRequired() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(required: true),
                .string(required: true)
            ],
            .string(.init(), .init())
        )
    }

    func test_deeperObjectFragments() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .object(.init(), .init(properties: [:], additionalProperties: .init(true))),
                .object(.init(description: "nested"), .init(properties: [:])),
                .object(
                    .init(),
                    .init(
                        properties: [
                            "required": .string
                        ],
                        minProperties: 2
                    )
                ),
                .object(
                    .init(),
                    .init(
                        properties: [
                            "optional": .boolean(required: false),
                            "someObject": .object(required: false),
                            "anything": .fragment(.init(description: nil))
                        ],
                        minProperties: 2
                    )
                )
            ],
            .object(
                .init(description: "nested"),
                DereferencedJSONSchema.ObjectContext(
                    .init(
                        properties: [
                            "required": .string,
                            "optional": .boolean(required: false),
                            "someObject": .object(required: false),
                            "anything": .fragment(.init(description: nil))
                        ],
                        additionalProperties: .init(true),
                        minProperties: 2
                    )
                )!
            )
        )
    }

    func test_evenDeeperObjectFragments() throws {
        let fragments: [JSONSchema] = [
            .object(
                .init(),
                .init(
                    properties: [
                        "more_object": .object(required: false, properties: ["boolean": .boolean])
                    ]
                )
            ),
            .object(
                .init(),
                .init(
                    properties: [
                        "more_fragments": .all(
                            of: [
                                .object(.init(description: "nested"), .init(properties: ["someObject": .object])),
                                .object(.init(title: "nested test"), .init(
                                    properties: [
                                        "boolean": .boolean(format: .other("integer"), required: false),
                                        "string": .string(maxLength: 50),
                                        "integer": .integer(required: false, maximum: (10, exclusive: false)),
                                        "number": .number(required: false, maximum: (33.2, exclusive: false)),
                                        "array": .array(required: false, maxItems: 22)
                                    ]
                                )),
                                .object(.init(title: "nested test"), .init(
                                    properties: [
                                        "boolean": .boolean(required: false, description: "boolean"),
                                        "string": .string(description: "string"),
                                        "integer": .integer(required: false, description: "integer"),
                                        "number": .number(required: false, description: "number"),
                                        "array": .array(required: true, description: "array")
                                    ]
                                ))
                            ]
                        )
                    ]
                )
            )
        ]

        let expectedResult = DereferencedJSONSchema.object(
            .init(),
            DereferencedJSONSchema.ObjectContext(
                .init(
                    properties: [
                        "more_object": .object(required: false, properties: ["boolean": .boolean]),
                        "more_fragments": .object(
                            title: "nested test",
                            description: "nested",
                            properties: [
                                "someObject": .object,
                                "boolean": .boolean(format: .other("integer"), required: false, description: "boolean"),
                                "string": .string(required: true, description: "string", maxLength: 50),
                                "integer": .integer(required: false, description: "integer", maximum: (10, exclusive: false)),
                                "number": .number(required: false, description: "number", maximum: (33.2, exclusive: false)),
                                "array": .array(required: true, description: "array", maxItems: 22)
                            ]
                        )
                    ]
                )
            )!
        )

        try assertOrderIndependentCombinedEqual(
            fragments,
            expectedResult
        )
    }

    func test_minLessThanMaxObject() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .object(.init(), .init(properties: [:], minProperties: 2)),
                .object(.init(), .init(properties: [:], maxProperties: 3))
            ],
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: [:], maxProperties: 3, minProperties: 2))!)
        )
    }

    func test_minLessThanMaxArray() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .array(.init(), .init(minItems: 2)),
                .array(.init(), .init(maxItems: 3))
            ],
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(maxItems: 3, minItems: 2))!)
        )
    }

    func test_minLessThanMaxString() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .string(.init(), .init(minLength: 2)),
                .string(.init(), .init(maxLength: 3))
            ],
            .string(.init(), .init(maxLength: 3, minLength: 2))
        )
    }

    func test_minLessThanMaxNumber() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .number(.init(), .init(minimum: (2, exclusive: false))),
                .number(.init(), .init(maximum: (3, exclusive: false)))
            ],
            .number(.init(), .init(maximum: (3, exclusive: false), minimum: (2, exclusive: false)))
        )
    }

    func test_minLessThanMaxInteger() throws {
        try assertOrderIndependentCombinedEqual(
            [
                .integer(.init(), .init(minimum: (2, exclusive: false))),
                .integer(.init(), .init(maximum: (3, exclusive: false)))
            ],
            .integer(.init(), .init(maximum: (3, exclusive: false), minimum: (2, exclusive: false)))
        )
    }

    // MARK: - Dereferencing
    func test_referenceNotFound() {
        let t1 = [JSONSchema.reference(.component(named: "test"))]
        XCTAssertThrowsError(try t1.combined(resolvingAgainst: .noComponents)) { error in
            XCTAssertEqual((error as? OpenAPI.Components.ReferenceError)?.description, "Failed to look up a JSON Reference. \'test\' was not found in schemas.")
        }

        let t2 = [
            JSONSchema.object(.init(description: "test"), .init(properties: [:])),
            JSONSchema.object(.init(), .init(properties: [ "test": .reference(.component(named: "test"))]))
        ]
        XCTAssertThrowsError(try t2.combined(resolvingAgainst: .noComponents)) { error in
            XCTAssertEqual((error as? OpenAPI.Components.ReferenceError)?.description, "Failed to look up a JSON Reference. \'test\' was not found in schemas.")
        }
    }

    func test_referenceFound() throws {
        let components = OpenAPI.Components(
            schemas: [
                "test": .string
            ]
        )

        let t1 = [JSONSchema.reference(.component(named: "test"))]
        let schema1 = try t1.combined(resolvingAgainst: components)
        XCTAssertEqual(
            schema1,
            JSONSchema.string.dereferenced()
        )

        let t2 = [
            JSONSchema.object(.init(description: "test"), .init(properties: [:])),
            JSONSchema.object(.init(), .init(properties: [ "test": .reference(.component(named: "test"))]))
        ]
        let schema2 = try t2.combined(resolvingAgainst: components)
        XCTAssertEqual(
            schema2,
            JSONSchema.object(description: "test", properties: ["test": .string]).dereferenced()
        )
    }

    // MARK: - Compound Nestings
    func test_allOfInAllOf() throws {
        let t1 = JSONSchema.all(
            of: [
                .object(title: "hello world"),
                .object(description: "hi"),
                .all(
                    of: [
                        .object(
                            properties: [
                                "string": .string
                            ]
                        ),
                        .object(minProperties: 1)
                    ]
                )
            ]
        )

        let expectedSimplification = JSONSchema.object(
            title: "hello world",
            description: "hi",
            minProperties: 1,
            properties: [
                "string": .string
            ]
        ).dereferenced()

        let schema = try t1.simplified(given: .noComponents)

        XCTAssertEqual(schema, expectedSimplification)
    }

    // MARK: - Conflict Failures
    func test_typeConflicts() {
        let booleanFragment = JSONSchema.boolean(.init())
        let integerFragment = JSONSchema.integer(.init(), .init())
        let numberFragment = JSONSchema.number(.init(), .init())
        let stringFragment = JSONSchema.string(.init(), .init())
        let arrayFragment = JSONSchema.array(.init(), .init())
        let objectFragment = JSONSchema.object(.init(), .init(properties: [:]))

        let fragments = [
            booleanFragment,
            integerFragment,
            numberFragment,
            stringFragment,
            arrayFragment,
            objectFragment
        ]

        for left in fragments {
            for right in fragments where right != left {
                XCTAssertThrowsError(try [left, right].combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .typeConflict)
                }
            }
        }
    }

    func test_booleanFormatConflicts() {
        // boolean does not have any built-in formats, but we can use two different custom formats.
        let format1: JSONTypeFormat.BooleanFormat = .other("integer")
        let format2: JSONTypeFormat.BooleanFormat = .other("textual")

        let formatStrings = [
            format1,
            format2
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .boolean(.init(format: left)),
                    .boolean(.init(format: right))
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_integerFormatConflicts() {
        let int32: JSONTypeFormat.IntegerFormat = .int32
        let int64: JSONTypeFormat.IntegerFormat = .int64
        let uint32: JSONTypeFormat.IntegerFormat = .extended(.uint32)
        let other: JSONTypeFormat.IntegerFormat = .other("bigint")

        let formatStrings = [
            int32,
            int64,
            uint32,
            other
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .integer(.init(format: left), .init()),
                    .integer(.init(format: right), .init())
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_numberFormatConflicts() {
        let float: JSONTypeFormat.NumberFormat = .float
        let double: JSONTypeFormat.NumberFormat = .double
        let other: JSONTypeFormat.NumberFormat = .other("bigint")

        let formatStrings = [
            float,
            double,
            other
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .number(.init(format: left), .init()),
                    .number(.init(format: right), .init())
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_StringFormatConflicts() {
        let byte: JSONTypeFormat.StringFormat = .byte
        let binary: JSONTypeFormat.StringFormat = .binary
        let date: JSONTypeFormat.StringFormat = .date
        let dateTime: JSONTypeFormat.StringFormat = .dateTime
        let password: JSONTypeFormat.StringFormat = .password
        let uuid: JSONTypeFormat.StringFormat = .extended(.uuid)
        let other: JSONTypeFormat.StringFormat = .other("moontalk")

        let formatStrings = [
            byte,
            binary,
            date,
            dateTime,
            password,
            uuid,
            other
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .string(.init(format: left), .init()),
                    .string(.init(format: right), .init())
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_ArrayFormatConflicts() {
        // array does not have any built-in formats, but we can use two different custom formats.
        let format1: JSONTypeFormat.ArrayFormat = .other("numbered")
        let format2: JSONTypeFormat.ArrayFormat = .other("bulleted")

        let formatStrings = [
            format1,
            format2
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .array(.init(format: left), .init()),
                    .array(.init(format: right), .init())
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_ObjectFormatConflicts() {
        // object does not have any built-in formats, but we can use two different custom formats.
        let format1: JSONTypeFormat.ObjectFormat = .other("compact")
        let format2: JSONTypeFormat.ObjectFormat = .other("pretty")

        let formatStrings = [
            format1,
            format2
        ]

        for left in formatStrings {
            for right in formatStrings where left != right {
                let fragments: [JSONSchema] = [
                    .object(.init(format: left), .init(properties: [:])),
                    .object(.init(format: right), .init(properties: [:]))
                ]
                XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                    guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                    XCTAssert(error ~= .formatConflict)
                }
            }
        }
    }

    func test_generalAttributeConflicts() {

        typealias AnyContext = JSONSchema.CoreContext<JSONTypeFormat.AnyFormat>

        let differentDescription = [
            AnyContext(description: "string1"),
            AnyContext(description: "string2")
        ]

        let differentDiscriminator = [
            AnyContext(discriminator: .init(propertyName: "string1")),
            AnyContext(discriminator: .init(propertyName: "string2"))
        ]

        let differentTitle = [
            AnyContext(title: "string1"),
            AnyContext(title: "string2")
        ]

        let differentNullable = [
            AnyContext(nullable: true),
            AnyContext(nullable: false)
        ]

        let differentDeprecated = [
            AnyContext(deprecated: true),
            AnyContext(deprecated: false)
        ]

        let differentExternalDocs = [
            AnyContext(externalDocs: .init(url: URL(string: "https://string1.com")!)),
            AnyContext(externalDocs: .init(url: URL(string: "https://string2.com")!))
        ]

        let differentAllowedValues = [
            AnyContext(allowedValues: ["string1"]),
            AnyContext(allowedValues: ["string2"])
        ]

        let differentExample = [
            AnyContext(example: "string1"),
            AnyContext(example: "string2")
        ]

        let differences = [
            differentDescription,
            differentDiscriminator,
            differentTitle,
            differentNullable,
            differentDeprecated,
            differentExternalDocs,
            differentAllowedValues,
            differentExample
        ]

        // break up for type checking
        let fragmentsArray1: [[JSONSchema]] = differences.map { $0.map { .fragment($0) } }
        let fragmentsArray2: [[JSONSchema]] = differences.map { $0.map { .boolean($0.transformed()) } }
        let fragmentsArray3: [[JSONSchema]] = differences.map { $0.map { .integer($0.transformed(), .init()) } }
        let fragmentsArray4: [[JSONSchema]] = differences.map { $0.map { .number($0.transformed(), .init()) } }
        let fragmentsArray5: [[JSONSchema]] = differences.map { $0.map { .string($0.transformed(), .init()) } }
        let fragmentsArray6: [[JSONSchema]] = differences.map { $0.map { .array($0.transformed(), .init()) } }
        let fragmentsArray7: [[JSONSchema]] = differences.map { $0.map { .object($0.transformed(), .init(properties: [:])) } }

        let allFragmentsArrays  = fragmentsArray1
            + fragmentsArray2
            + fragmentsArray3
            + fragmentsArray4
            + fragmentsArray5
            + fragmentsArray6
            + fragmentsArray7

        for fragments in allFragmentsArrays {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    func test_integerAttributeConflicts() {
        let differentMultipleOf = [
            JSONSchema.IntegerContext(multipleOf: 10),
            JSONSchema.IntegerContext(multipleOf: 2)
        ]

        let differentMaximum = [
            JSONSchema.IntegerContext(maximum: (10, exclusive: false)),
            JSONSchema.IntegerContext(maximum: (100, exclusive: false))
        ]

        let differentExclusiveMaximum = [
            JSONSchema.IntegerContext(maximum: (10, exclusive: true)),
            JSONSchema.IntegerContext(maximum: (10, exclusive: false))
        ]

        let differentMinimum = [
            JSONSchema.IntegerContext(minimum: (1, exclusive: false)),
            JSONSchema.IntegerContext(minimum: (3, exclusive: false))
        ]

        let differentExclusiveMinimum = [
            JSONSchema.IntegerContext(minimum: (10, exclusive: true)),
            JSONSchema.IntegerContext(minimum: (10, exclusive: false))
        ]

        let differences = [
            differentMultipleOf,
            differentMaximum,
            differentExclusiveMaximum,
            differentMinimum,
            differentExclusiveMinimum
        ]

        for difference in differences {
            let fragments: [JSONSchema] = difference.map { .integer(.init(), $0) }
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    func test_numberAttributeConflicts() {
        let differentMultipleOf = [
            JSONSchema.NumericContext(multipleOf: 10),
            JSONSchema.NumericContext(multipleOf: 2)
        ]

        let differentMaximum = [
            JSONSchema.NumericContext(maximum: (10, exclusive: false)),
            JSONSchema.NumericContext(maximum: (100, exclusive: false))
        ]

        let differentExclusiveMaximum = [
            JSONSchema.NumericContext(maximum: (10, exclusive: true)),
            JSONSchema.NumericContext(maximum: (10, exclusive: false))
        ]

        let differentMinimum = [
            JSONSchema.NumericContext(minimum: (1, exclusive: false)),
            JSONSchema.NumericContext(minimum: (3, exclusive: false))
        ]

        let differentExclusiveMinimum = [
            JSONSchema.NumericContext(minimum: (10, exclusive: true)),
            JSONSchema.NumericContext(minimum: (10, exclusive: false))
        ]

        let differences = [
            differentMultipleOf,
            differentMaximum,
            differentExclusiveMaximum,
            differentMinimum,
            differentExclusiveMinimum
        ]

        for difference in differences {
            let fragments: [JSONSchema] = difference.map { .number(.init(), $0) }
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    func test_StringAttributeConflicts() {
        let differentMaxLength = [
            JSONSchema.StringContext(maxLength: 10),
            JSONSchema.StringContext(maxLength: 2)
        ]

        let differentMinLength = [
            JSONSchema.StringContext(minLength: 10),
            JSONSchema.StringContext(minLength: 100)
        ]

        let differentPattern = [
            JSONSchema.StringContext(pattern: "string1"),
            JSONSchema.StringContext(pattern: "string2")
        ]

        let differences = [
            differentMaxLength,
            differentMinLength,
            differentPattern
        ]

        for difference in differences {
            let fragments: [JSONSchema] = difference.map { .string(.init(), $0) }
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    func test_ArrayAttributeConflicts() {
        let differentItems = [
            JSONSchema.ArrayContext(items: .string),
            JSONSchema.ArrayContext(items: .boolean)
        ]

        let differentMaxItems = [
            JSONSchema.ArrayContext(maxItems: 10),
            JSONSchema.ArrayContext(maxItems: 100)
        ]

        let differentMinItems = [
            JSONSchema.ArrayContext(minItems: 1),
            JSONSchema.ArrayContext(minItems: 2)
        ]

        let differentUniqueItems = [
            JSONSchema.ArrayContext(uniqueItems: true),
            JSONSchema.ArrayContext(uniqueItems: false)
        ]

        let differences = [
            differentItems,
            differentMaxItems,
            differentMinItems,
            differentUniqueItems
        ]

        for difference in differences {
            let fragments: [JSONSchema] = difference.map { .array(.init(), $0) }
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    func test_ObjectAttributeConflicts() {
        let differentMaxProperties = [
            JSONSchema.ObjectContext(properties: [:], maxProperties: 10),
            JSONSchema.ObjectContext(properties: [:], maxProperties: 2)
        ]

        let differentMinProperties = [
            JSONSchema.ObjectContext(properties: [:], minProperties: 10),
            JSONSchema.ObjectContext(properties: [:], minProperties: 100)
        ]

        let differentProperties = [
            JSONSchema.ObjectContext(properties: ["string1": .string(description: "truth")]),
            JSONSchema.ObjectContext(properties: ["string1": .string(description: "falsity")])
        ]

        let differentAdditionalProperties1 = [
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(true)),
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(false))
        ]

        let differentAdditionalProperties2 = [
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(true)),
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(.string))
        ]

        let differentAdditionalProperties3 = [
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(.boolean)),
            JSONSchema.ObjectContext(properties: [:], additionalProperties: .init(.string))
        ]

        let differences = [
            differentMaxProperties,
            differentMinProperties,
            differentProperties,
            differentAdditionalProperties1,
            differentAdditionalProperties2,
            differentAdditionalProperties3
        ]

        for difference in differences {
            let fragments: [JSONSchema] = difference.map { .object(.init(), $0) }
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents), "\(fragments)") { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .attributeConflict, "\(error) is not ~= `.attributeConflict` --  \(fragments)")
            }
        }
    }

    // MARK: - Inconsistency Failures
    func test_generalInconsistencyErrors() {

        let fragmentsArray: [[JSONSchema]] = [
            // boolean readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .boolean(.init(permissions: .readOnly)),
                .boolean(.init(permissions: .writeOnly))
            ],
            [
                .boolean(.init(permissions: .readOnly)),
                .boolean(.init(permissions: .readWrite))
            ],
            [
                .boolean(.init(permissions: .writeOnly)),
                .boolean(.init(permissions: .readWrite))
            ],
            // integer readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .integer(.init(permissions: .readOnly), .init()),
                .integer(.init(permissions: .writeOnly), .init())
            ],
            [
                .integer(.init(permissions: .readOnly), .init()),
                .integer(.init(permissions: .readWrite), .init())
            ],
            [
                .integer(.init(permissions: .writeOnly), .init()),
                .integer(.init(permissions: .readWrite), .init())
            ],
            // number readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .number(.init(permissions: .readOnly), .init()),
                .number(.init(permissions: .writeOnly), .init())
            ],
            [
                .number(.init(permissions: .readOnly), .init()),
                .number(.init(permissions: .readWrite), .init())
            ],
            [
                .number(.init(permissions: .writeOnly), .init()),
                .number(.init(permissions: .readWrite), .init())
            ],
            // string readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .string(.init(permissions: .readOnly), .init()),
                .string(.init(permissions: .writeOnly), .init())
            ],
            [
                .string(.init(permissions: .readOnly), .init()),
                .string(.init(permissions: .readWrite), .init())
            ],
            [
                .string(.init(permissions: .writeOnly), .init()),
                .string(.init(permissions: .readWrite), .init())
            ],
            // array readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .array(.init(permissions: .readOnly), .init()),
                .array(.init(permissions: .writeOnly), .init())
            ],
            [
                .array(.init(permissions: .readOnly), .init()),
                .array(.init(permissions: .readWrite), .init())
            ],
            [
                .array(.init(permissions: .writeOnly), .init()),
                .array(.init(permissions: .readWrite), .init())
            ],
            // object readOnly/writeOnly, readOnly/readWrite, writeOnly/readWrite
            [
                .object(.init(permissions: .readOnly), .init(properties: [:])),
                .object(.init(permissions: .writeOnly), .init(properties: [:]))
            ],
            [
                .object(.init(permissions: .readOnly), .init(properties: [:])),
                .object(.init(permissions: .readWrite), .init(properties: [:]))
            ],
            [
                .object(.init(permissions: .writeOnly), .init(properties: [:])),
                .object(.init(permissions: .readWrite), .init(properties: [:]))
            ]
        ]

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }

    func test_integerInconsistencyErrors() {

        let minBelowZero = [
            JSONSchema.IntegerContext(minimum: (-1, exclusive: false))
        ]

        let minHigherThanMax = [
            JSONSchema.IntegerContext(minimum: (10, exclusive: false)),
            JSONSchema.IntegerContext(maximum: (2, exclusive: false))
        ]

        let inconsistencies = [
            minBelowZero,
            minHigherThanMax
        ]

        // break up for type checking
        let fragmentsArray: [[JSONSchema]] = inconsistencies.map { $0.map { .integer(.init(), $0) } }

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }

    func test_numberInconsistencyErrors() {

        let minBelowZero = [
            JSONSchema.NumericContext(minimum: (-1, exclusive: false))
        ]

        let minHigherThanMax = [
            JSONSchema.NumericContext(minimum: (10, exclusive: false)),
            JSONSchema.NumericContext(maximum: (2, exclusive: false))
        ]

        let inconsistencies = [
            minBelowZero,
            minHigherThanMax
        ]

        // break up for type checking
        let fragmentsArray: [[JSONSchema]] = inconsistencies.map { $0.map { .number(.init(), $0) } }

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }

    func test_stringInconsistencyErrors() {

        let minBelowZero = [
            JSONSchema.StringContext(minLength: -1)
        ]

        let minHigherThanMax = [
            JSONSchema.StringContext(minLength: 10),
            JSONSchema.StringContext(maxLength: 2)
        ]

        let inconsistencies = [
            minBelowZero,
            minHigherThanMax
        ]

        // break up for type checking
        let fragmentsArray: [[JSONSchema]] = inconsistencies.map { $0.map { .string(.init(), $0) } }

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }

    func test_arrayInconsistencyErrors() {

        let minBelowZero = [
            JSONSchema.ArrayContext(minItems: -1)
        ]

        let minHigherThanMax = [
            JSONSchema.ArrayContext(minItems: 10),
            JSONSchema.ArrayContext(maxItems: 2)
        ]

        let inconsistencies = [
            minBelowZero,
            minHigherThanMax
        ]

        // break up for type checking
        let fragmentsArray: [[JSONSchema]] = inconsistencies.map { $0.map { .array(.init(), $0) } }

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }

    func test_objectInconsistencyErrors() {

        let minBelowZero = [
            JSONSchema.ObjectContext(properties: [:], minProperties: -1)
        ]

        let minHigherThanMax = [
            JSONSchema.ObjectContext(properties: [:], minProperties: 10),
            JSONSchema.ObjectContext(properties: [:], maxProperties: 2)
        ]

        let inconsistencies = [
            minBelowZero,
            minHigherThanMax
        ]

        // break up for type checking
        let fragmentsArray: [[JSONSchema]] = inconsistencies.map { $0.map { .object(.init(), $0) } }

        for fragments in fragmentsArray {
            XCTAssertThrowsError(try fragments.combined(resolvingAgainst: .noComponents)) { error in
                guard let error = error as? JSONSchemaResolutionError else { XCTFail("Received unexpected error"); return }
                XCTAssert(error ~= .inconsistency, "\(error) is not ~= `.inconsistency` --  \(fragments)")
            }
        }
    }
}

extension JSONSchema.CoreContext {
    internal func transformed<NewFormat: OpenAPIFormat>() -> JSONSchema.CoreContext<NewFormat> {

        return .init(
            format: NewFormat(rawValue: format.rawValue)!,
            required: required,
            nullable: nullable,
            permissions: JSONSchema.CoreContext<NewFormat>.Permissions(permissions),
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            example: example
        )
    }
}
