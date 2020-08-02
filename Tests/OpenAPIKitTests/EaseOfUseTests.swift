//
//  DeclarativeEaseOfUseTests.swift
//  
//
//  Created by Mathew Polzin on 10/27/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class DeclarativeEaseOfUseTests: XCTestCase {
    func test_wholeBoi() {
        let _ = OpenAPI.Document(
            openAPIVersion: .v3_0_0,
            info: .init(
                title: "Test Documentation",
                description: "Description of Test Documentation",
                termsOfService: URL(string: "http://termsofservice.com")!,
                contact: .init(
                    name: "Test Documentation Owner",
                    url: URL(string: "http://testowner.com")!,
                    email: "testowner@testowner.com"
                ),
                license: .MIT,
                version: "1.0"
            ),
            servers: [
                .init(
                    url: URL(string: "http://testapi.com")!,
                    description: "Primary Test API Host",
                    variables: [:]
                )
            ],
            paths: [
                "/test/api/endpoint/{param}": .init(
                    summary: "Test Endpoint",
                    description: "Test Endpoint description",
                    parameters: [
                        .parameter(
                            name: "param",
                            context: .path,
                            schema: .string
                        )
                    ],
                    get: .init(
                        tags: "Test",
                        summary: "Get Test",
                        description: "Get Test description",
                        parameters: [
                            .reference(.component( named: "filter")),
                            .parameter(
                                name: "Content-Type",
                                context: .header(required: false),
                                schema: .string(
                                    allowedValues: [
                                        .init(OpenAPI.ContentType.json.rawValue),
                                        .init(OpenAPI.ContentType.txt.rawValue)
                                    ]
                                )
                            )
                        ],
                        responses: [
                            200: .response(
                                description: "Successful Retrieve",
                                content: [
                                    .json: .init(
                                        schema: .object(
                                            properties: [
                                                "hello": .string
                                            ]
                                        ),
                                        example: #"{ "hello": "world" }"#
                                    )
                                ]
                            )
                        ]
                    ),
                    post: .init(
                        tags: "Test",
                        summary: "Post Test",
                        description: "Post Test description",
                        parameters: [],
                        requestBody: .init(
                            content: [
                                .json: .init(
                                    schema: .object(
                                        properties: [
                                            "hello": .string
                                        ]
                                    )
                                )
                            ]
                        ),
                        responses: [
                            202: .response(
                                description: "Successful Create",
                                content: [
                                    .json: .init(
                                        schema: .object(
                                            properties: [
                                                "hello": .string
                                            ]
                                        )
                                    )
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .init(
                schemas: [
                    "string_schema": .string
                ],
                parameters: [
                    "filter": .init(
                        name: "filter",
                        context: .query(required: false),
                        schema: .init(
                            .object(
                                properties: [
                                    "size": .integer,
                                    "shape": .string(allowedValues: [ "round", "square" ])
                                ]
                            ),
                            style: .deepObject,
                            explode: true
                        )
                    )
                ]
            ),
            security: [],
            externalDocs: .init(
                description: "External Docs",
                url: URL(string: "http://externaldocs.com")!
            )
        )
    }

    func test_declarePiecemeal() {
        // probably easier to read version of whole boi with components declared as constants

        let apiInfo = OpenAPI.Document.Info(
            title: "Test Documentation",
            description: "Description of Test Documentation",
            termsOfService: URL(string: "http://termsofservice.com")!,
            contact: .init(
                name: "Test Documentation Owner",
                url: URL(string: "http://testowner.com")!,
                email: "testowner@testowner.com"
            ),
            license: .MIT,
            version: "1.0"
        )

        let server = OpenAPI.Server(
            url: URL(string: "http://testapi.com")!,
            description: "Primary Test API Host",
            variables: [:]
        )

        let testSHOW_endpoint = OpenAPI.Operation(
            tags: "Test",
            summary: "Get Test",
            description: "Get Test description",
            parameters: [
                .reference(.component( named: "filter")),
                .parameter(
                    name: "Content-Type",
                    context: .header(required: false),
                    schema: .string(
                        allowedValues: [
                            .init(OpenAPI.ContentType.json.rawValue),
                            .init(OpenAPI.ContentType.txt.rawValue)
                        ]
                    )
                )
            ],
            responses: [
                200: .response(
                    description: "Successful Retrieve",
                    content: [
                        .json: .init(
                            schema: .object(
                                properties: [
                                    "hello": .string
                                ]
                            ),
                            example: #"{ "hello": "world" }"#
                        )
                    ]
                )
            ]
        )

        let testCREATE_endpoint = OpenAPI.Operation(
            tags: "Test",
            summary: "Post Test",
            description: "Post Test description",
            parameters: [],
            requestBody: .init(
                content: [
                    .json: .init(
                        schema: .object(
                            properties: [
                                "hello": .string
                            ]
                        )
                    )
                ]
            ),
            responses: [
                202: .response(
                    description: "Successful Create",
                    content: [
                        .json: .init(
                            schema: .object(
                                properties: [
                                    "hello": .string
                                ]
                            )
                        )
                    ]
                )
            ]
        )

        let testRoute = OpenAPI.PathItem(
            summary: "Test Endpoint",
            description: "Test Endpoint description",
            parameters: [
                .parameter(
                    name: "param",
                    context: .path,
                    schema: .string
                )
            ],
            get: testSHOW_endpoint,
            post: testCREATE_endpoint
        )

        let components = OpenAPI.Components(
            schemas: [
                "string_schema": .string
            ],
            parameters: [
                "filter": .init(
                    name: "filter",
                    context: .query(required: false),
                    schema: .init(
                        .object(
                            properties: [
                                "size": .integer,
                                "shape": .string(allowedValues: [ "round", "square" ])
                            ]
                        ),
                        style: .deepObject,
                        explode: true
                    )
                )
            ]
        )

        let _ = OpenAPI.Document(
            openAPIVersion: .v3_0_0,
            info: apiInfo,
            servers: [server],
            paths: [
                "/test/api/endpoint/{param}": testRoute
            ],
            components: components,
            security: [],
            externalDocs: .init(
                description: "External Docs",
                url: URL(string: "http://externaldocs.com")!
            )
        )
    }

    func test_JSONSchema() {
        /*

         {
            "data": [
                {
                    "id": "1234",
                    "type": "test_thing",
                    "attributes": {
                        "name": "Thing",
                        "age": 10,
                        "created_at": "2019-11-03T05:24:55Z"
                    },
                    "relationships": {
                        "other": {
                            "data": null
                        }
                    }
                }
            ]
         }

         */
        let _ = JSONSchema.object(
            properties: [
                "data": .array(
                    items: .object(
                        properties: [
                            "id": .string,
                            "type": .string(allowedValues: "test_thing"),

                            "attributes": .object(
                                properties: [
                                    "name": .string,
                                    "age": .integer,
                                    "created_at": .string(format: .dateTime)
                                ]
                            ),

                            "relationships": .object(
                                properties: [
                                    "other": .object(
                                        properties: [
                                            "data": .object(
                                                nullable: true,
                                                properties: [
                                                    "type": .string,
                                                    "id": .string
                                                ]
                                            )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                )
            ]
        )
    }

    func test_securityRequirements() {
        let components = OpenAPI.Components(
            securitySchemes: [
                "basic_auth": .init(
                    type: .http(scheme: "basic", bearerFormat: nil),
                    description: "Basic Auth"
                ),
                "oauth_flow": .init(
                    type: .oauth2(
                        flows: .init(
                            authorizationCode: .init(
                                authorizationUrl: URL(string: "https://address1.com")!,
                                tokenUrl: URL(string: "https://address2.com")!,
                                scopes: [
                                    "read:widgets" : "read those widgets"
                                ]
                            )
                        )
                    ),
                    description: "OAuth Flows"
                )
        ])

        let securityRequirements: [OpenAPI.SecurityRequirement] = [
            [
                .component( named: "basic_auth"): [],
                .component( named: "oauth_flow"): ["read:widgets"]
            ]
        ]

        let _ = OpenAPI.Document(
            info: .init(title: "Secured API", version: "1.0"),
            servers: [OpenAPI.Server(url: URL(string: "http://google.com")!)],
            paths: [:],
            components: components,
            security: securityRequirements
        )
    }

    func test_simpleDeclaration() throws {
        // OpenAPI Info Object
        // https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#info-object
        let info = OpenAPI.Document.Info(title: "Demo API", version: "1.0")

        // OpenAPI Server Object
        // https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#server-object
        let server = OpenAPI.Server(url: URL(string: "https://demo.server.com")!)

        // OpenAPI Components Object
        // https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#components-object
        let components = OpenAPI.Components(
            schemas: [
                "hello_string": .string(allowedValues: "hello")
            ]
        )

        // OpenAPI Response Object
        // https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#response-object
        let successfulHelloResponse = OpenAPI.Response(
            description: "Hello",
            content: [
                .txt: .init(schemaReference: try components.reference(named: "hello_string", ofType: JSONSchema.self))
            ]
        )

        // OpenAPI Document Object
        // https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#openapi-object
        let _ = OpenAPI.Document(
            info: info,
            servers: [server],
            paths: [
                "/hello": .init(
                    summary: "Say hello",
                    get: OpenAPI.Operation(
                        tags: ["Greetings"],
                        summary: "Get a greeting",
                        description: "An endpoint that says hello to you.",
                        responses: [
                            200: .init(successfulHelloResponse)
                        ]
                    )
                )
            ],
            components: components
        )
    }

    func test_getAllEndpoints() {
        let document = testDocument

        // get endpoints for each path
        let endpoints = document.paths.mapValues { $0.endpoints }

        // count endpoints by HTTP method
        let endpointMethods = endpoints.values.flatMap { $0 }.map { $0.method }
        let countByMethod = Dictionary(grouping: endpointMethods, by: { $0 }).mapValues { $0.count }
        XCTAssertEqual(countByMethod[.get], 2)
        XCTAssertEqual(countByMethod[.post], 1)
    }

    func test_resolveSecurity() {
        let document = testDocument

        let securityForAllEndpoints = document.security.first?.first
        let authForAllEndpoints = securityForAllEndpoints.flatMap { document.components[$0.key] }
        let scopesForAllEndpoints = securityForAllEndpoints?.value

        XCTAssertEqual(authForAllEndpoints?.type.name, .oauth2)
        XCTAssertEqual(scopesForAllEndpoints, ["widget:read", "widget:write"])
    }

    func test_getResponseSchema() {
        let document = testDocument

        let endpoint = document.paths["/widgets/{id}"]?.get
        let response = endpoint?.responses[status: 200]?.responseValue
        let responseSchemaReference = response?.content[.json]?.schema
        // this response schema is a reference found in the Components Object. We dereference
        // it to get at the schema.
        let responseSchema = responseSchemaReference.flatMap(document.components.dereference)

        XCTAssertEqual(responseSchema, .object(properties: [ "partNumber": .integer, "description": .string ]))
    }

    func test_getRequestSchema() {
        let document = testDocument

        let endpoint = document.paths["/widgets/{id}"]?.post
        let request = endpoint?.requestBody?.requestValue
        let requestSchemaReference = request?.content[.json]?.schema
        // this request schema is defined inline but dereferencing still produces the schema
        // (dereferencing is just a no-op in this case).
        let requestSchema = requestSchemaReference.flatMap(document.components.dereference)

        XCTAssertEqual(requestSchema, .object(properties: [ "description": .string ]))
    }
}

fileprivate let testWidgetSchema = JSONSchema.object(
    properties: [
        "partNumber": .integer,
        "description": .string
    ]
)

fileprivate let testComponents = OpenAPI.Components(
    schemas: [
        "testWidgetSchema": testWidgetSchema
    ],
    securitySchemes: [
        "oauth": .oauth2(
            flows: .init(
                clientCredentials: .init(
                    tokenUrl: URL(string: "http://website.com/token")!,
                    scopes: [ "widget:read": "", "widget:write": "" ]
                )
            )
        )
    ]
)

fileprivate let testInfo = OpenAPI.Document.Info(title: "Test API", version: "1.0")

fileprivate let testServer = OpenAPI.Server(url: URL(string: "http://website.com")!)

fileprivate let testDocument =  OpenAPI.Document(
    openAPIVersion: .v3_0_3,
    info: testInfo,
    servers: [testServer],
    paths: [
        "/widgets/{id}": OpenAPI.PathItem(
            parameters: [
                .parameter(
                    name: "id",
                    context: .path,
                    schema: .string
                )
            ],
            get: OpenAPI.Operation(
                tags: "Widgets",
                summary: "Get a widget",
                responses: [
                    200: .response(
                        description: "A single widget",
                        content: [
                            .json: .init(schemaReference: .component(named: "testWidgetSchema"))
                        ]
                    )
                ]
            ),
            post: OpenAPI.Operation(
                tags: "Widgets",
                summary: "Create a new widget",
                description: "Create a new widget by adding a description. The created widget will be returned in the response body including a new part number.",
                requestBody: OpenAPI.Request(
                    content: [
                        .json: .init(
                            schema: JSONSchema.object(
                                properties: [
                                    "description": .string
                                ]
                            )
                        )
                    ]
                ),
                responses: [
                    201: .response(
                        description: "The newly created widget",
                        content: [
                            .json: .init(schemaReference: .component(named: "testWidgetSchema"))
                        ]
                    )
                ]
            )
        ),
        "/docs": OpenAPI.PathItem(
            get: OpenAPI.Operation(
                tags: "Documentation",
                responses: [
                    200: .response(
                        description: "Get documentation on this API.",
                        content: [
                            .html: .init(schema: .string)
                        ]
                    )
                ]
            )
        )
    ],
    components: testComponents,
    security: [
        [.component(named: "oauth"): ["widget:read", "widget:write"]]
    ]
)
