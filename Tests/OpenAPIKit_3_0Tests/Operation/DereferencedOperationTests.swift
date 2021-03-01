//
//  DereferencedOperationTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class DereferencedOperationTests: XCTestCase {
    func test_noReferencedComponents() throws {
        let t1 = try OpenAPI.Operation(tags: "test", responses: [:]).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.parameters.count, 0)
        XCTAssertNil(t1.requestBody)
        XCTAssertEqual(t1.responses.count, 0)
        XCTAssertNil(t1.security)
        XCTAssertEqual(t1.responseOutcomes.count, 0)
        // test dynamic member lookup
        XCTAssertEqual(t1.tags, ["test"])
    }

    func test_allInlinedComponents() throws {
        let t1 = try OpenAPI.Operation(
            parameters: [
                .parameter(
                    name: "test",
                    context: .header,
                    schema: .string
                )
            ],
            requestBody: OpenAPI.Request(content: [.json: .init(schema: .string)]),
            responses: [
                200: .response(description: "test")
            ]
        ).dereferenced(in: .noComponents)
        XCTAssertEqual(t1.parameters.count, 1)
        XCTAssertEqual(t1.requestBody?.underlyingRequest, OpenAPI.Request(content: [.json: .init(schema: .string)]))
        XCTAssertEqual(t1.responses.count, 1)
        XCTAssertEqual(t1.responseOutcomes.first?.response, t1.responses[status: 200])
        XCTAssertEqual(t1.responseOutcomes.first?.status, 200)
    }

    func test_parameterReference() throws {
        let components = OpenAPI.Components(
            parameters: [
                "test": .init(
                    name: "test",
                    context: .header,
                    schema: .string
                )
            ]
        )
        let t1 = try OpenAPI.Operation(
            parameters: [
                .reference(.component(named: "test"))
            ],
            responses: [:]
        ).dereferenced(in: components)
        XCTAssertEqual(
            t1.parameters.first?.underlyingParameter,
            .init(
                name: "test",
                context: .header,
                schema: .string
            )
        )
    }

    func test_parameterReferenceMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Operation(
                parameters: [
                    .reference(.component(named: "test"))
                ],
                responses: [:]
            ).dereferenced(in: .noComponents)
        )
    }

    func test_requestReference() throws {
        let components = OpenAPI.Components(
            requestBodies: [
                "test": OpenAPI.Request(content: [.json: .init(schema: .string)])
            ]
        )
        let t1 = try OpenAPI.Operation(
            requestBody: .reference(.component(named: "test")),
            responses: [
                200: .response(description: "test")
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.requestBody?.underlyingRequest, OpenAPI.Request(content: [.json: .init(schema: .string)]))
    }

    func test_requestReferenceMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Operation(
                requestBody: .reference(.component(named: "test")),
                responses: [
                    200: .response(description: "test")
                ]
            ).dereferenced(in: .noComponents)
        )
    }

    func test_responseReference() throws {
        let components = OpenAPI.Components(
            responses: [
                "test": .init(description: "test")
            ]
        )
        let t1 = try OpenAPI.Operation(
            responses: [
                200: .reference(.component(named: "test"))
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(
            t1.responses[status: 200]?.underlyingResponse,
            .init(description: "test")
        )
    }

    func test_responseReferenceMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Operation(
                responses: [
                    200: .reference(.component(named: "test"))
                ]
            ).dereferenced(in: .noComponents)
        )
    }

    func test_securityReference() throws {
        let components = OpenAPI.Components(
            securitySchemes: ["requirement": .apiKey(name: "Api-Key", location: .header)]
        )
        let t1 = try OpenAPI.Operation(
            responses: [:],
            security: [
                [.component(named: "requirement"): []]
            ]
        ).dereferenced(in: components)
        XCTAssertEqual(t1.security?.first?.schemes["requirement"]?.securityScheme, .apiKey(name: "Api-Key", location: .header))
    }

    func test_securityReferenceMissing() {
        XCTAssertThrowsError(
            try OpenAPI.Operation(
                responses: [:],
                security: [
                    [.component(named: "requirement"): []]
                ]
            ).dereferenced(in: .noComponents)
        )
    }
}
