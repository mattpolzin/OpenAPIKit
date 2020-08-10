//
//  ServerURLTests.swift
//  
//
//  Created by Mathew Polzin on 8/10/20.
//

import Foundation
import XCTest
#warning("Don't leave at @testable import")
@testable import OpenAPIKit

final class ServerURLTests: XCTestCase {
    func test_tmp() throws {
        let urls = [
            "website.com",
            "https://website.com",
            "https://website.com/a/path",
            "https://website.com:1234/a/path",
            "https://user:password@website.com:1234/a/path",
            "https://user:password@website.com:1234/a/path?query=value1&other=value2"
        ]

        let expectedTokens: [[OpenAPI.ServerURL.Token]] = [
            [.constant("website"), .separator(.period), .constant("com")],
            [.constant("https"), .separator(.scheme), .constant("website"), .separator(.period), .constant("com")],
            [.constant("https"), .separator(.scheme), .constant("website"), .separator(.period), .constant("com"), .separator(.slash), .constant("a"), .separator(.slash), .constant("path")],
            [.constant("https"), .separator(.scheme), .constant("website"), .separator(.period), .constant("com"), .separator(.colon), .constant("1234"), .separator(.slash), .constant("a"), .separator(.slash), .constant("path")],
            [.constant("https"), .separator(.scheme), .constant("user"), .separator(.colon), .constant("password"), .separator(.at), .constant("website"), .separator(.period), .constant("com"), .separator(.colon), .constant("1234"), .separator(.slash), .constant("a"), .separator(.slash), .constant("path")],
            [.constant("https"), .separator(.scheme), .constant("user"), .separator(.colon), .constant("password"), .separator(.at), .constant("website"), .separator(.period), .constant("com"), .separator(.colon), .constant("1234"), .separator(.slash), .constant("a"), .separator(.slash), .constant("path"), .separator(.question), .constant("query=value1"),.separator(.ampersand), .constant("other=value2")]
        ]

        for (url, expected) in zip(urls, expectedTokens) {
            XCTAssertEqual(
                try OpenAPI.ServerURL.scan(url, partialToken: nil, from: url[...], addingTo: []),
                expected
            )
        }
    }
}
