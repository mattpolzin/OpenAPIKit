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
                "/test/api/endpoint/{param}": .pathItem(
                    summary: "Test Endpoint",
                    description: "Test Endpoint description",
                    parameters: [
                        .parameter(
                            name: "param",
                            parameterLocation: .path,
                            schema: .string
                        )
                    ],
                    get: .init(
                        tags: "Test",
                        summary: "Get Test",
                        description: "Get Test description",
                        parameters: [
                            .parameter(reference: .internal(\.parameters, named: "filter")),
                            .parameter(
                                name: "Content-Type",
                                parameterLocation: .header(required: false),
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
                        parameterLocation: .query(required: false),
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

        let testSHOW_endpoint = OpenAPI.PathItem.Operation(
            tags: "Test",
            summary: "Get Test",
            description: "Get Test description",
            parameters: [
                .parameter(reference: .internal(\.parameters, named: "filter")),
                .parameter(
                    name: "Content-Type",
                    parameterLocation: .header(required: false),
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

        let testCREATE_endpoint = OpenAPI.PathItem.Operation(
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
                    parameterLocation: .path,
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
                    parameterLocation: .query(required: false),
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
                "/test/api/endpoint/{param}": .pathItem(testRoute)
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
                .internal(\.securitySchemes, named: "basic_auth"): [],
                .internal(\.securitySchemes, named: "oauth_flow"): ["read:widgets"]
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
}
