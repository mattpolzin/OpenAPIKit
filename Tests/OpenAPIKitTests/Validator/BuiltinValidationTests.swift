//
//  BuiltinValidationTests.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import Foundation
import XCTest
import OpenAPIKit

final class BuiltinValidationTests: XCTestCase {
    
    // MARK: Builtin validators -
    
    func test_noPathsOnDocumentFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.documentContainsPaths)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Document contains at least one path")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths"])
        }
    }

    func test_onePathOnDocumentSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init()
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.documentContainsPaths)
        try document.validate(using: validator)
    }

    func test_noOperationsOnPathItemFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init()
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathsContainOperations)

        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Paths contain at least one operation")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world"])
        }
    }

    func test_oneOperationOnPathItemSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [:])
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathsContainOperations)
        try document.validate(using: validator)
    }

    func test_emptySchemaFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .response(
                                description: "Test",
                                content: [
                                    .json: .init(
                                        schema: .fragment(.init())
                                    )
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.schemaComponentsAreDefined)
        XCTAssertThrowsError(try document.validate(using: validator))
    }

    func test_nestedEmptySchemaFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .response(
                                description: "Test",
                                content: [
                                    .json: .init(
                                        schema: .object(
                                            properties: [
                                                "nested": .fragment(.init())
                                            ]
                                        )
                                    )
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.schemaComponentsAreDefined)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            XCTAssertEqual(
                (error as? ValidationErrorCollection)?.values.map(String.init(describing:)),
                [#"Failed to satisfy: JSON Schema components have defining characteristics (i.e. they are not just the empty schema component: `{}`) [Note that one way to end up with empty schema components is by having property names in an object's `required` array that are not defined in that object's `properties` map] at path: .paths['/hello/world'].get.responses.200.content['application/json'].schema.properties.nested"#]
            )
        }
    }

    func test_noEmptySchemasSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .response(
                                description: "Test",
                                content: [
                                    .json: .init(
                                        // following is _not_ an empty schema component
                                        // because it is actually a `{ "type": "object" }`
                                        // instead of a `{ }`
                                        schema: .object
                                    )
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.schemaComponentsAreDefined)
        try document.validate(using: validator)
    }

    func test_missingPathParamFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world/{idx}": .init(
                    get: .init(
                        responses: [:]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathParametersAreDefined)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(
                error?.values.map(String.init(describing:)),
                [#"The following path parameters were not defined in the Path Item or Operation `parameters`: ["idx"] at path: .paths['/hello/world/{idx}'].GET"#]
            )
        }
    }

    func test_pathParamInPathItemSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world/{idx}": .init(
                    parameters: [
                        .parameter(name: "idx", context: .path, schema: .string)
                    ],
                    get: .init(
                        responses: [:]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathParametersAreDefined)
        try document.validate(using: validator)
    }

    func test_pathParamInOperationSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world/{idx}": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "idx", context: .path, schema: .string)
                        ],
                        responses: [:]
                    )
                )
            ],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.pathParametersAreDefined)
        try document.validate(using: validator)
    }

    func test_missingServerVariableFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [
                .init(urlTemplate: URLTemplate(rawValue: "https://website.com/{path}")!)
            ],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.serverVariablesAreDefined)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            XCTAssertEqual(
                (error as? ValidationErrorCollection)?.values.map(String.init(describing:)),
                [
                    "Server Object does not define the variable 'path' that is found in the `urlTemplate` 'https://website.com/{path}' at path: .servers[0]"
                ]
            )
        }
    }

    func test_partialMissingServerVariablesFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [
                .init(
                    urlTemplate: URLTemplate(rawValue: "{scheme}://website.com/{path}")!,
                    variables: ["scheme": .init(default: "scheme")]
                )
            ],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.serverVariablesAreDefined)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            XCTAssertEqual(
                (error as? ValidationErrorCollection)?.values.map(String.init(describing:)),
                [
                    "Server Object does not define the variable 'path' that is found in the `urlTemplate` '{scheme}://website.com/{path}' at path: .servers[0]"
                ]
            )
        }
    }

    func test_noSevrerVariablesSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [
                .init(urlTemplate: URLTemplate(rawValue: "https://website.com")!)
            ],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.serverVariablesAreDefined)
        try document.validate(using: validator)
    }

    func test_allServerVariablesDefinedSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [
                .init(
                    urlTemplate: URLTemplate(rawValue: "https://website.com/{path}")!,
                    variables: ["path": .init(default: "welcome")]
                )
            ],
            paths: [:],
            components: .noComponents
        )

        let validator = Validator.blank.validating(.serverVariablesAreDefined)
        try document.validate(using: validator)
    }
    
    func test_operationsContainResponsesFails() throws {
        let op = OpenAPI.Operation(responses: [:])
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: op
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationsContainResponses)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operations contain at least one response")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "get", "responses"])
        }
    }
    
    func test_operationsContainResponsesSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "Test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(
                        responses: [
                            200: .response(
                                description: "Test",
                                content: [
                                    .json: .init(
                                        schema: .object(
                                            properties: [
                                                "nested": .fragment(.init())
                                            ]
                                        )
                                    )
                                ]
                            )
                        ]
                    )
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationsContainResponses)
        try document.validate(using: validator)
    }
    
    func test_documentTagNamesAreUniqueFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "hello"]
        )
        let validator = Validator.blank.validating(.documentTagNamesAreUnique)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: The names of Tags in the Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }
    
    func test_documentTagNamesAreUniqueSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "again"]
        )
        let validator = Validator.blank.validating(.documentTagNamesAreUnique)
        try document.validate(using: validator)
    }
    
    func test_pathItemParametersAreUniqueFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "item", context: .query, schema: .string),
                        .parameter(name: "item", context: .query, schema: .string)
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.pathItemParametersAreUnique)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Path Item parameters are unique (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello']")
        }
    }
    
    func test_pathItemParametersAreUniqueSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "item", context: .query, schema: .string),
                        .parameter(name: "item", context: .path, schema: .string), // changes parameter location but not name
                        .parameter(name: "cool", context: .path, schema: .string) // changes parameter name but not location
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.pathItemParametersAreUnique)
        try document.validate(using: validator)
    }
    
    // TODO: operationParametersAreUnique -
    func test_operationParametersAreUniqueFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .path, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string)
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationParametersAreUnique)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operation parameters are unique (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello", "get"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello'].get")
        }
    }
    
    func test_operationParametersAreUniqueSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .query, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string), // changes parameter location but not name
                            .parameter(name: "cool", context: .path, schema: .string)  // changes parameter name but not location
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationParametersAreUnique)
        try document.validate(using: validator)
    }
    
    func test_operationIdsAreUniqueFails() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationIdsAreUnique)
        XCTAssertThrowsError(try document.validate(using: validator)) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: All Operation Ids in Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }
    
    func test_operationIdsAreUniqueSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "one", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )
        let validator = Validator.blank.validating(.operationIdsAreUnique)
        try document.validate(using: validator)
    }
    
    // TODO: schemaReferencesAreValid -
    func test_schemaReferencesAreValidFails() throws {
    }
    func test_schemaReferencesAreValidSucceeds() throws {
    }
    
    // TODO: responseReferencesAreValid -
    func test_responseReferencesAreValidFails() throws {
    }
    func test_responseReferencesAreValidSucceeds() throws {
    }
    
    // TODO: parameterReferencesAreValid -
    func test_parameterReferencesAreValidFails() throws {
    }
    func test_parameterReferencesAreValidSucceeds() throws {
    }
    
    // TODO: exampleReferencesAreValid -
    func test_exampleReferencesAreValidFails() throws {
    }
    func test_exampleReferencesAreValidSucceeds() throws {
    }
    
    // TODO: requestReferencesAreValid -
    func test_requestReferencesAreValidFails() throws {
    }
    func test_requestReferencesAreValidSucceeds() throws {
    }
    
    // TODO: headerReferencesAreValid -
    func test_headerReferencesAreValidFails() throws {
    }
    func test_headerReferencesAreValidSucceeds() throws {
    }
    
    
    // TODO: serverVarialbeEnumIsValid -
    func test_serverVarialbeEnumIsValidFails() throws {
    }
    func test_serverVarialbeEnumIsValidSucceeds() throws {
    }
    
    // TODO: serverVarialbeDefaultExistsInEnum -
    func test_serverVarialbeDefaultExistsInEnumFails() throws {
    }
    func test_serverVarialbeDefaultExistsInEnumSucceeds() throws {
    }
    
    
    // MARK: Default validation -

    func test_duplicateTagOnDocumentFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "hello"]
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: The names of Tags in the Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_uniqueTagsOnDocumentSocceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [:],
            components: .noComponents,
            tags: ["hello", "world"]
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noResponsesOnOperationFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [:])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operations contain at least one response")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello/world", "get", "responses"])
        }
    }

    func test_oneResponseOnOperationSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello/world": .init(
                    get: .init(responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicateOperationParameterFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .path, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string)
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Operation parameters are unique (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello", "get"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello'].get")
        }
    }

    func test_uniqueOperationParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [
                            .parameter(name: "hiya", context: .query, schema: .string),
                            .parameter(name: "hiya", context: .path, schema: .string), // changes parameter location but not name
                            .parameter(name: "cool", context: .path, schema: .string)  // changes parameter name but not location
                        ],
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noOperationParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [],
                        responses: [
                            200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicateOperationIdFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "test", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: All Operation Ids in Document are unique")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, [])
        }
    }

    func test_uniqueOperationIdsSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: "one", responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: "two", responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noOperationIdsSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(operationId: nil, responses: [
                        200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(operationId: nil, responses: [
                        200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_duplicatePathItemParameterFails() {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "hiya", context: .query, schema: .string),
                        .parameter(name: "hiya", context: .query, schema: .string)
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.first?.reason, "Failed to satisfy: Path Item parameters are unique (identity is defined by the 'name' and 'location')")
            XCTAssertEqual(error?.values.first?.codingPath.map { $0.stringValue }, ["paths", "/hello"])
            XCTAssertEqual(error?.values.first?.codingPathString, ".paths['/hello']")
        }
    }

    func test_uniquePathItemParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    parameters: [
                        .parameter(name: "hiya", context: .query, schema: .string),
                        .parameter(name: "hiya", context: .path, schema: .string), // changes parameter location but not name
                        .parameter(name: "cool", context: .path, schema: .string) // changes parameter name but not location
                    ],
                    get: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_noPathItemParametersSucceeds() throws {
        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": .init(
                    get: .init(
                        parameters: [],
                        responses: [
                            200: .response(description: "hi")
                    ])
                ),
                "/hello/world": .init(
                    put: .init(
                        responses: [
                            200: .response(description: "hi")
                    ])
                )
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        try document.validate()
    }

    func test_oneOfEachReferenceTypeFails() throws {

        let path = OpenAPI.PathItem(
            get: .init(
                parameters: [
                    .reference(.component(named: "parameter1"))
                ],
                requestBody: .reference(.component(named: "request1")),
                responses: [
                    200: .reference(.component(named: "response1")),
                    404: .response(
                        description: "response2",
                        headers: ["header1": .reference(.component(named: "header1"))],
                        content: [
                            .json: .init(
                                schema: .string,
                                examples: [
                                    "example1": .reference(.component(named: "example1"))
                                ]
                            ),
                            .xml: .init(schemaReference: .component(named: "schema1"))
                        ]
                    )
                ]
            )
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": path
            ],
            components: .noComponents
        )

        // NOTE this is part of default validation
        XCTAssertThrowsError(try document.validate()) { error in
            let error = error as? ValidationErrorCollection
            XCTAssertEqual(error?.values.count, 6)
            XCTAssertEqual(error?.values[0].reason, "Failed to satisfy: Parameter reference can be found in components/parameters")
            XCTAssertEqual(error?.values[0].codingPathString, ".paths['/hello'].get.parameters[0]")
            XCTAssertEqual(error?.values[1].reason, "Failed to satisfy: Request reference can be found in components/requestBodies")
            XCTAssertEqual(error?.values[1].codingPathString, ".paths['/hello'].get.requestBody")
            XCTAssertEqual(error?.values[2].reason, "Failed to satisfy: Response reference can be found in components/responses")
            XCTAssertEqual(error?.values[2].codingPathString, ".paths['/hello'].get.responses.200")
            XCTAssertEqual(error?.values[3].reason, "Failed to satisfy: Header reference can be found in components/headers")
            XCTAssertEqual(error?.values[3].codingPathString, ".paths['/hello'].get.responses.404.headers.header1")
            XCTAssertEqual(error?.values[4].reason, "Failed to satisfy: Example reference can be found in components/examples")
            XCTAssertEqual(error?.values[4].codingPathString, ".paths['/hello'].get.responses.404.content['application/json'].examples.example1")
            XCTAssertEqual(error?.values[5].reason, "Failed to satisfy: JSONSchema reference can be found in components/schemas")
            XCTAssertEqual(error?.values[5].codingPathString, ".paths['/hello'].get.responses.404.content['application/xml'].schema")
        }
    }

    func test_oneOfEachReferenceTypeSucceeds() throws {
        let path = OpenAPI.PathItem(
            put: .init(
                requestBody: .reference(.external(URL(string: "https://website.com/file.json#/hello/world")!)),
                responses: [
                    200: .response(description: "empty")
                ]
            ),
            post: .init(
                parameters: [
                    .reference(.component(named: "parameter1")),
                    .reference(.external(URL(string: "https://website.com/file.json#/hello/world")!))
                ],
                requestBody: .reference(.component(named: "request1")),
                responses: [
                    200: .reference(.component(named: "response1")),
                    301: .reference(.external(URL(string: "https://website.com/file.json#/hello/world")!)),
                    404: .response(
                        description: "response2",
                        headers: [
                            "header1": .reference(.component(named: "header1")),
                            "external": .reference(.external(URL(string: "https://website.com/file.json#/hello/world")!))
                        ],
                        content: [
                            .json: .init(
                                schema: .string,
                                examples: [
                                    "example1": .reference(.component(named: "example1")),
                                    "external": .reference(.external(URL(string: "https://website.com/file.json#/hello/world")!))
                                ]
                            ),
                            .xml: .init(schemaReference: .component(named: "schema1")),
                            .txt: .init(schemaReference: .external(URL(string: "https://website.com/file.json#/hello/world")!))
                        ]
                    )
                ]
            )
        )

        let document = OpenAPI.Document(
            info: .init(title: "test", version: "1.0"),
            servers: [],
            paths: [
                "/hello": path
            ],
            components: .init(
                schemas: [
                    "schema1": .object
                ],
                responses: [
                    "response1": .init(description: "test")
                ],
                parameters: [
                    "parameter1": .init(name: "test", context: .header, schema: .string)
                ],
                examples: [
                    "example1": .init(value: .b("hello"))
                ],
                requestBodies: [
                    "request1": .init(content: [.json: .init(schema: .object)])
                ],
                headers: [
                    "header1": .init(schema: .string)
                ]
            )
        )

        // NOTE this is part of default validation
        try document.validate()
    }
}
