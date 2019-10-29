//
//  EaseOfUseTests.swift
//  
//
//  Created by Mathew Polzin on 10/27/19.
//

import Foundation
import OpenAPIKit
import XCTest

final class EaseOfUseTests: XCTestCase {
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
                "/test/api/endpoint/{param}": .pathItem(.init(
                    summary: "Test Endpoint",
                    description: "Test Endpoint description",
                    parameters: [
                        .parameter(.init(
                            name: "param",
                            parameterLocation: .path,
                            schema: .string)
                        )
                    ],
                    get: .init(
                        tags: ["Test"],
                        summary: "Get Test",
                        description: "Get Test description",
                        parameters: [
                            .parameter(reference: .internal(.node(\.parameters, named: "global_param"))),
                            .parameter(.init(
                                name: "Content-Type",
                                parameterLocation: .header(required: false),
                                schema: .string(
                                    allowedValues: [
                                        .init(OpenAPI.ContentType.json.rawValue),
                                        .init(OpenAPI.ContentType.txt.rawValue)
                                    ]
                                )
                            ))
                        ],
                        responses: [
                            200: .response(.init(
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
                            ))
                        ]
                    ),
                    post: .init(
                        tags: ["Test"],
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
                            202: .response(.init(
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
                            ))
                        ]
                    ))
                )
            ],
            components: .init(
                schemas: [
                    "string_schema": .string
                ],
                responses: [:],
                parameters: [
                    "global_param": .init(
                        name: "global_param",
                        parameterLocation: .query(required: false),
                        schema: .string
                    )
                ],
                examples: [:],
                requestBodies: [:],
                headers: [:]
            ),
            externalDocs: .init(
                description: "External Docs",
                url: URL(string: "http://externaldocs.com")!
            )
        )
    }
}
