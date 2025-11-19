//
//  ResolvedDocumentTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit

final class ResolvedDocumentTests: XCTestCase {
    func test_documentWithNoRoutesOrSecurity() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [:],
            components: .noComponents
        )
        .locallyDereferenced()
        .resolved()

        XCTAssertEqual(t1.routes.count, 0)
        XCTAssertEqual(t1.endpoints.count, 0)
        XCTAssertEqual(t1.paths.count, 0)
        XCTAssertEqual(t1.security.count, 0)

        // test dynamic member lookup
        XCTAssertEqual(t1.allServers, [.init(url: URL(string: "http://website.com")!)])
    }

    func test_documentWithSecurity() throws {
        let components = OpenAPI.Components.direct(
            securitySchemes: [
                "test": .apiKey(name: "api-key", location: .cookie)
            ]
        )
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: components,
            security: [
                [.component(named: "test"): []]
            ]
        )
        .locallyDereferenced()
        .resolved()

        XCTAssertEqual(t1.security.count, 1)
        XCTAssertEqual(t1.security[0].schemes["test"]?.name, "test")
        XCTAssertEqual(t1.security[0].schemes["test"]?.securityScheme, .apiKey(name: "api-key", location: .cookie))
    }

    func test_documentWithOneRouteWithMultipleEndpoints() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    description: "test",
                    get: .init(tags: "hello", summary: "Get world", responses: [:]),
                    post: .init(tags: "hello", summary: "Create world", responses: [:])
                )
            ],
            components: .noComponents
        )
        .locallyDereferenced()
        .resolved()

        XCTAssertEqual(t1.routes.count, 1)
        XCTAssertEqual(t1.routesByPath["/hello/world"]?.endpoints.count, 2)
        XCTAssertEqual(t1.routesByPath["/hello/world"]?.description, "test")

        XCTAssertEqual(t1.endpoints.count, 2)
        XCTAssertEqual(t1.endpoints, t1.routes.flatMap { $0.endpoints })
        XCTAssert(t1.routesByPath["/hello/world"]!.endpoints.contains { $0.endpointSummary == "Get world" })
        XCTAssert(t1.routesByPath["/hello/world"]!.endpoints.contains { $0.endpointSummary == "Create world" })

        XCTAssertEqual(t1.paths["/hello/world"]?.get?.summary, "Get world")
        XCTAssertEqual(t1.paths["/hello/world"]?.post?.summary, "Create world")
    }

    public func test_documentWithTwoRoutesEachWithTwoEndpoints() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    description: "test 1",
                    get: .init(tags: "world", summary: "Get world", responses: [:]),
                    post: .init(tags: "world", summary: "Create world", responses: [:])
                ),
                "/hello/universe": .init(
                    description: "test 2",
                    get: .init(tags: "universe", summary: "Get universe", responses: [:]),
                    post: .init(tags: "universe", summary: "Create universe", responses: [:])
                ),
            ],
            components: .noComponents
        )
            .locallyDereferenced()
            .resolved()

        XCTAssertEqual(t1.routes.count, 2)
        XCTAssertEqual(t1.routesByPath["/hello/world"]?.endpoints.count, 2)
        XCTAssertEqual(t1.routesByPath["/hello/world"]?.description, "test 1")
        XCTAssertEqual(t1.routesByPath["/hello/universe"]?.endpoints.count, 2)
        XCTAssertEqual(t1.routesByPath["/hello/universe"]?.description, "test 2")

        XCTAssertEqual(t1.endpoints.count, 4)
        XCTAssertEqual(t1.endpoints, t1.routes.flatMap { $0.endpoints })
        XCTAssert(t1.routesByPath["/hello/world"]!.endpoints.contains { $0.endpointSummary == "Get world" })
        XCTAssert(t1.routesByPath["/hello/world"]!.endpoints.contains { $0.endpointSummary == "Create world" })

        XCTAssertEqual(t1.paths["/hello/world"]?.get?.summary, "Get world")
        XCTAssertEqual(t1.paths["/hello/world"]?.post?.summary, "Create world")

        XCTAssert(t1.routesByPath["/hello/universe"]!.endpoints.contains { $0.endpointSummary == "Get universe" })
        XCTAssert(t1.routesByPath["/hello/universe"]!.endpoints.contains { $0.endpointSummary == "Create universe" })

        XCTAssertEqual(t1.paths["/hello/universe"]?.get?.summary, "Get universe")
        XCTAssertEqual(t1.paths["/hello/universe"]?.post?.summary, "Create universe")

        XCTAssertEqual(t1.allTags, ["world", "universe"])
    }
}
