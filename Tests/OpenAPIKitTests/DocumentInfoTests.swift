//
//  DocumentInfoTests.swift
//  OpenAPIKitTests
//
//  Created by Mathew Polzin on 10/18/19.
//

import XCTest
import OpenAPIKit

final class DocumentInfoTests: XCTestCase {
    func test_init() {
        let _ = OpenAPI.Document.Info(title: "title", version: "1.0")

        let _ = OpenAPI.Document.Info(
            title: "title",
            description: "description",
            termsOfService: URL(string: "http://google.com")!,
            contact: .init(name: "contact"),
            license: .MIT,
            version: "1.0"
        )
    }

    func test_initLicense() {
        let _ = OpenAPI.Document.Info.License(name: "license")
        let _ = OpenAPI.Document.Info.License(name: "license", url: URL(string: "http://google.com")!)

        let _ = OpenAPI.Document.Info.License.MIT
        let _ = OpenAPI.Document.Info.License.MIT(url: URL(string: "http://google.com")!)
        let _ = OpenAPI.Document.Info.License.apache2
        let _ = OpenAPI.Document.Info.License.apache2(url: URL(string: "http://google.com")!)
    }
}

// MARK: - Codable
extension DocumentInfoTests {
    func test_license_encode() {
        let license = OpenAPI.Document.Info.License.MIT

        let encodedLicense = try! testStringFromEncoding(of: license)

        XCTAssertEqual(encodedLicense,
"""
{
  "name" : "MIT"
}
"""
        )
    }

    func test_license_decode() {
        let licenseData =
"""
{
  "name" : "MIT"
}
""".data(using: .utf8)!
        let license = try! testDecoder.decode(OpenAPI.Document.Info.License.self, from: licenseData)

        XCTAssertEqual(
            license,
            .MIT
        )
    }

    func test_license_withUrl_encode() {
        let license = OpenAPI.Document.Info.License.MIT(url: URL(string: "http://google.com")!)

        let encodedLicense = try! testStringFromEncoding(of: license)

        XCTAssertEqual(encodedLicense,
"""
{
  "name" : "MIT",
  "url" : "http:\\/\\/google.com"
}
"""
        )
    }

    func test_license_withUrl_decode() {
        let licenseData =
"""
{
  "name" : "MIT",
  "url" : "http://google.com"
}
""".data(using: .utf8)!
        let license = try! testDecoder.decode(OpenAPI.Document.Info.License.self, from: licenseData)

        XCTAssertEqual(
            license,
            .MIT(url: URL(string: "http://google.com")!)
        )
    }

    // TODO: write the rest of the tests
}
