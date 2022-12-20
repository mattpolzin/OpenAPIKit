//
//  DocumentConversionTests.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

import OpenAPIKit30
import OpenAPIKit
import OpenAPIKitCompat
import XCTest

final class DocumentConversionTests: XCTestCase {
    func test_barebonesDocument() {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(title: "Hello World", version: "1.0.1"),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        assertEqualOldToNew(newDoc, oldDoc)
    }

    func test_fullInfo() {
        let oldDoc = OpenAPIKit30.OpenAPI.Document(
            info: .init(
                title: "Hello World",
                description: "described",
                termsOfService: URL(string: "https://website.com"),
                contact: .init(name: "Me", url: URL(string: "https://website.com"), email: "me@website.com", vendorExtensions: ["x-test": 1]),
                license: .init(name: "MIT-not", url: URL(string: "https://website.com"), vendorExtensions: ["x-two": 2.0]),
                version: "1.0.1",
                vendorExtensions: ["x-good" : "yeah"]
            ),
            servers: [],
            paths: [:],
            components: .noComponents
        )

        let newDoc = oldDoc.convert(to: .v3_1_0)

        assertEqualOldToNew(newDoc, oldDoc)
    }

    // TODO: more tests
}

fileprivate func assertEqualOldToNew(_ newDoc: OpenAPIKit.OpenAPI.Document, _ oldDoc: OpenAPIKit30.OpenAPI.Document) {
    XCTAssertEqual(newDoc.info.title, oldDoc.info.title)
    XCTAssertEqual(newDoc.info.version, oldDoc.info.version)
    XCTAssertEqual(newDoc.info.vendorExtensions, oldDoc.info.vendorExtensions)
    XCTAssertEqual(newDoc.info.description, oldDoc.info.description)
    XCTAssertEqual(newDoc.info.contact?.name, oldDoc.info.contact?.name)
    XCTAssertEqual(newDoc.info.contact?.url, oldDoc.info.contact?.url)
    XCTAssertEqual(newDoc.info.contact?.email, oldDoc.info.contact?.email)
    XCTAssertEqual(newDoc.info.contact?.vendorExtensions, oldDoc.info.contact?.vendorExtensions)
    XCTAssertEqual(newDoc.info.termsOfService, oldDoc.info.termsOfService)
    XCTAssertEqual(newDoc.info.license?.name, oldDoc.info.license?.name)
    XCTAssertEqual(newDoc.info.license?.identifier, oldDoc.info.license?.url.map(OpenAPIKit.OpenAPI.Document.Info.License.Identifier.url))
    XCTAssertEqual(newDoc.info.license?.vendorExtensions, oldDoc.info.license?.vendorExtensions)
    XCTAssertNil(newDoc.info.summary)

    // TODO: test the rest of equality.
}
