//
//  SecuritySchemeTests.swift
//  
//
//  Created by Mathew Polzin on 1/3/20.
//

import XCTest
import OpenAPIKit

final class SecuritySchemeTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header))
        let _ = OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header), description: "description")

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header), description: "description"),
            OpenAPI.SecurityScheme.apiKey(name: "hi", location: .header, description: "description")
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .http(scheme: "hi", bearerFormat: "there"), description: "description"),
            OpenAPI.SecurityScheme.http(scheme: "hi", bearerFormat: "there", description: "description")
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .oauth2(flows: .init()), description: "description"),
            OpenAPI.SecurityScheme.oauth2(flows: .init(), description: "description")
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .openIdConnect(openIdConnectUrl: URL(string: "https://google.com")!), description: "description"),
            OpenAPI.SecurityScheme.openIdConnect(url: URL(string: "https://google.com")!, description: "description")
        )
    }
}

// MARK: - Codable
extension SecuritySchemeTests {
    // TODO: write tests
}
