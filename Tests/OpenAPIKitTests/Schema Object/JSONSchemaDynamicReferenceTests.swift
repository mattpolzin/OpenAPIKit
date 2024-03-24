//
//  JSONSchemaDynamicReferenceTests.swift
//  
//
//  Created by Mathew Polzin.
//

import Foundation
import XCTest
import OpenAPIKit

final class SchemaObjectDynamicReferenceTests: XCTestCase {
    func test_tmp() throws {
        let testComponents = OpenAPI.Components(
            schemas: [
                "genericList": .array(
                    items: .dynamicReference(.anchor("T")),
                    defs: [
                      "generic-param": .all(of: [], core: .init(dynamicAnchor: "T"))
                    ]
                ),
                "intList": .reference(
                    .component(named: "genericList"), 
                    defs: [
                        "string-param": .string(dynamicAnchor: "T")
                    ]
                )
            ]
        )

        let jsonString = """
        {
          "schemas" : {
            "genericList" : {
              "$defs" : {
                "T" : {
                  "$dynamicAnchor" : "T",
                  "allOf" : [

                  ]
                }
              },
              "items" : {
                "$dynamicRef" : "#T"
              },
              "type" : "array"
            },
            "intList" : {
              "$defs" : {
                "T" : {
                  "$dynamicAnchor" : "T",
                  "type" : "string"
                }
              },
              "$ref" : "#/components/schemas/genericList"
            }
          }
        }
        """

        XCTAssertEqual(
            testComponents, 
            try orderUnstableDecode(OpenAPI.Components.self, from: jsonString.data(using: .utf8)!)
        )
    }

    func test_tmp2() throws {
        let testComponents = OpenAPI.Components(
            schemas: [
                "genericList": .array(
                    items: .dynamicReference(.anchor("T")),
                    defs: [
                      "generic-param": .all(of: [], core: .init(dynamicAnchor: "T"))
                    ]
                ),
                "intList": .reference(
                    .component(named: "genericList"), 
                    defs: [
                        "string-param": .string(dynamicAnchor: "T")
                    ]
                )
            ]
        )

        let testDoc = OpenAPI.Document(
            info: .init(title: "test", version: "1.0.0"),
            servers: [],
            paths: [:],
            components: testComponents
        )

        let dereferenced = try testDoc.locallyDereferenced()

        print(dereferenced.components.schemas["intList"]!.defs)
    }

    func buildDynamicContext<T>(_ defs: OrderedDictionary<T, JSONSchema>) -> [String: JSONSchema] {
        var dynamicContext: [String: JSONSchema] = [:]
        for (_, def) in defs {
          if let anchor = def.dynamicAnchor {
            dynamicContext[anchor] = def
          }
        }
        return dynamicContext
    }

    func t(_ source: JSONSchema, _ components: OpenAPI.Components) throws -> JSONSchema {
        return try tp(
            source,
            dynamicContext: buildDynamicContext(components.schemas)
        )
    }

    func tp(_ source: JSONSchema, dynamicContext: [String: JSONSchema]) throws -> JSONSchema {
        var localDynamicContext = buildDynamicContext(source.defs)

        localDynamicContext.merge(dynamicContext, uniquingKeysWith: { local, global in local })
    }
}
