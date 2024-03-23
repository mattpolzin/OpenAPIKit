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
                    items: .dynamicReference(.internal("T"))
                    defs: [
                      "T": .all(of: [], dynamicAnchor: "T")
                    ]
                ),
                "intList": .reference(
                    .component(named: "genericList"), 
                    defs: [
                        "T": .string(dynamicAnchor: "T")
                    ]
                )
            ]
        )
    }
}
