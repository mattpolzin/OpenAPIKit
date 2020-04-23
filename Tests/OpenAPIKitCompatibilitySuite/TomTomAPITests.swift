//
//  TomTomAPITests.swift
//
//
//  Created by Mathew Polzin on 2/17/20.
//

import XCTest
import OpenAPIKit
import Yams
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class TomTomAPICampatibilityTests: XCTestCase {
    var tomtomAPI: Result<OpenAPI.Document, Error>? = nil
    var apiDoc: OpenAPI.Document? {
        guard case .success(let document) = tomtomAPI else { return nil }
        return document
    }

    override func setUp() {
        if tomtomAPI == nil {
            tomtomAPI = Result {
                try YAMLDecoder().decode(
                    OpenAPI.Document.self,
                    from: String(contentsOf: URL(string: "https://raw.githubusercontent.com/APIs-guru/openapi-directory/c9190db19e5cb151592d44f0d4482839e1e5a8e0/APIs/tomtom.com/search/1.0.0/openapi.yaml")!)
                )
            }
        }
    }

    func test_successfullyParsedDocument() {
        switch tomtomAPI {
        case nil:
            XCTFail("Did not attempt to pull TomTom API documentation like expected.")
        case .failure(let error):
            let prettyError = OpenAPI.Error(from: error)
            XCTFail(prettyError.localizedDescription + "\n coding path: " + prettyError.codingPathString)
        case .success:
            break
        }
    }

    func test_successfullyParsedBasicMetadata() {
        guard let apiDoc = apiDoc else { return }

        // title is Search
        XCTAssertEqual(apiDoc.info.title, "Search")

        // description is set
        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)

        // contact name is "Contact Us"
        XCTAssertEqual(apiDoc.info.contact?.name, "Contact Us")

        // no contact email is provided
        XCTAssert(apiDoc.info.contact?.email?.isEmpty ?? true)

        // server is specified
        XCTAssertNotNil(apiDoc.servers.first)
    }

    func test_successfullyParsedRoutes() {
        guard let apiDoc = apiDoc else { return }

        // just check for a few of the known paths
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/additionalData.{ext}"))
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/cS/{category}.{ext}"))
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/categorySearch/{query}.{ext}"))
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/geocode/{query}.{ext}"))
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/geometryFilter.{ext}"))
        XCTAssert(apiDoc.paths.contains(key: "/search/{versionNumber}/geometrySearch/{query}.{ext}"))

        // check for a known POST response
        XCTAssertNotNil(apiDoc.paths["/search/{versionNumber}/geometrySearch/{query}.{ext}"]?.post?.responses[200 as OpenAPI.Response.StatusCode])

        // and a known GET response
        XCTAssertNotNil(apiDoc.paths["/search/{versionNumber}/geometrySearch/{query}.{ext}"]?.get?.responses[200 as OpenAPI.Response.StatusCode])

        // check for parameters
        XCTAssertFalse(apiDoc.paths["/search/{versionNumber}/geometrySearch/{query}.{ext}"]?.get?.parameters.isEmpty ?? true)
    }

    func test_successfullyParsedComponents() {
        guard let apiDoc = apiDoc else { return }

        // check for a known parameter
        XCTAssertNotNil(apiDoc.components.parameters["btmRight"])
        XCTAssertTrue(apiDoc.components.parameters["btmRight"]?.parameterLocation.inQuery ?? false)

        // check for known response
        XCTAssertNotNil(apiDoc.components.responses["200"])

        // check for known security scheme
        XCTAssertNotNil(apiDoc.components.securitySchemes["api_key"])
    }
}
