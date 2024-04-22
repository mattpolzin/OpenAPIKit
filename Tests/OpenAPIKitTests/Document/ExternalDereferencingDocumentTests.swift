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
            static func load<T>(_ url: URL) async throws -> T where T : Decodable {
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
                return finished
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
                        "$ref": "file://./schemas/name_param.json#"
                    }
                }
                """,
                "schemas_name_param_json": """
                {
                    "type": "string"
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
                                        "type": "string"
                                    }
                                }
                            },
                            "examples": {
                                "good": {
                                    "$ref": "file://./examples/good.json"
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
                            "$ref": "file://./headers/webhook.json"
                        }
                    }
                }
                """,
                "headers_webhook_json": """
                {
                    "schema": {
                        "$ref": "file://./schemas/name_param.json"
                    }
                }
                """,
                "examples_good_json": """
                {
                    "value": "{\\"body\\": \\"request me\\"}"
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
                   ]
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
                   "name_param": .reference(.external(URL(string: "file://./schemas/name_param.json")!))
               ],
               // just to show, no parameters defined within document components :
               parameters: [:]
           )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        var docCopy1 = document
        try await docCopy1.externallyDereference(in: ExampleLoader.self)
        try await docCopy1.externallyDereference(in: ExampleLoader.self)
        try await docCopy1.externallyDereference(in: ExampleLoader.self)
        docCopy1.components.sort()

        var docCopy2 = document
        try await docCopy2.externallyDereference(in: ExampleLoader.self, depth: 3)
        docCopy2.components.sort()

        var docCopy3 = document
        try await docCopy3.externallyDereference(in: ExampleLoader.self, depth: .full)
        docCopy3.components.sort()

//        print("-----")
//        print(docCopy2 == docCopy3)
//        print(docCopy2.components == docCopy3.components)
//        print("+++++")
//        print(docCopy2.components.schemas == docCopy3.components.schemas)
//        print(docCopy2.components.responses == docCopy3.components.responses)
//        print(docCopy2.components.parameters == docCopy3.components.parameters)
//        print(docCopy2.components.examples == docCopy3.components.examples)
//        print(docCopy2.components.requestBodies == docCopy3.components.requestBodies)
//        print(docCopy2.components.headers == docCopy3.components.headers)
//        print(docCopy2.components.securitySchemes == docCopy3.components.securitySchemes)
//        print(docCopy2.components.links == docCopy3.components.links)
//        print(docCopy2.components.callbacks == docCopy3.components.callbacks)
//        print(docCopy2.components.pathItems == docCopy3.components.pathItems)
//        print("=====")
//        print(docCopy2.components.responses)
//        print("&&&&&")
//        print(docCopy3.components.responses)
//        print("$$$$$")

        XCTAssertEqual(docCopy1, docCopy2)
        XCTAssertEqual(docCopy2, docCopy3)
//        XCTAssertEqual(String(describing: docCopy2), String(describing: docCopy3))

       // - MARK: After
//       print(
//           String(data: try encoder.encode(docCopy1), encoding: .utf8)!
//       )
//       print(
//           String(data: try encoder.encode(docCopy2), encoding: .utf8)!
//       )
//       print(
//           String(data: try encoder.encode(docCopy3), encoding: .utf8)!
//       )
    }
}
