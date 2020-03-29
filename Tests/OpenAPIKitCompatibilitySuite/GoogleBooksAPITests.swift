//
//  GoogleBooksAPITests.swift
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

final class GoogleBooksAPICampatibilityTests: XCTestCase {
    var booksAPI: Result<OpenAPI.Document, Error>? = nil
    var apiDoc: OpenAPI.Document? {
        guard case .success(let document) = booksAPI else { return nil }
        return document
    }

    override func setUp() {
        if booksAPI == nil {
            booksAPI = Result {
                try YAMLDecoder().decode(
                    OpenAPI.Document.self,
                    from: String(contentsOf: URL(string: "https://raw.githubusercontent.com/APIs-guru/openapi-directory/master/APIs/googleapis.com/books/v1/openapi.yaml")!)
                )
            }
        }
    }

    func test_successfullyParsedDocument() {
        switch booksAPI {
        case nil:
            XCTFail("Did not attempt to pull Google Books API documentation like expected.")
        case .failure(let error):
            let prettyError = OpenAPI.Error(from: error)
            XCTFail(prettyError.localizedDescription + "\n coding path: " + prettyError.codingPathString)
        case .success:
            break
        }
    }

    func test_successfullyParsedBasicMetadata() {
        guard let apiDoc = apiDoc else { return }

        // title is Books
        XCTAssertEqual(apiDoc.info.title, "Books")

        // description is set
        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)

        // contact name is Google
        XCTAssertEqual(apiDoc.info.contact?.name, "Google")

        // no contact email is provided
        XCTAssert(apiDoc.info.contact?.email?.isEmpty ?? true)

        // there is at least one tag defined
        XCTAssertFalse(apiDoc.tags?.isEmpty ?? true)

        // server is specified
        XCTAssertNotNil(apiDoc.servers.first)
    }

    func test_successfullyParsedRoutes() {
        guard let apiDoc = apiDoc else { return }

        // just check for a few of the known paths
        XCTAssert(apiDoc.paths.contains(key: "/cloudloading/addBook"))
        XCTAssert(apiDoc.paths.contains(key: "/cloudloading/deleteBook"))
        XCTAssert(apiDoc.paths.contains(key: "/cloudloading/updateBook"))
        XCTAssert(apiDoc.paths.contains(key: "/dictionary/listOfflineMetadata"))
        XCTAssert(apiDoc.paths.contains(key: "/familysharing/getFamilyInfo"))
        XCTAssert(apiDoc.paths.contains(key: "/familysharing/share"))

        // check for a known POST response
        XCTAssertNotNil(apiDoc.paths["/cloudloading/addBook"]?.post?.responses[200 as OpenAPI.Response.StatusCode])

        // and a known GET response
        XCTAssertNotNil(apiDoc.paths["/dictionary/listOfflineMetadata"]?.get?.responses[200 as OpenAPI.Response.StatusCode])

        // check for parameters
        XCTAssertFalse(apiDoc.paths["/dictionary/listOfflineMetadata"]?.parameters.isEmpty ?? true)
    }

    func test_successfullyParsedComponents() {
        guard let apiDoc = apiDoc else { return }

        // check for a known parameter
        XCTAssertNotNil(apiDoc.components.parameters["alt"])
        XCTAssertTrue(apiDoc.components.parameters["alt"]?.parameterLocation.inQuery ?? false)

        // check for known schema
        XCTAssertNotNil(apiDoc.components.schemas["Annotation"])

        // check for oauth flow
        XCTAssertNotNil(apiDoc.components.securitySchemes["Oauth2"])
    }

    func test_someReferences() {
        guard let apiDoc = apiDoc else { return }

        let addBooksPath = apiDoc.paths["/cloudloading/addBook"]

        let addBooksParameters = addBooksPath?.parameters.compactMap(apiDoc.components.dereference)

        XCTAssertNotNil(addBooksParameters)
        XCTAssertEqual(addBooksParameters?.count, 7)
        XCTAssertEqual(addBooksParameters?.first?.description, "Data format for the response.")
        XCTAssertEqual(addBooksParameters?.first?.parameterLocation, .query)
    }
}
