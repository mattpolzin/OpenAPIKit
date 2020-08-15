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

    func test_locallyDereferenced() throws {
        // should just be self
        let t1 = OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header))
        XCTAssertEqual(try t1.dereferenced(in: .noComponents), t1)

        let t2 = OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header), description: "description")
        XCTAssertEqual(try t2.dereferenced(in: .noComponents), t2)
    }

    func test_names() {
        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .apiKey(name: "hi", location: .header), description: "description").type.name,
            .apiKey
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .http(scheme: "hi", bearerFormat: "there"), description: "description").type.name,
            .http
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .oauth2(flows: .init()), description: "description").type.name,
            .oauth2
        )

        XCTAssertEqual(
            OpenAPI.SecurityScheme(type: .openIdConnect(openIdConnectUrl: URL(string: "https://google.com")!), description: "description").type.name,
            .openIdConnect
        )
    }
}

// MARK: - Codable
extension SecuritySchemeTests {
    func test_apiKeyWithoutDescription_encode() throws {
        let apiKey = OpenAPI.SecurityScheme.apiKey(name: "hi", location: .header)

        let encodedApiKey = try orderUnstableTestStringFromEncoding(of: apiKey)

        assertJSONEquivalent(
            encodedApiKey,
"""
{
  "in" : "header",
  "name" : "hi",
  "type" : "apiKey"
}
"""
        )
    }

    func test_apiKeyWithoutDescription_decode() throws {
        let apiKeyData =
"""
{
  "in" : "header",
  "name" : "hi",
  "type" : "apiKey"
}
""".data(using: .utf8)!

        let apiKey = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: apiKeyData)

        XCTAssertEqual(
            apiKey,
            OpenAPI.SecurityScheme.apiKey(name: "hi", location: .header)
        )
    }

    func test_apiKeyWithDescription_encode() throws {
        let apiKey = OpenAPI.SecurityScheme.apiKey(name: "hi", location: .header, description: "hello")

        let encodedApiKey = try orderUnstableTestStringFromEncoding(of: apiKey)

        assertJSONEquivalent(
            encodedApiKey,
"""
{
  "description" : "hello",
  "in" : "header",
  "name" : "hi",
  "type" : "apiKey"
}
"""
        )
    }

    func test_apiKeyWithDescription_decode() throws {
        let apiKeyData =
"""
{
  "description" : "hello",
  "in" : "header",
  "name" : "hi",
  "type" : "apiKey"
}
""".data(using: .utf8)!

        let apiKey = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: apiKeyData)

        XCTAssertEqual(
            apiKey,
            OpenAPI.SecurityScheme.apiKey(name: "hi", location: .header, description: "hello")
        )
    }

    func test_http_encode() throws {
        let http = OpenAPI.SecurityScheme.http(scheme: "hi")

        let encodedHttp = try orderUnstableTestStringFromEncoding(of: http)

        assertJSONEquivalent(
            encodedHttp,
"""
{
  "scheme" : "hi",
  "type" : "http"
}
"""
        )
    }

    func test_http_decode() throws {
        let httpData =
"""
{
  "scheme" : "hi",
  "type" : "http"
}
""".data(using: .utf8)!

        let http = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: httpData)

        XCTAssertEqual(
            http,
            OpenAPI.SecurityScheme.http(scheme: "hi")
        )
    }

    func test_httpWithBearer_encode() throws {
        let http = OpenAPI.SecurityScheme.http(scheme: "hi", bearerFormat: "hello")

        let encodedHttp = try orderUnstableTestStringFromEncoding(of: http)

        assertJSONEquivalent(
            encodedHttp,
"""
{
  "bearerFormat" : "hello",
  "scheme" : "hi",
  "type" : "http"
}
"""
        )
    }

    func test_httpWithBearer_decode() throws {
        let httpData =
"""
{
  "bearerFormat" : "hello",
  "scheme" : "hi",
  "type" : "http"
}
""".data(using: .utf8)!

        let http = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: httpData)

        XCTAssertEqual(
            http,
            OpenAPI.SecurityScheme.http(scheme: "hi", bearerFormat: "hello")
        )
    }

    func test_oauth2_encode() throws {
        let oauth = OpenAPI.SecurityScheme.oauth2(
            flows: .init(
                implicit: .init(
                    authorizationUrl: URL(string: "http://google.com")!,
                    scopes: ["read:test": "read test"]
                )
            )
        )

        let encodedOAuth = try orderUnstableTestStringFromEncoding(of: oauth)

        assertJSONEquivalent(
            encodedOAuth,
"""
{
  "flows" : {
    "implicit" : {
      "authorizationUrl" : "http:\\/\\/google.com",
      "scopes" : {
        "read:test" : "read test"
      }
    }
  },
  "type" : "oauth2"
}
"""
        )
    }

    func test_oauth2_decode() throws {
        let oauthData =
"""
{
  "flows" : {
    "implicit" : {
      "authorizationUrl" : "http:\\/\\/google.com",
      "scopes" : {
        "read:test" : "read test"
      }
    }
  },
  "type" : "oauth2"
}
""".data(using: .utf8)!

        let oauth = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: oauthData)

        XCTAssertEqual(
            oauth,
            OpenAPI.SecurityScheme.oauth2(
                flows: .init(
                    implicit: .init(
                        authorizationUrl: URL(string: "http://google.com")!,
                        scopes: ["read:test": "read test"]
                    )
                )
            )
        )
    }

    func test_openIdConnect_encode() throws {
        let openIdConnect = OpenAPI.SecurityScheme.openIdConnect(url: URL(string: "http://google.com")!)

        let encodedOpenIdConnect = try orderUnstableTestStringFromEncoding(of: openIdConnect)

        assertJSONEquivalent(
            encodedOpenIdConnect,
"""
{
  "openIdConnectUrl" : "http:\\/\\/google.com",
  "type" : "openIdConnect"
}
"""
        )
    }

    func test_openIdConnect_decode() throws {
        let openIdConnectData =
"""
{
  "openIdConnectUrl" : "http:\\/\\/google.com",
  "type" : "openIdConnect"
}
""".data(using: .utf8)!

        let openIdConnect = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: openIdConnectData)

        XCTAssertEqual(
            openIdConnect,
            OpenAPI.SecurityScheme.openIdConnect(url: URL(string: "http://google.com")!)
        )
    }

    func test_openIdConnect_withExtension_encode() throws {
        let openIdConnect = OpenAPI.SecurityScheme(
            type: .openIdConnect(
                openIdConnectUrl: URL(string: "http://google.com")!
            ),
            vendorExtensions: [ "x-specialFeature": "hello" ]
        )

        let encodedOpenIdConnect = try orderUnstableTestStringFromEncoding(of: openIdConnect)

        assertJSONEquivalent(
            encodedOpenIdConnect,
"""
{
  "openIdConnectUrl" : "http:\\/\\/google.com",
  "type" : "openIdConnect",
  "x-specialFeature" : "hello"
}
"""
        )
    }

    func test_openIdConnect_withExtension_decode() throws {
        let openIdConnectData =
"""
{
  "openIdConnectUrl" : "http:\\/\\/google.com",
  "type" : "openIdConnect",
  "x-specialFeature" : "hello"
}
""".data(using: .utf8)!

        let openIdConnect = try orderUnstableDecode(OpenAPI.SecurityScheme.self, from: openIdConnectData)

        XCTAssertEqual(
            openIdConnect,
            OpenAPI.SecurityScheme(
                type: .openIdConnect(
                    openIdConnectUrl: URL(string: "http://google.com")!
                ),
                vendorExtensions: [ "x-specialFeature": "hello" ]
            )
        )
    }
}
