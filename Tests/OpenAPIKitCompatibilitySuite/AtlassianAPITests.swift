//
//  AtlassianAPITests.swift
//
//
//  Created by Mathew Polzin on 2/17/20.
//

import XCTest
import OpenAPIKit
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


/*

 Currently failing to parse because Atlassian includes an empty string as a server URL which is not a valid URL.

 Is it worth failing to parse this? sometimes, yeah, it would be good to know if you were accidentally publishing
 an empty server URL when you meant to publish one.

 failed - The data couldn’t be read because it isn’t in the correct format.
 coding path: servers -> Index 0 -> url
 debug description: Invalid URL string.

 */


//final class AtlassianAPICampatibilityTests: XCTestCase {
//    var atlassianAPI: Result<OpenAPI.Document, Error>? = nil
//    var apiDoc: OpenAPI.Document? {
//        guard case .success(let document) = atlassianAPI else { return nil }
//        return document
//    }
//
//    override func setUp() {
//        if atlassianAPI == nil {
//            atlassianAPI = Result {
//                try JSONDecoder().decode(
//                    OpenAPI.Document.self,
//                    from: Data(contentsOf: URL(string: "https://developer.atlassian.com/cloud/jira/platform/swagger.v3.json")!)
//                )
//            }
//        }
//    }
//
//    func test_successfulParse() {
//        switch atlassianAPI {
//        case nil:
//            XCTFail("Did not attempt to pull Atlassian API documentation like expected.")
//        case .failure(let error as DecodingError):
//            let codingPath: String
//            let debugDetails: String
//            switch error {
//            case .dataCorrupted(let context), .keyNotFound(_, let context), .typeMismatch(_, let context), .valueNotFound(_, let context):
//                codingPath = context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
//                debugDetails = context.debugDescription
//            @unknown default:
//                codingPath = ""
//                debugDetails = ""
//            }
//            XCTFail(error.failureReason ?? error.errorDescription ?? error.localizedDescription + "\n coding path: " + codingPath + "\n debug description: " + debugDetails)
//        case .failure(let error):
//            XCTFail(error.localizedDescription)
//        case .success:
//            break
//        }
//    }
//
//    func test_successfullyParsedBasicMetadata() {
//        guard let apiDoc = apiDoc else { return }
//
//        XCTAssertFalse(apiDoc.info.title.isEmpty)
//        XCTAssertFalse(apiDoc.info.description?.isEmpty ?? true)
//        XCTAssertFalse(apiDoc.info.contact?.email?.isEmpty ?? true)
//        XCTAssertFalse(apiDoc.tags?.isEmpty ?? true)
//    }
//}
