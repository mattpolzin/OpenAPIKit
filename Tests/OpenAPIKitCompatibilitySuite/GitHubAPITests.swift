//
//  GitHubAPITests.swift
//  
//
//  Created by Mathew Polzin on 7/28/20.
//

import XCTest
import OpenAPIKit
import Yams
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class GitHubAPICampatibilityTests: XCTestCase {
    var githubAPI: Result<OpenAPI.Document, Error>? = nil
    var apiDoc: OpenAPI.Document? {
        guard case .success(let document) = githubAPI else { return nil }
        return document
    }

    override func setUp() {
        if githubAPI == nil {
            githubAPI = Result {
                try YAMLDecoder().decode(
                    OpenAPI.Document.self,
                    from: String(contentsOf: URL(string: "https://raw.githubusercontent.com/github/rest-api-description/main/descriptions/api.github.com/api.github.com.yaml")!)
                )
            }
        }
    }

    func test_successfullyParsedDocument() {
        switch githubAPI {
        case nil:
            XCTFail("Did not attempt to pull GitHub API documentation like expected.")
        case .failure(let error):
            let prettyError = OpenAPI.Error(from: error)
            XCTFail(prettyError.localizedDescription + "\n coding path: " + prettyError.codingPathString)
        case .success:
            break
        }
    }

    func test_passesValidation() throws {
        guard let apiDoc = apiDoc else { return }

        try apiDoc.validate()
    }

    func test_successfullyParsedBasicMetadata() throws {
        guard let apiDoc = apiDoc else { return }

        // title is GitHub v3 REST API
        XCTAssertEqual(apiDoc.info.title, "GitHub v3 REST API")

        // description is set
        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)

        // contact name is Support
        XCTAssertEqual(apiDoc.info.contact?.name, "Support")

        // contact URL was parsed as https://support.github.com
        XCTAssertEqual(apiDoc.info.contact?.url, URL(string: "https://support.github.com")!)

        // no contact email is provided
        XCTAssert(apiDoc.info.contact?.email?.isEmpty ?? true)

        // there is at least one tag defined
        XCTAssertFalse(apiDoc.tags?.isEmpty ?? true)

        // server is specified
        XCTAssertNotNil(apiDoc.servers.first)
    }

    func test_successfullyParsedRoutes() throws {
        guard let apiDoc = apiDoc else { return }

        // just check for a few of the known paths
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/cloudloading/addBook"))
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/cloudloading/deleteBook"))
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/cloudloading/updateBook"))
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/dictionary/listOfflineMetadata"))
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/familysharing/getFamilyInfo"))
        XCTAssert(apiDoc.paths.contains(key: "/books/v1/familysharing/share"))

        // check for a known POST response
        XCTAssertNotNil(apiDoc.paths["/books/v1/cloudloading/addBook"]?.post?.responses[200 as OpenAPI.Response.StatusCode])

        // and a known GET response
        XCTAssertNotNil(apiDoc.paths["/books/v1/dictionary/listOfflineMetadata"]?.get?.responses[200 as OpenAPI.Response.StatusCode])

        // check for parameters
        XCTAssertFalse(apiDoc.paths["/books/v1/dictionary/listOfflineMetadata"]?.parameters.isEmpty ?? true)
    }

    func test_successfullyParsedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        // check for a known parameter
        XCTAssertNotNil(apiDoc.components.parameters["alt"])
        XCTAssertTrue(apiDoc.components.parameters["alt"]?.context.inQuery ?? false)

        // check for known schema
        XCTAssertNotNil(apiDoc.components.schemas["Annotation"])

        // check for oauth flow
        XCTAssertNotNil(apiDoc.components.securitySchemes["Oauth2"])
    }

    func test_someReferences() throws {
        guard let apiDoc = apiDoc else { return }

        let addBooksPath = apiDoc.paths["/books/v1/cloudloading/addBook"]

        let addBooksParameters = try addBooksPath?.parameters.compactMap(apiDoc.components.lookup)

        XCTAssertNotNil(addBooksParameters)
        XCTAssertEqual(addBooksParameters?.count, 11)
        XCTAssertEqual(addBooksParameters?.first?.description, "JSONP")
        XCTAssertEqual(addBooksParameters?.first?.context, .query)
    }

    func test_dereferencedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        let dereferencedDoc = try apiDoc.locallyDereferenced()

        // params are all $refs to Components Object
        XCTAssertTrue(
            dereferencedDoc.paths["/books/v1/volumes/{volumeId}/layersummary/{summaryId}"]?.parameters
                .contains { param in param.description == "OAuth access token." }
                ?? false
        )
    }

    func test_resolveDocument() throws {
        guard let apiDoc = apiDoc else { return }

        let resolvedDoc = try apiDoc.locallyDereferenced().resolved()

        XCTAssert(resolvedDoc.routes.count >= 403)
        XCTAssert(resolvedDoc.endpoints.count >= 623)
        XCTAssertEqual(resolvedDoc.tags?.count, resolvedDoc.allTags.count)
    }
}
