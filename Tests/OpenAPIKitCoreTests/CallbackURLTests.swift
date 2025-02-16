//
//  CallbackURLTests.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 2/15/25.
//

import OpenAPIKitCore
import XCTest

final class CallbackURLTests: XCTestCase {
    func testInit() {
        let plainUrl = Shared.CallbackURL(url: URL(string: "https://hello.com")!)
        XCTAssertEqual(plainUrl.url, URL(string: "https://hello.com")!)
        XCTAssertEqual(plainUrl.template.variables.count, 0)
        XCTAssertEqual(plainUrl.rawValue, "https://hello.com")

        let templateUrl = Shared.CallbackURL(rawValue: "https://hello.com/item/{$request.path.id}")
        XCTAssertEqual(templateUrl?.template.variables, ["$request.path.id"])
    }

    func testEncode() throws {
        let url = Shared.CallbackURL(rawValue: "https://hello.com/item/{$request.path.id}")

        let result = try orderUnstableTestStringFromEncoding(of: url)

        assertJSONEquivalent(
          result,
              """
              "https:\\/\\/hello.com\\/item\\/{$request.path.id}"
              """
        )
    }

    func testDecode() throws {
        let json = #""https://hello.com/item/{$request.path.id}""#
        let data = json.data(using: .utf8)!

        let url = try orderUnstableDecode(Shared.CallbackURL.self, from: data)

        XCTAssertEqual(url, Shared.CallbackURL(rawValue: "https://hello.com/item/{$request.path.id}"))
    }
}
