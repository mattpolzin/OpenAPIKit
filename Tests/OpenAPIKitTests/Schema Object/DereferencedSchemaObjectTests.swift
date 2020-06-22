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
        let t1 = JSONSchema.boolean.dereferencedSchemaObject()
        XCTAssertEqual(t1, .boolean(.init()))
        XCTAssertTrue(t1?.required ?? false)

        let t2 = JSONSchema.boolean(required: false).dereferencedSchemaObject()
        XCTAssertEqual(t2, .boolean(.init(required: false)))
        XCTAssertFalse(t2?.required ?? true)

        let t3 = JSONSchema.object.dereferencedSchemaObject()
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

        let t4 = JSONSchema.object(required: false).dereferencedSchemaObject()
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

        let t5 = JSONSchema.array.dereferencedSchemaObject()
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

        let t6 = JSONSchema.array(required: false).dereferencedSchemaObject()
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

        let t7 = JSONSchema.number.dereferencedSchemaObject()
        XCTAssertEqual(t7, .number(.init(), .init()))
        XCTAssertEqual(t7?.generalContext as? JSONSchema.Context<JSONTypeFormat.NumberFormat>, JSONSchema.Context<JSONTypeFormat.NumberFormat>())

        let t8 = JSONSchema.number(required: false).dereferencedSchemaObject()
        XCTAssertEqual(t8, .number(.init(required: false), .init()))
        XCTAssertEqual(t8?.generalContext as? JSONSchema.Context<JSONTypeFormat.NumberFormat>, JSONSchema.Context<JSONTypeFormat.NumberFormat>(required: false))

        let t9 = JSONSchema.number(required: false, minimum: (10.5, exclusive: false)).dereferencedSchemaObject()
        XCTAssertEqual(t9, .number(.init(required: false), .init(minimum: (10.5, exclusive: false))))

        let t10 = JSONSchema.integer.dereferencedSchemaObject()
        XCTAssertEqual(t10, .integer(.init(), .init()))
        XCTAssertEqual(t10?.generalContext as? JSONSchema.Context<JSONTypeFormat.IntegerFormat>, JSONSchema.Context<JSONTypeFormat.IntegerFormat>())

        let t11 = JSONSchema.integer(required: false).dereferencedSchemaObject()
        XCTAssertEqual(t11, .integer(.init(required: false), .init()))
        XCTAssertEqual(t11?.generalContext as? JSONSchema.Context<JSONTypeFormat.IntegerFormat>, JSONSchema.Context<JSONTypeFormat.IntegerFormat>(required: false))

        let t12 = JSONSchema.integer(required: false, minimum: (10, exclusive: false)).dereferencedSchemaObject()
        XCTAssertEqual(t12, .integer(.init(required: false), .init(minimum: (10, exclusive: false))))

        let t13 = JSONSchema.string.dereferencedSchemaObject()
        XCTAssertEqual(t13, .string(.init(), .init()))
        XCTAssertEqual(t13?.generalContext as? JSONSchema.Context<JSONTypeFormat.StringFormat>, JSONSchema.Context<JSONTypeFormat.StringFormat>())

        let t14 = JSONSchema.string(required: false).dereferencedSchemaObject()
        XCTAssertEqual(t14, .string(.init(required: false), .init()))
        XCTAssertEqual(t14?.generalContext as? JSONSchema.Context<JSONTypeFormat.StringFormat>, JSONSchema.Context<JSONTypeFormat.StringFormat>(required: false))

        let t15 = JSONSchema.string(required: false, minLength: 5).dereferencedSchemaObject()
        XCTAssertEqual(t15, .string(.init(required: false), .init(minLength: 5)))

        let t16 = JSONSchema.undefined(description: nil).dereferencedSchemaObject()
        XCTAssertEqual(t16, .undefined(description: nil))
        XCTAssertNil(t16?.generalContext)

        let t17 = JSONSchema.undefined(description: "test").dereferencedSchemaObject()
        XCTAssertEqual(t17, .undefined(description: "test"))

        let t18 = JSONSchema.all(of: []).dereferencedSchemaObject()
        XCTAssertEqual(t18, .all(of: [], discriminator: nil))
        XCTAssertNil(t18?.discriminator)
        XCTAssertNil(t18?.generalContext)

        let t19 = JSONSchema.all(of: [], discriminator: .init(propertyName: "hi")).dereferencedSchemaObject()
        XCTAssertEqual(t19, .all(of: [], discriminator: .init(propertyName: "hi")))
        XCTAssertEqual(t19?.discriminator, .init(propertyName: "hi"))
        XCTAssertNil(t19?.generalContext)

        let t20 = JSONSchema.all(of: [.string(.init(), .init())]).dereferencedSchemaObject()
        XCTAssertEqual(t20, .all(of: [.string(.init(), .init())], discriminator: nil))
        XCTAssertNil(t20?.generalContext)
    }

    func test_throwingBasicConstructionsFromSchemaObject() throws {
        let components = OpenAPI.Components.noComponents

        let t1 = try JSONSchema.boolean.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t1, .boolean(.init()))

        let t2 = try JSONSchema.boolean(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t2, .boolean(.init(required: false)))

        let t3 = try JSONSchema.object.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t3,
            .object(
                .init(),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                    )!
            )
        )

        let t4 = try JSONSchema.object(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t4,
            .object(
                .init(required: false),
                DereferencedJSONSchema.ObjectContext(
                    JSONSchema.ObjectContext(properties: [:])
                    )!
            )
        )

        let t5 = try JSONSchema.array.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t5,
            .array(
                .init(),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                    )!
            )
        )

        let t6 = try JSONSchema.array(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t6,
            .array(
                .init(required: false),
                DereferencedJSONSchema.ArrayContext(
                    JSONSchema.ArrayContext()
                    )!
            )
        )

        let t7 = try JSONSchema.number.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t7, .number(.init(), .init()))

        let t8 = try JSONSchema.number(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t8, .number(.init(required: false), .init()))

        let t9 = try JSONSchema.number(required: false, minimum: (10.5, exclusive: false)).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t9, .number(.init(required: false), .init(minimum: (10.5, exclusive: false))))

        let t10 = try JSONSchema.integer.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t10, .integer(.init(), .init()))

        let t11 = try JSONSchema.integer(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t11, .integer(.init(required: false), .init()))

        let t12 = try JSONSchema.integer(required: false, minimum: (10, exclusive: false)).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t12, .integer(.init(required: false), .init(minimum: (10, exclusive: false))))

        let t13 = try JSONSchema.string.dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t13, .string(.init(), .init()))

        let t14 = try JSONSchema.string(required: false).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t14, .string(.init(required: false), .init()))

        let t15 = try JSONSchema.string(required: false, minLength: 5).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t15, .string(.init(required: false), .init(minLength: 5)))

        let t16 = try JSONSchema.undefined(description: nil).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t16, .undefined(description: nil))

        let t17 = try JSONSchema.undefined(description: "test").dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t17, .undefined(description: "test"))

        let t18 = try JSONSchema.all(of: []).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t18, .all(of: [], discriminator: nil))

        let t19 = try JSONSchema.all(of: [], discriminator: .init(propertyName: "hi")).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t19, .all(of: [], discriminator: .init(propertyName: "hi")))

        let t20 = try JSONSchema.all(of: [.string(.init(), .init())]).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t20, .all(of: [.string(.init(), .init())], discriminator: nil))
    }

    func test_optionalReferenceMissing() {
        let t21 = JSONSchema.reference(.component(named: "test")).dereferencedSchemaObject()
        XCTAssertNil(t21)
    }

    func test_throwingReferenceMissing() {
        let components = OpenAPI.Components.noComponents
        XCTAssertThrowsError(try JSONSchema.reference(.component(named: "test")).dereferencedSchemaObject(resolvingIn: components))
    }

    func test_throwingReferenceFound() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .string]
        )
        let t1 = try JSONSchema.reference(.component(named: "test")).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t1, .string(.init(), .init()))
    }

    func test_optionalObjectWithoutReferences() {
        let t1 = JSONSchema.object(properties: ["test": .string]).dereferencedSchemaObject()
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
        )
    }

    func test_throwingObjectWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.object(properties: ["test": .string]).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
        )
        XCTAssertEqual(t1.objectContext, DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .string]))!)
    }

    func test_optionalObjectWithReferences() {
        XCTAssertNil(JSONSchema.object(properties: ["test": .reference(.component(named: "test"))]).dereferencedSchemaObject())
    }

    func test_throwingObjectWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.object(properties: ["test": .reference(.component(named: "test"))]).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .object(.init(), DereferencedJSONSchema.ObjectContext(.init(properties: ["test": .boolean]))!)
        )
        XCTAssertThrowsError(try JSONSchema.object(properties: ["missing": .reference(.component(named: "missing"))]).dereferencedSchemaObject(resolvingIn: components))
    }

    func test_optionalArrayWithoutReferences() {
        let t1 = JSONSchema.array(items: .boolean).dereferencedSchemaObject()
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items:.boolean))!)
        )
    }

    func test_throwingArrayWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.array(items: .string).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items: .string))!)
        )
        XCTAssertEqual(t1.arrayContext, DereferencedJSONSchema.ArrayContext(.init(items: .string))!)
    }

    func test_optionalArrayWithReferences() {
        XCTAssertNil(JSONSchema.array(items: .reference(.component(named: "test"))).dereferencedSchemaObject())
    }

    func test_throwingArrayWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.array(items: .reference(.component(named: "test"))).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .array(.init(), DereferencedJSONSchema.ArrayContext(.init(items: .boolean))!)
        )
        XCTAssertThrowsError(try JSONSchema.array(items: .reference(.component(named: "missing"))).dereferencedSchemaObject(resolvingIn: components))
    }

    func test_optionalOneOfWithoutReferences() {
        let t1 = JSONSchema.one(of: .boolean).dereferencedSchemaObject()
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_throwingOneOfWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.one(of: .boolean).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_optionalOneOfWithReferences() {
        XCTAssertNil(JSONSchema.one(of: .reference(.component(named: "test"))).dereferencedSchemaObject())
    }

    func test_throwingOneOfWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.one(of: .reference(.component(named: "test"))).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .one(of: [.boolean(.init())], discriminator: nil)
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.one(of: .reference(.component(named: "missing"))).dereferencedSchemaObject(resolvingIn: components))
    }

    func test_optionalAnyOfWithoutReferences() {
        let t1 = JSONSchema.any(of: .boolean).dereferencedSchemaObject()
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_throwingAnyOfWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.any(of: .boolean).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
    }

    func test_optionalAnyOfWithReferences() {
        XCTAssertNil(JSONSchema.any(of: .reference(.component(named: "test"))).dereferencedSchemaObject())
    }

    func test_throwingAnyOfWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.any(of: .reference(.component(named: "test"))).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .any(of: [.boolean(.init())], discriminator: nil)
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.any(of: .reference(.component(named: "missing"))).dereferencedSchemaObject(resolvingIn: components))
    }

    func test_optionalNotWithoutReferences() {
        let t1 = JSONSchema.not(.boolean).dereferencedSchemaObject()
        XCTAssertEqual(t1, .not(.boolean(.init())))
    }

    func test_throwingNotWithoutReferences() throws {
        let components = OpenAPI.Components.noComponents
        let t1 = try JSONSchema.not(.boolean).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(t1, .not(.boolean(.init())))
    }

    func test_optionalNotWithReferences() {
        XCTAssertNil(JSONSchema.not(.reference(.component(named: "test"))).dereferencedSchemaObject())
    }

    func test_throwingNotWithReferences() throws {
        let components = OpenAPI.Components(
            schemas: ["test": .boolean]
        )
        let t1 = try JSONSchema.not(.reference(.component(named: "test"))).dereferencedSchemaObject(resolvingIn: components)
        XCTAssertEqual(
            t1,
            .not(.boolean(.init()))
        )
        XCTAssertNil(t1.generalContext)
        XCTAssertThrowsError(try JSONSchema.not(.reference(.component(named: "missing"))).dereferencedSchemaObject(resolvingIn: components))
    }
}
