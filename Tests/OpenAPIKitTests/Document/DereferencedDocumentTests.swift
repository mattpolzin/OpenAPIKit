//
//  DereferencedDocumentTests.swift
//  
//
//  Created by Mathew Polzin on 6/22/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class DereferencedDocumentTests: XCTestCase {
    func test_noSecurityOrPaths() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        ).locallyDereferenced()

        // test that dynamic member lookup works:
        XCTAssertEqual(t1.info, .init(title: "test", version: "1.0"))
    }

    func test_noSecurityInlinePath() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .response(description: "success")
                        ]
                    )
                )
            ],
            components: .noComponents
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        // just check that you can snag the expected resolved endpoints
        XCTAssertEqual(
            t1.resolvedEndpoints().map { $0.path },
            ["/hello/world"]
        )

        XCTAssertEqual(
            t1.resolvedEndpointsByPath().keys,
            ["/hello/world"]
        )
    }

    func test_noSecurityReferencedResponseInPath() throws {
        let components = OpenAPI.Components(
            responses: [
                "test": .init(description: "success")
            ]
        )
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .reference(.component(named: "test"))
                        ]
                    )
                )
            ],
            components: components
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        XCTAssertEqual(t1.routes.first?.path, "/hello/world")
        XCTAssertNotNil(t1.routes.first?.pathItem.get)
    }

    func test_securityAndReferencedResponseInPath() throws {
        let components = OpenAPI.Components(
            responses: [
                "test": .init(description: "success")
            ],
            securitySchemes: [
                "test": .apiKey(name: "Api-Key", location: .header)
            ]
        )
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://website.com")!)],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .reference(.component(named: "test"))
                        ]
                    )
                )
            ],
            components: components,
            security: [[.component(named: "test"): []]]
        ).locallyDereferenced()

        XCTAssertEqual(t1.paths.count, 1)
        XCTAssertEqual(t1.paths["/hello/world"]?.get?.responses[status: 200]?.description, "success")

        XCTAssertEqual(t1.security.count, 1)
        XCTAssertEqual(t1.security.first?.schemes["test"]?.securityScheme.type, .apiKey(name: "Api-Key", location: .header))
    }
}
