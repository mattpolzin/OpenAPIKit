//
//  ResolvedRouteTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class ResolvedRouteTests: XCTestCase {
    func test_takesOnPathProperties() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world/{id}": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [],
                    parameters: [.parameter(name: "id", context: .path, schema: .integer)],
                    get: .init(
                        summary: "get",
                        responses: [200: .response(description: "hello world")]
                    ),
                    put: .init(
                        summary: "put",
                        responses: [200: .response(description: "hello world")]
                    ),
                    post: .init(
                        summary: "post",
                        responses: [200: .response(description: "hello world")]
                    ),
                    delete: .init(
                        summary: "delete",
                        responses: [200: .response(description: "hello world")]
                    ),
                    options: .init(
                        summary: "options",
                        responses: [200: .response(description: "hello world")]
                    ),
                    head: .init(
                        summary: "head",
                        responses: [200: .response(description: "hello world")]
                    ),
                    patch: .init(
                        summary: "patch",
                        responses: [200: .response(description: "hello world")]
                    ),
                    trace: .init(
                        summary: "trace",
                        responses: [200: .response(description: "hello world")]
                    ),
                    vendorExtensions: [
                        "test": "route"
                    ]
                )
            ],
            components: .noComponents
        )
        .locallyDereferenced()
        .resolved()

        let routes = t1.routes

        XCTAssertEqual(routes.first?.summary, "routeSummary")
        XCTAssertEqual(routes.first?.description, "routeDescription")
        XCTAssertEqual(routes.first?.vendorExtensions["test"], "route")
        XCTAssertEqual(routes.first?.path, "/hello/world/{id}")
        XCTAssertEqual(routes.first?.parameters.map { $0.name }, ["id"])
        XCTAssertEqual(routes.first?.get?.endpointSummary, "get")
        XCTAssertEqual(routes.first?.put?.endpointSummary, "put")
        XCTAssertEqual(routes.first?.post?.endpointSummary, "post")
        XCTAssertEqual(routes.first?.delete?.endpointSummary, "delete")
        XCTAssertEqual(routes.first?.options?.endpointSummary, "options")
        XCTAssertEqual(routes.first?.head?.endpointSummary, "head")
        XCTAssertEqual(routes.first?.patch?.endpointSummary, "patch")
        XCTAssertEqual(routes.first?.trace?.endpointSummary, "trace")

        XCTAssertEqual(routes.first?.endpoints.count, 8)

        XCTAssertEqual(routes.first?.get, routes.first?[.get])
        XCTAssertEqual(routes.first?.put, routes.first?[.put])
        XCTAssertEqual(routes.first?.post, routes.first?[.post])
        XCTAssertEqual(routes.first?.delete, routes.first?[.delete])
        XCTAssertEqual(routes.first?.options, routes.first?[.options])
        XCTAssertEqual(routes.first?.head, routes.first?[.head])
        XCTAssertEqual(routes.first?.patch, routes.first?[.patch])
        XCTAssertEqual(routes.first?.trace, routes.first?[.trace])
    }

    func test_pathServersTakePrecedence() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world/{id}": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [.init(url: URL(string: "http://b.com")!)],
                    get: .init(
                        summary: "get",
                        responses: [200: .response(description: "hello world")]
                    )
                )
            ],
            components: .noComponents
        )
        .locallyDereferenced()
        .resolved()

        let routes = t1.routes

        XCTAssertEqual(routes.first?.servers, [.init(url: URL(string: "http://b.com")!)])
    }

    func test_emptServersOverrideDocumentServers() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world/{id}": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [],
                    get: .init(
                        summary: "get",
                        responses: [200: .response(description: "hello world")]
                    )
                )
            ],
            components: .noComponents
        )
            .locallyDereferenced()
            .resolved()

        let routes = t1.routes

        XCTAssertEqual(routes.first?.servers, [])
    }

    func test_fallsBackToDocumentServers() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world/{id}": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    get: .init(
                        summary: "get",
                        responses: [200: .response(description: "hello world")]
                    )
                )
            ],
            components: .noComponents
        )
            .locallyDereferenced()
            .resolved()

        let routes = t1.routes

        XCTAssertEqual(routes.first?.servers, [.init(url: URL(string: "http://a.com")!)])
    }
}

