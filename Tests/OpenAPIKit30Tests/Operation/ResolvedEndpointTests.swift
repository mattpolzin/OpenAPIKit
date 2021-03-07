//
//  ResolvedEndpointTests.swift
//  
//
//  Created by Mathew Polzin on 6/23/20.
//

import XCTest
import OpenAPIKit30

final class ResolvedEndpointTests: XCTestCase {
    func test_takesOnPathAndOperationProperties() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [],
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.routeSummary, "routeSummary")
        XCTAssertEqual(endpoints.first?.routeDescription, "routeDescription")
        XCTAssertEqual(endpoints.first?.routeVendorExtensions["test"]?.value as? String, "route")
        XCTAssertEqual(endpoints.first?.tags, ["a", "b"])
        XCTAssertEqual(endpoints.first?.endpointSummary, "endpointSummary")
        XCTAssertEqual(endpoints.first?.endpointDescription, "endpointDescription")
        XCTAssertEqual(endpoints.first?.endpointVendorExtensions["test"]?.value as? String, "endpoint")
        XCTAssertEqual(endpoints.first?.operationId, "hi there")
        XCTAssertEqual(endpoints.first?.externalDocs, .init(url: URL(string: "http://website.com")!))
        XCTAssertEqual(endpoints.first?.method, .get)
        XCTAssertEqual(endpoints.first?.path, "/hello/world")
        XCTAssertEqual(endpoints.first?.requestBody?.description, "requestBody")
        XCTAssertEqual(endpoints.first?.responses[status: 200]?.description, "hello world")
        XCTAssertEqual(endpoints.first?.deprecated, true)

        let t2 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [200: .response(description: "hello world")]
                    )
                )
            ],
            components: .noComponents
        )
        .locallyDereferenced()
        .resolved()

        let endpoints2 = t2.endpoints

        XCTAssertEqual(endpoints2.first?.tags, [])
    }

    func test_operationServersTakePrecedenceOverAll() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [.init(url: URL(string: "http://b.com")!)],
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        servers: [.init(url: URL(string: "http://c.com")!)],
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.servers, [.init(url: URL(string: "http://c.com")!)])
    }

    func test_pathServersTakePrecedenceOverDocument() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    servers: [.init(url: URL(string: "http://b.com")!)],
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.servers, [.init(url: URL(string: "http://b.com")!)])
    }

    func test_documentServersAreAdopted() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [.init(url: URL(string: "http://a.com")!)],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.servers, [.init(url: URL(string: "http://a.com")!)])
    }

    func test_pathAndOperationParametersAdd() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [.parameter(name: "one", context: .header, schema: .string)],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [.parameter(name: "two", context: .query, schema: .string)],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.parameters.map { $0.name }, ["two", "one"])
    }

    func test_operationParametersTakePrecedence() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [.parameter(name: "one", context: .header, schema: .string)],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [.parameter(name: "one", context: .header, schema: .integer)],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.parameters.first?.underlyingParameter.schemaOrContent.schemaValue, .integer)
    }

    func test_operationSecurityTakesPrecedence() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        security: [[ .component(named: "secure2"): []]],
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
                    ),
                    vendorExtensions: [
                        "test": "route"
                    ]
                )
            ],
            components: .init(
                securitySchemes: [
                    "secure1": .apiKey(name: "hi", location: .cookie),
                    "secure2": .oauth2(
                        flows: .init(
                            implicit: .init(
                                authorizationUrl: URL(
                                    string: "https://website.com")!,
                                scopes: [
                                    "write": "write scope"
                                ]
                            )
                        )
                    )
                ]
            ),
            security: [[ .component(named: "secure1"): []]]
        )
        .locallyDereferenced()
        .resolved()

        let endpoints = t1.endpoints

        XCTAssertNotNil(endpoints.first?.security.first?.schemes["secure2"])
    }

    func test_emptyOperationSecurityOverridesDocumentSecurity() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        security: [],
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
                    ),
                    vendorExtensions: [
                        "test": "route"
                    ]
                )
            ],
            components: .init(
                securitySchemes: [
                    "secure1": .apiKey(name: "hi", location: .cookie),
                    "secure2": .oauth2(
                        flows: .init(
                            implicit: .init(
                                authorizationUrl: URL(
                                    string: "https://website.com")!,
                                scopes: [
                                    "write": "write scope"
                                ]
                            )
                        )
                    )
                ]
            ),
            security: [[ .component(named: "secure1"): []]]
        )
        .locallyDereferenced()
        .resolved()

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.security, [])
    }

    func test_documentSecurityIsAdopted() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
                    ),
                    vendorExtensions: [
                        "test": "route"
                    ]
                )
            ],
            components: .init(
                securitySchemes: [
                    "secure1": .apiKey(name: "hi", location: .cookie),
                    "secure2": .oauth2(
                        flows: .init(
                            implicit: .init(
                                authorizationUrl: URL(
                                    string: "https://website.com")!,
                                scopes: [
                                    "write": "write scope"
                                ]
                            )
                        )
                    )
                ]
            ),
            security: [[ .component(named: "secure1"): []]]
        )
        .locallyDereferenced()
        .resolved()

        let endpoints = t1.endpoints

        XCTAssertNotNil(endpoints.first?.security.first?.schemes["secure1"])
    }

    func test_requiredAndOptionalParameters() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [.parameter(name: "one", context: .header(required: true), schema: .string)],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [.parameter(name: "two", context: .query, schema: .string)],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [200: .response(description: "hello world")],
                        deprecated: true,
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
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

        let endpoints = t1.endpoints

        XCTAssertEqual(endpoints.first?.parameters.count, 2)
        XCTAssertEqual(endpoints.first?.requiredParameters.first?.name, "one")
        XCTAssertEqual(endpoints.first?.optionalParameters.first?.name, "two")
    }

    func test_responseOutcomes() throws {
        let t1 = try OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    summary: "routeSummary",
                    description: "routeDescription",
                    parameters: [],
                    get: .init(
                        tags: "a", "b",
                        summary: "endpointSummary",
                        description: "endpointDescription",
                        externalDocs: .init(url: URL(string: "http://website.com")!),
                        operationId: "hi there",
                        parameters: [],
                        requestBody: .init(description: "requestBody", content: [:]),
                        responses: [
                            200: .response(description: "hello world"),
                            404: .response(description: "missing"),
                            500: .response(description: "uh-oh")
                        ],
                        deprecated: true,
                        security: [[ .component(named: "secure2"): []]],
                        vendorExtensions: [
                            "test": "endpoint"
                        ]
                    ),
                    vendorExtensions: [
                        "test": "route"
                    ]
                )
            ],
            components: .init(
                securitySchemes: [
                    "secure1": .apiKey(name: "hi", location: .cookie),
                    "secure2": .oauth2(
                        flows: .init(
                            implicit: .init(
                                authorizationUrl: URL(
                                    string: "https://website.com")!,
                                scopes: [
                                    "write": "write scope"
                                ]
                            )
                        )
                    )
                ]
            ),
            security: [[ .component(named: "secure1"): []]]
        )
        .locallyDereferenced()
        .resolved()

        XCTAssertEqual(
            t1.endpoints.first?.responseOutcomes.map { $0.status },
            [
                200,
                404,
                500
            ]
        )
        XCTAssertEqual(
            t1.endpoints.first?.responseOutcomes.map { $0.response.description },
            [
                "hello world",
                "missing",
                "uh-oh"
            ]
        )
    }
}

