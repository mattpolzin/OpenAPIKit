//
//  DereferencedSchemaObjectTests.swift
//  
//
//  Created by Mathew Polzin on 6/21/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class DereferencedSchemaObjectTests: XCTestCase {
    func test_optionalBasicConstructionsFromSchemaObject() {
        let t1 = JSONSchema.boolean.dereferenced()
        XCTAssertEqual(t1, .boolean(.init()))
        XCTAssertTrue(t1?.required ?? false)

        let t2 = JSONSchema.boolean(required: false).dereferenced()
        XCTAssertEqual(t2, .boolean(.init(required: false)))
        XCTAssertFalse(t2?.required ?? true)

        let t3 = JSONSchema.object.dereferenced()
        XCTAssertEqual(
            t3,
            .object(
                .init(),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                )!
            )
        )
        XCTAssertEqual(t3?.generalContext as? JSONSchema.Context<JSONTypeFormat.ObjectFormat>, JSONSchema.Context<JSONTypeFormat.ObjectFormat>())

        let t4 = JSONSchema.object(required: false).dereferenced()
        XCTAssertEqual(
            t4,
            .object(
                .init(required: false),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                    )!
            )
        )
        XCTAssertEqual(t4?.generalContext as? JSONSchema.Context<JSONTypeFormat.ObjectFormat>, JSONSchema.Context<JSONTypeFormat.ObjectFormat>(required: false))
        XCTAssertEqual(t4?.objectContext, DereferencedJSONSchema.ObjectContext(.init(properties: [:]))!)
        XCTAssertNil(t4?.arrayContext)

        let t5 = JSONSchema.array.dereferenced()
        XCTAssertEqual(
            t5,
            .array(
                .init(),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                )!
            )
        )
        XCTAssertEqual(t5?.generalContext as? JSONSchema.Context<JSONTypeFormat.ArrayFormat>, JSONSchema.Context<JSONTypeFormat.ArrayFormat>())

        let t6 = JSONSchema.array(required: false).dereferenced()
        XCTAssertEqual(
            t6,
            .array(
                .init(required: false),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                    )!
            )
        )
        XCTAssertEqual(t6?.generalContext as? JSONSchema.Context<JSONTypeFormat.ArrayFormat>, JSONSchema.Context<JSONTypeFormat.ArrayFormat>(required: false))
        XCTAssertEqual(t6?.arrayContext, DereferencedJSONSchema.ArrayContext(.init())!)
        XCTAssertNil(t6?.objectContext)

        let t7 = JSONSchema.number.dereferenced()
        XCTAssertEqual(t7, .number(.init(), .init()))
        XCTAssertEqual(t7?.generalContext as? JSONSchema.Context<JSONTypeFormat.NumberFormat>, JSONSchema.Context<JSONTypeFormat.NumberFormat>())

        let t8 = JSONSchema.number(required: false).dereferenced()
        XCTAssertEqual(t8, .number(.init(required: false), .init()))
        XCTAssertEqual(t8?.generalContext as? JSONSchema.Context<JSONTypeFormat.NumberFormat>, JSONSchema.Context<JSONTypeFormat.NumberFormat>(required: false))

        let t9 = JSONSchema.number(required: false, minimum: (10.5, exclusive: false)).dereferenced()
        XCTAssertEqual(t9, .number(.init(required: false), .init(minimum: (10.5, exclusive: false))))

        let t10 = JSONSchema.integer.dereferenced()
        XCTAssertEqual(t10, .integer(.init(), .init()))
        XCTAssertEqual(t10?.generalContext as? JSONSchema.Context<JSONTypeFormat.IntegerFormat>, JSONSchema.Context<JSONTypeFormat.IntegerFormat>())

        let t11 = JSONSchema.integer(required: false).dereferenced()
        XCTAssertEqual(t11, .integer(.init(required: false), .init()))
        XCTAssertEqual(t11?.generalContext as? JSONSchema.Context<JSONTypeFormat.IntegerFormat>, JSONSchema.Context<JSONTypeFormat.IntegerFormat>(required: false))

        let t12 = JSONSchema.integer(required: false, minimum: (10, exclusive: false)).dereferenced()
        XCTAssertEqual(t12, .integer(.init(required: false), .init(minimum: (10, exclusive: false))))

        let t13 = JSONSchema.string.dereferenced()
        XCTAssertEqual(t13, .string(.init(), .init()))
        XCTAssertEqual(t13?.generalContext as? JSONSchema.Context<JSONTypeFormat.StringFormat>, JSONSchema.Context<JSONTypeFormat.StringFormat>())

        let t14 = JSONSchema.string(required: false).dereferenced()
        XCTAssertEqual(t14, .string(.init(required: false), .init()))
        XCTAssertEqual(t14?.generalContext as? JSONSchema.Context<JSONTypeFormat.StringFormat>, JSONSchema.Context<JSONTypeFormat.StringFormat>(required: false))

        let t15 = JSONSchema.string(required: false, minLength: 5).dereferenced()
        XCTAssertEqual(t15, .string(.init(required: false), .init(minLength: 5)))

        let t16 = JSONSchema.undefined(description: nil).dereferenced()
        XCTAssertEqual(t16, .undefined(description: nil))
        XCTAssertNil(t16?.generalContext)

        let t17 = JSONSchema.undefined(description: "test").dereferenced()
        XCTAssertEqual(t17, .undefined(description: "test"))

        #warning("need to test that this succeeds trivially")
//        let t18 = JSONSchema.all(of: []).dereferenced()
//        XCTAssertEqual(t18, .all(of: [], discriminator: nil))
//        XCTAssertNil(t18?.discriminator)
//        XCTAssertNil(t18?.generalContext)

        #warning("need to test that this succeeds")
//        let t19 = JSONSchema.all(of: [], discriminator: .init(propertyName: "hi")).dereferenced()
//        XCTAssertEqual(t19, .all(of: [], discriminator: .init(propertyName: "hi")))
//        XCTAssertEqual(t19?.discriminator, .init(propertyName: "hi"))
//        XCTAssertNil(t19?.generalContext)

        #warning("need to test that this succeeds")
//        let t20 = JSONSchema.all(of: [.string(.init(), .init())]).dereferenced()
//        XCTAssertEqual(t20, .all(of: [.string(.init(), .init())], discriminator: nil))
//        XCTAssertNil(t20?.generalContext)
    }

    func test_throwingBasicConstructionsFromSchemaObject() throws {
        let components = OpenAPI.Components.noComponents

        let t1 = try JSONSchema.boolean.dereferenced(in: components)
        XCTAssertEqual(t1, .boolean(.init()))

        let t2 = try JSONSchema.boolean(required: false).dereferenced(in: components)
        XCTAssertEqual(t2, .boolean(.init(required: false)))

        let t3 = try JSONSchema.object.dereferenced(in: components)
        XCTAssertEqual(
            t3,
            .object(
                .init(),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                    )!
            )
        )

        let t4 = try JSONSchema.object(required: false).dereferenced(in: components)
        XCTAssertEqual(
            t4,
            .object(
                .init(required: false),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                    )!
            )
        )

        let t5 = try JSONSchema.array.dereferenced(in: components)
        XCTAssertEqual(
            t5,
            .array(
                .init(),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                    )!
            )
        )

        let t6 = try JSONSchema.array(required: false).dereferenced(in: components)
        XCTAssertEqual(
            t6,
            .array(
                .init(required: false),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                    )!
            )
        )

        let t7 = try JSONSchema.number.dereferenced(in: components)
        XCTAssertEqual(t7, .number(.init(), .init()))

        let t8 = try JSONSchema.number(required: false).dereferenced(in: components)
        XCTAssertEqual(t8, .number(.init(required: false), .init()))

        let t9 = try JSONSchema.number(required: false, minimum: (10.5, exclusive: false)).dereferenced(in: components)
        XCTAssertEqual(t9, .number(.init(required: false), .init(minimum: (10.5, exclusive: false))))

        let t10 = try JSONSchema.integer.dereferenced(in: components)
        XCTAssertEqual(t10, .integer(.init(), .init()))

        let t11 = try JSONSchema.integer(required: false).dereferenced(in: components)
        XCTAssertEqual(t11, .integer(.init(required: false), .init()))

        let t12 = try JSONSchema.integer(required: false, minimum: (10, exclusive: false)).dereferenced(in: components)
        XCTAssertEqual(t12, .integer(.init(required: false), .init(minimum: (10, exclusive: false))))

        let t13 = try JSONSchema.string.dereferenced(in: components)
        XCTAssertEqual(t13, .string(.init(), .init()))

        let t14 = try JSONSchema.string(required: false).dereferenced(in: components)
        XCTAssertEqual(t14, .string(.init(required: false), .init()))

        let t15 = try JSONSchema.string(required: false, minLength: 5).dereferenced(in: components)
        XCTAssertEqual(t15, .string(.init(required: false), .init(minLength: 5)))

        let t16 = try JSONSchema.undefined(description: nil).dereferenced(in: components)
        XCTAssertEqual(t16, .undefined(description: nil))

        let t17 = try JSONSchema.undefined(description: "test").dereferenced(in: components)
        XCTAssertEqual(t17, .undefined(description: "test"))

        #warning("need to test that this succeeds")
//        let t18 = try JSONSchema.all(of: []).dereferenced(in: components)
//        XCTAssertEqual(t18, .all(of: [], discriminator: nil))

        #warning("need to test that this succeeds")
//        let t19 = try JSONSchema.all(of: [], discriminator: .init(propertyName: "hi")).dereferenced(in: components)
//        XCTAssertEqual(t19, .all(of: [], discriminator: .init(propertyName: "hi")))

        #warning("need to test that this succeeds")
//        let t20 = try JSONSchema.all(of: [.string(.init(), .init())]).dereferenced(in: components)
//        XCTAssertEqual(t20, .all(of: [.string(.init(), .init())], discriminator: nil))
    }

    func test_optionalReferenceMissing() {
        let t21 = JSONSchema.reference(.component(named: "test")).dereferenced()
        XCTAssertNil(t21)
    }

    func test_throwingReferenceMissing() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(try JSONSchema.reference(.component(named: "test")).dereferenced(in: components))
    }

    func test_throwingReferenceFound() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .string]
        )
        let t1 = try JSONSchema.reference(.component(named: "test")).dereferenced(in: components)
        XCTAssertEqual(t1, .string(.init(), .init()))
    }

    func test_optionalObjectWithoutReferences() {
        let t1 = JSONSchema.object(properties: ["test": .string]).dereferenced()
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
        )
    }

    func test_throwingObjectWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.object(properties: ["test": .string]).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
        )
        XCTAssertEqual(t1.objectContext, DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
    }

    func test_optionalObjectWithReferences() {
        XCTAssertNil(JSONSchema.object(properties: ["test": .reference(.component(named: "test"))]).dereferenced())
    }

    func test_throwingObjectWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.object(properties: ["test": .reference(.component(named: "test"))]).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .boolean]))!)
        )
        XCTAssertThrowsError(try JSONSchema.object(properties: ["missing": .reference(.component(named: "missing"))]).dereferenced(in: components))
    }

    func test_optionalArrayWithoutReferences() {
        let t1 = JSONSchema.array(items: .boolean).dereferenced()
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items:.boolean))!)
        )
    }

    func test_throwingArrayWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.array(items: .string).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items: .string))!)
        )
        XCTAssertEqual(t1.arrayContext, DereferencedJSONSchema.ArrayContext(.init(items: .string))!)
    }

    func test_optionalArrayWithReferences() {
        XCTAssertNil(JSONSchema.array(items: .reference(.component(named: "test"))).dereferenced())
    }

    func test_throwingArrayWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.array(items: .reference(.component(named: "test"))).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items: .boolean))!)
        )
        XCTAssertThrowsError(try JSONSchema.array(items: .reference(.component(named: "missing"))).dereferenced(in: components))
    }

    func test_optionalOneOfWithoutReferences() {
        let t1 = JSONSchema.one(of: .boolean).dereferenced()
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_throwingOneOfWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.one(of: .boolean).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_optionalOneOfWithReferences() {
        XCTAssertNil(JSONSchema.one(of: .reference(.component(named: "test"))).dereferenced())
    }

    func test_throwingOneOfWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.one(of: .reference(.component(named: "test"))).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.one(of: .reference(.component(named: "missing"))).dereferenced(in: components))
    }

    func test_optionalAnyOfWithoutReferences() {
        let t1 = JSONSchema.any(of: .boolean).dereferenced()
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_throwingAnyOfWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.any(of: .boolean).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_optionalAnyOfWithReferences() {
        XCTAssertNil(JSONSchema.any(of: .reference(.component(named: "test"))).dereferenced())
    }

    func test_throwingAnyOfWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.any(of: .reference(.component(named: "test"))).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.any(of: .reference(.component(named: "missing"))).dereferenced(in: components))
    }

    func test_optionalNotWithoutReferences() {
        let t1 = JSONSchema.not(.boolean).dereferenced()
        XCTAssertEqual(t1, .not(.boolean(.init())))
    }

    func test_throwingNotWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.not(.boolean).dereferenced(in: components)
        XCTAssertEqual(t1, .not(.boolean(.init())))
    }

    func test_optionalNotWithReferences() {
        XCTAssertNil(JSONSchema.not(.reference(.component(named: "test"))).dereferenced())
    }

    func test_throwingNotWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.not(.reference(.component(named: "test"))).dereferenced(in: components)
        XCTAssertEqual(
            t1,
            .not(.boolean(.init()))
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.not(.reference(.component(named: "missing"))).dereferenced(in: components))
    }
}
