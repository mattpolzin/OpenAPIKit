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
                "T": .all(of: [], dynamicAnchor: "T"),
                "genericList": .array(
                    items: .dynamicReference(.internal("T"))
                ),
                "intList": .init(
                )
            ]
        )
    }
}
