//
//  ContentTypeTests.swift
//  
//
//  Created by Mathew Polzin on 12/20/21.
//

import OpenAPIKitCore
import XCTest

final class ContentTypeTests: XCTestCase {
    func test_badContentType() {
        let bad = OpenAPI.ContentType(rawValue: "not a content type")
        XCTAssertEqual(
            bad?.warnings[0].localizedDescription,
            "\'not a content type\' could not be parsed as a Content Type. Content Types should have the format \'<type>/<subtype>\'"
        )
    }

    func test_contentTypeStringReflexivity() {
        let types: [OpenAPI.ContentType] = [
            .bmp,
            .css,
            .csv,
            .form,
            .html,
            .javascript,
            .jpg,
            .json,
            .jsonapi,
            .mov,
            .mp3,
            .mp4,
            .mpg,
            .multipartForm,
            .otf,
            .pdf,
            .rar,
            .rtf,
            .tar,
            .tif,
            .ttf,
            .txt,
            .woff,
            .woff2,
            .xml,
            .yaml,
            .zip,
            .anyApplication,
            .anyAudio,
            .anyImage,
            .anyFont,
            .anyText,
            .anyVideo,
            .any,
            .other("application/custom")
        ]

        for type in types {
            XCTAssertEqual(type, OpenAPI.ContentType(rawValue: type.rawValue))
        }
    }

    func test_goodParam() {
        let type = OpenAPI.ContentType.init(rawValue: "text/html; charset=utf8")
        XCTAssertEqual(type?.warnings.count, 0)
        XCTAssertEqual(type?.rawValue, "text/html; charset=utf8")
    }

    func test_multipleParams() {
        let type = OpenAPI.ContentType.init(rawValue: "my/type; some=thing; another=else")
        XCTAssertEqual(type?.warnings.count, 0)
        XCTAssert(type?.rawValue == "my/type; another=else; some=thing")
    }

    func test_oneBadParam() {
        let type = OpenAPI.ContentType.init(rawValue: "my/type; some: thing; another=else")
        XCTAssertEqual(type?.warnings.count, 1)
        XCTAssertEqual(type?.warnings.first?.localizedDescription, "Could not parse a Content Type parameter from \' some: thing\'")
        XCTAssert(type?.rawValue == "my/type; another=else")
    }
}
