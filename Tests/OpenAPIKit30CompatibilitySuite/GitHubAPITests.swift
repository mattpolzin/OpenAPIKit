//
//  GitHubAPITests.swift
//  
//
//  Created by Mathew Polzin on 7/28/20.
//

import XCTest
import OpenAPIKit30
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
        /*
         NOTE: As of GitHub's OpenAPI documentation v 2.22, they started to nest
            their schema components in a bit of an unusual way. not clear to me that
            the thing they are doing is disallowed by the spec, but definitely weird.

            At any rate, it fails here for now so I will pin this to version 2.21 and
            revisit later.
         */
        if githubAPI == nil {
            githubAPI = Result {
                try YAMLDecoder().decode(
                    OpenAPI.Document.self,
                    from: String(contentsOf: URL(string: "https://raw.githubusercontent.com/github/rest-api-description/v1.0.0-rc.1/descriptions/ghes-2.21/ghes-2.21.yaml")!)
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
        XCTAssert(apiDoc.paths.contains(key: "/"))
        XCTAssert(apiDoc.paths.contains(key: "/app"))
        XCTAssert(apiDoc.paths.contains(key: "/app-manifests/{code}/conversions"))
        XCTAssert(apiDoc.paths.contains(key: "/app/installations"))
        XCTAssert(apiDoc.paths.contains(key: "/app/installations/{installation_id}"))
        XCTAssert(apiDoc.paths.contains(key: "/app/installations/{installation_id}/access_tokens"))

        // check for a known POST response
        XCTAssertNotNil(apiDoc.paths["/app/installations/{installation_id}/access_tokens"]?.post?.responses[status: 201])

        // and a known GET response
        XCTAssertNotNil(apiDoc.paths["/app/installations/{installation_id}"]?.get?.responses[status: 200])

        // check for parameters
        XCTAssertFalse(apiDoc.paths["/app/installations/{installation_id}"]?.get?.parameters.isEmpty ?? true)
    }

    func test_successfullyParsedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        // check for a known parameter
        XCTAssertNotNil(apiDoc.components.parameters["per_page"])
        XCTAssertTrue(apiDoc.components.parameters["per_page"]?.context.inQuery ?? false)

        // check for known schema
        XCTAssertNotNil(apiDoc.components.schemas["simple-user"])

        // check for header
        XCTAssertNotNil(apiDoc.components.headers["link"])
    }

    func test_someReferences() throws {
        guard let apiDoc = apiDoc else { return }

        let installationsPath = apiDoc.paths["/app/installations/{installation_id}"]

        let installationsParameters = try installationsPath?.get?.parameters.compactMap(apiDoc.components.lookup)

        XCTAssertNotNil(installationsParameters)
        XCTAssertEqual(installationsParameters?.count, 1)
        XCTAssertEqual(installationsParameters?.first?.description, "installation_id parameter")
        XCTAssertEqual(installationsParameters?.first?.context, .path)
    }

    func test_dereferencedComponents() throws {
        guard let apiDoc = apiDoc else { return }

        let dereferencedDoc = try apiDoc.locallyDereferenced()

        // params are all $refs to Components Object
        XCTAssertTrue(
            dereferencedDoc.paths["/app/installations/{installation_id}"]?.get?.parameters
                .contains { param in param.description == "installation_id parameter" }
                ?? false
        )
    }

    func test_resolveDocument() throws {
        guard let apiDoc = apiDoc else { return }

        let resolvedDoc = try apiDoc.locallyDereferenced().resolved()

        XCTAssertEqual(resolvedDoc.routes.count, apiDoc.paths.count)
        XCTAssertEqual(resolvedDoc.endpoints.count, 550)
    }
}
