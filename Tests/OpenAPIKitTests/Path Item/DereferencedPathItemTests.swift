//
//  DereferencedPathItemTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class DereferencedPathItemTests: XCTestCase {
    func test_noOperationsOrParameters() throws {
        let t1 = try OpenAPI.PathItem(
            summary: "test"
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.endpoints, [])
        XCTAssertEqual(t1.parameters, [])
        XCTAssertNil(t1[.delete])
        XCTAssertNil(t1[.get])
        XCTAssertNil(t1[.head])
        XCTAssertNil(t1[.options])
        XCTAssertNil(t1[.patch])
        XCTAssertNil(t1[.post])
        XCTAssertNil(t1[.put])
        XCTAssertNil(t1[.trace])

        // test dynamic member lookup
        XCTAssertEqual(t1.summary, "test")
    }

    func test_inlinedOperationsAndParameters() throws {
        let t1 = try OpenAPI.PathItem(
            parameters: [
                .parameter(name: "param", context: .header, schema: .string)
            ],
            get: .init(tags: "get op", responses: [:]),
            put: .init(tags: "put op", responses: [:]),
            post: .init(tags: "post op", responses: [:]),
            delete: .init(tags: "delete op", responses: [:]),
            options: .init(tags: "options op", responses: [:]),
            head: .init(tags: "head op", responses: [:]),
            patch: .init(tags: "patch op", responses: [:]),
            trace: .init(tags: "trace op", responses: [:])
        ).dereferenced(in: .noComponents)

        XCTAssertEqual(t1.endpoints.count, 8)
        XCTAssertEqual(t1.parameters.map { $0.schemaOrContent.schemaValue?.jsonSchema }, [.string])
        XCTAssertEqual(t1[.delete]?.tags, ["delete op"])
        XCTAssertEqual(t1[.get]?.tags, ["get op"])
        XCTAssertEqual(t1[.head]?.tags, ["head op"])
        XCTAssertEqual(t1[.options]?.tags, ["options op"])
        XCTAssertEqual(t1[.patch]?.tags, ["patch op"])
        XCTAssertEqual(t1[.post]?.tags, ["post op"])
        XCTAssertEqual(t1[.put]?.tags, ["put op"])
        XCTAssertEqual(t1[.trace]?.tags, ["trace op"])
    }

    func test_referencedParameter() throws {
        let components = OpenAPI.Components(
            parameters: [
                "test": .init(name: "param", context: .header, schema: .string)
            ]
        )
        let t1 = try OpenAPI.PathItem(
            parameters: [
                .reference(.component(named: "test"))
            ]
        ).dereferenced(in: components)

        XCTAssertEqual(
            t1.parameters.map { $0.schemaOrContent.schemaValue?.jsonSchema },
            [.string]
        )
        XCTAssertEqual(
           t1.parameters.map { $0.vendorExtensions },
           [ ["x-component-name": "test"] ]
        )
    }

    func test_missingReferencedParameter() {
        let components = OpenAPI.Components(
            parameters: [:]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                parameters: [
                    .reference(.component(named: "test"))
                ]
            ).dereferenced(in: components)
        )
    }

    func test_referencedOperations() throws {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        let t1 = try OpenAPI.PathItem(
            get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
            put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
            post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
            delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
            options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
            head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
            patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
            trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
        ).dereferenced(in: components)

        XCTAssertEqual(t1.endpoints.count, 8)
        XCTAssertEqual(t1[.delete]?.tags, ["delete op"])
        XCTAssertEqual(t1[.delete]?.responses[status: 200]?.description, "delete resp")
        XCTAssertEqual(t1[.get]?.tags, ["get op"])
        XCTAssertEqual(t1[.get]?.responses[status: 200]?.description, "get resp")
        XCTAssertEqual(t1[.head]?.tags, ["head op"])
        XCTAssertEqual(t1[.head]?.responses[status: 200]?.description, "head resp")
        XCTAssertEqual(t1[.options]?.tags, ["options op"])
        XCTAssertEqual(t1[.options]?.responses[status: 200]?.description, "options resp")
        XCTAssertEqual(t1[.patch]?.tags, ["patch op"])
        XCTAssertEqual(t1[.patch]?.responses[status: 200]?.description, "patch resp")
        XCTAssertEqual(t1[.post]?.tags, ["post op"])
        XCTAssertEqual(t1[.post]?.responses[status: 200]?.description, "post resp")
        XCTAssertEqual(t1[.put]?.tags, ["put op"])
        XCTAssertEqual(t1[.put]?.responses[status: 200]?.description, "put resp")
        XCTAssertEqual(t1[.trace]?.tags, ["trace op"])
        XCTAssertEqual(t1[.trace]?.responses[status: 200]?.description, "trace resp")
    }

    func test_missingReferencedGetResp() {
        let components = OpenAPI.Components(
            responses: [
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedPutResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedPostResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedDeleteResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedOptionsResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedHeadResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "patch": .init(description: "patch resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedPatchResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "trace": .init(description: "trace resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }

    func test_missingReferencedTraceResp() {
        let components = OpenAPI.Components(
            responses: [
                "get": .init(description: "get resp"),
                "put": .init(description: "put resp"),
                "post": .init(description: "post resp"),
                "delete": .init(description: "delete resp"),
                "options": .init(description: "options resp"),
                "head": .init(description: "head resp"),
                "patch": .init(description: "patch resp")
            ]
        )
        XCTAssertThrowsError(
            try OpenAPI.PathItem(
                get: .init(tags: "get op", responses: [200: .reference(.component(named: "get"))]),
                put: .init(tags: "put op", responses: [200: .reference(.component(named: "put"))]),
                post: .init(tags: "post op", responses: [200: .reference(.component(named: "post"))]),
                delete: .init(tags: "delete op", responses: [200: .reference(.component(named: "delete"))]),
                options: .init(tags: "options op", responses: [200: .reference(.component(named: "options"))]),
                head: .init(tags: "head op", responses: [200: .reference(.component(named: "head"))]),
                patch: .init(tags: "patch op", responses: [200: .reference(.component(named: "patch"))]),
                trace: .init(tags: "trace op", responses: [200: .reference(.component(named: "trace"))])
            ).dereferenced(in: components)
        )
    }
}
