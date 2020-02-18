//
//  GoogleBooksAPI.swift
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

/*

 Currently failing to parse because OpenAPIKit lacks support for JSON references.

 Is it worth failing to parse this? sometimes, yeah, it would be good to know if you were accidentally publishing
 an empty server URL when you meant to publish one.

 failed - The data couldn’t be read because it isn’t in the correct format.
 coding path: servers -> Index 0 -> url
 debug description: Invalid URL string.

 */

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

    func test_successfulParse() {
        switch booksAPI {
        case nil:
            XCTFail("Did not attempt to pull Google Books API documentation like expected.")
        case .failure(let error as DecodingError):
            let codingPath: String
            let debugDetails: String
            let underlyingError: String
            switch error {
            case .dataCorrupted(let context), .keyNotFound(_, let context), .typeMismatch(_, let context), .valueNotFound(_, let context):
                codingPath = context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
                debugDetails = context.debugDescription
                underlyingError = context.underlyingError.map { "\n underlying error: " + String(describing: $0) } ?? ""
            @unknown default:
                codingPath = ""
                debugDetails = ""
                underlyingError = ""
            }
            XCTFail(error.failureReason ?? error.errorDescription ?? error.localizedDescription + "\n coding path: " + codingPath + "\n debug description: " + debugDetails + underlyingError)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        case .success:
            break
        }
    }

    func test_successfullyParsedBasicMetadata() {
        guard let apiDoc = apiDoc else { return }

        // title is set
        XCTAssertFalse(apiDoc.info.title.isEmpty)

        // description is set
        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)

        // contact name is Google
        XCTAssertEqual(apiDoc.info.contact?.name, "Google")

        // no contact email is provided
        XCTAssertTrue(apiDoc.info.contact?.email?.isEmpty ?? true)

        // there is at least one tag defined
        XCTAssertFalse(apiDoc.tags?.isEmpty ?? true)
    }
}
