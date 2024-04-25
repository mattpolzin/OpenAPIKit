//
//  ExternalDereferencingDocumentTests.swift
//  

import Foundation
import Yams
import OpenAPIKit
import XCTest

final class ExternalDereferencingDocumentTests: XCTestCase {
    // temporarily test with an example of the new interface
    func test_example() async throws {

        /// An example of implementing a loader context for loading external references
        /// into an OpenAPI document.
        struct ExampleLoader: ExternalLoader {
            typealias Message = String

            static func load<T>(_ url: URL) async throws -> (T, [Message]) where T : Decodable {
                // load data from file, perhaps. we will just mock that up for the test:
                let data = try await mockData(componentKey(type: T.self, at: url))

                // We use the YAML decoder purely for order-stability.
                let decoded = try YAMLDecoder().decode(T.self, from: data)
                let finished: T
                // while unnecessary, a loader may likely want to attatch some extra info
                // to keep track of where a reference was loaded from. This test makes sure
                // the following strategy of using vendor extensions works.
                if var extendable = decoded as? VendorExtendable {
                    extendable.vendorExtensions["x-source-url"] = AnyCodable(url)
                    finished = extendable as! T
                } else {
                    finished = decoded 
                }
                return (finished, [url.absoluteString])
            }

            static func componentKey<T>(type: T.Type, at url: URL) throws -> OpenAPIKit.OpenAPI.ComponentKey {
                // do anything you want here to determine what key the new component should be stored at.
                // for the example, we will just transform the URL into a valid components key:
                let urlString = url.pathComponents.dropFirst()
                  .joined(separator: "_")
                  .replacingOccurrences(of: ".", with: "_")
                return try .forceInit(rawValue: urlString)
            }

            /// Mock up some data, just for the example. 
            static func mockData(_ key: OpenAPIKit.OpenAPI.ComponentKey) async throws -> Data {
                return try XCTUnwrap(files[key.rawValue])
            }

            static let files: [String: Data] = [
                "params_name_json": """
                {
                    "name": "name",
                    "description": "a lonely parameter",
                    "in": "path",
                    "required": true,
                    "schema": {
                        "$ref": "file://./schemas/string_param.json#"
                    }
                }
                """,
                "schemas_string_param_json": """
                {
                    "oneOf": [
                        { "type": "string" },
                        { "$ref": "file://./schemas/basic_object.json" }
                    ]
                }
                """,
                "schemas_basic_object_json": """
                {
                    "type": "object"
                }
                """,
                "paths_webhook_json": """
                {
                    "summary": "just a webhook",
                    "get": {
                        "requestBody": {
                            "$ref": "file://./requests/webhook.json"
                        },
                        "responses": {
                            "200": {
                                "$ref": "file://./responses/webhook.json"
                            }
                        }
                    }
                }
                """,
                "requests_webhook_json": """
                {
                    "content": {
                        "application/json": {
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "body": {
                                        "$ref": "file://./schemas/string_param.json"
                                    }
                                }
                            },
                            "examples": {
                                "good": {
                                    "$ref": "file://./examples/good.json"
                                }
                            },
                            "encoding": {
                                "enc1": {
                                    "headers": {
                                        "head1": {
                                            "$ref": "file://./headers/webhook.json"
                                        }
                                    }
                                },
                                "enc2": {
                                    "style": "form"
                                }
                            }
                        }
                    }
                }
                """,
                "responses_webhook_json": """
                {
                    "description": "webhook response",
                    "content": {
                        "application/json": {
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "body": {
                                        "type": "string"
                                    },
                                    "length": {
                                        "type": "integer",
                                        "minimum": 0
                                    }
                                }
                            }
                        }
                    },
                    "headers": {
                        "X-Hello": {
                            "$ref": "file://./headers/webhook2.json"
                        }
                    }
                }
                """,
                "headers_webhook_json": """
                {
                    "schema": {
                        "$ref": "file://./schemas/string_param.json"
                    }
                }
                """,
                "headers_webhook2_json": """
                {
                    "content": {
                        "application/json": {
                            "schema": {
                                "$ref": "file://./schemas/string_param.json"
                            }
                        }
                    }
                }
                """,
                "examples_good_json": """
                {
                    "value": "{\\"body\\": \\"request me\\"}"
                }
                """,
                "callbacks_one_json": """
                {
                    "https://callback.site.com/callback": {
                        "$ref": "file://./paths/callback.json"
                    }
                }
                """,
                "paths_callback_json": """
                {
                    "summary": "just a callback",
                    "get": {
                        "responses": {
                            "200": {
                                "description": "callback response",
                                "content": {
                                    "application/json": {
                                        "schema": {
                                            "type": "object"
                                        }
                                    }
                                },
                                "links": {
                                    "link1": {
                                        "$ref": "file://./links/first.json"
                                    }
                                }
                            }
                        }
                    }
                }
                """,
                "links_first_json": """
                {
                    "operationId": "helloOp"
                }
                """
            ].mapValues { $0.data(using: .utf8)! }
        }

        let document = OpenAPI.Document(
           info: .init(title: "test document", version: "1.0.0"),
           servers: [],
           paths: [
               "/hello/{name}": .init(
                   parameters: [
                       .reference(.external(URL(string: "file://./params/name.json")!))
                   ],
                   get: .init(
                      operationId: "helloOp",
                      responses: [:],
                      callbacks: [
                          "callback1": .reference(.external(URL(string: "file://./callbacks/one.json")!))
                      ]
                   )
               ),
               "/goodbye/{name}": .init(
                   parameters: [
                       .reference(.external(URL(string: "file://./params/name.json")!))
                   ]
               ),
               "/webhook": .reference(.external(URL(string: "file://./paths/webhook.json")!))
            ],
           webhooks: [
                "webhook": .reference(.external(URL(string: "file://./paths/webhook.json")!))
           ],
           components: .init(
               schemas: [
                   "name_param": .reference(.external(URL(string: "file://./schemas/string_param.json")!))
               ],
               // just to show, no parameters defined within document components :
               parameters: [:]
           )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        var docCopy1 = document
        try await docCopy1.externallyDereference(with: ExampleLoader.self)
        try await docCopy1.externallyDereference(with: ExampleLoader.self)
        try await docCopy1.externallyDereference(with: ExampleLoader.self)
        try await docCopy1.externallyDereference(with: ExampleLoader.self)
        docCopy1.components.sort()

        var docCopy2 = document
        try await docCopy2.externallyDereference(with: ExampleLoader.self, depth: 4)
        docCopy2.components.sort()

        var docCopy3 = document
        let messages = try await docCopy3.externallyDereference(with: ExampleLoader.self, depth: .full)
        docCopy3.components.sort()

        XCTAssertEqual(docCopy1, docCopy2)
        XCTAssertEqual(docCopy2, docCopy3)

        XCTAssertEqual(
            messages.sorted(),
            ["file://./callbacks/one.json",
             "file://./examples/good.json",
             "file://./headers/webhook.json",
             "file://./headers/webhook.json",
             "file://./links/first.json",
             "file://./params/name.json",
             "file://./params/name.json",
             "file://./paths/callback.json",
             "file://./paths/webhook.json",
             "file://./paths/webhook.json",
             "file://./requests/webhook.json",
             "file://./responses/webhook.json",
             "file://./schemas/basic_object.json",
             "file://./schemas/string_param.json",
             "file://./schemas/string_param.json",
             "file://./schemas/string_param.json",
             "file://./schemas/string_param.json#"]
        )
    }
}
