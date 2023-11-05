//
//  URLTemplateTests.swift
//  
//
//  Created by Mathew Polzin on 8/13/20.
//

import Foundation
import OpenAPIKitCore
import XCTest

final class URLTemplateTests: XCTestCase {
    func test_init() {
        XCTAssertNotNil(URLTemplate(rawValue: "https://website.com"))
        XCTAssertEqual(URLTemplate(rawValue: "https://website.com"), URLTemplate(url: URL(string: "https://website.com")!))
        XCTAssertNotNil(URLTemplate(rawValue: "{scheme}://website.com"))
    }

    func test_urlAccess() {
        let t1 = URLTemplate(rawValue: "https://website.com")
        let t2 = URLTemplate(rawValue: "{scheme}://website.com")

        XCTAssertEqual(t1?.url, URL(string: "https://website.com"))
        XCTAssertNil(t2?.url)
    }

    func test_absoluteString() {
        let t1 = URLTemplate(rawValue: "https://website.com")
        let t2 = URLTemplate(rawValue: "/a/relative/path")
        let t3 = URLTemplate(rawValue: "website.com?query=value")

        let t4 = URLTemplate(rawValue: "{scheme}://website.com/{path}")

        XCTAssertEqual(t1?.absoluteString, URL(string: "https://website.com")?.absoluteString)
        XCTAssertEqual(t2?.absoluteString, URL(string: "/a/relative/path")?.absoluteString)
        XCTAssertEqual(t3?.absoluteString, URL(string: "website.com?query=value")?.absoluteString)

        XCTAssertEqual(t4?.absoluteString, "{scheme}://website.com/{path}")
    }

    func test_componentErrors() {
        // unclosed variable brace
        XCTAssertNil(URLTemplate(rawValue: "{scheme://website.com"))
        XCTAssertThrowsError(try URLTemplate(templateString: "{scheme://website.com")) { error in
            XCTAssertEqual(
                String(describing: error),
                "An opening brace with no closing brace was found. The portion of the URL following the opening brace was 'scheme://website.com'"
            )
        }

        // unclosed variable brace (at end)
        XCTAssertNil(URLTemplate(rawValue: "https://website.com/{"))
        XCTAssertThrowsError(try URLTemplate(templateString: "https://website.com/{")) { error in
            XCTAssertEqual(
                String(describing: error),
                "An opening brace with no closing brace was found. The portion of the URL following the opening brace was ''"
            )
        }

        // unopened variable brace
        XCTAssertNil(URLTemplate(rawValue: "scheme}://website.com"))
        XCTAssertThrowsError(try URLTemplate(templateString: "scheme}://website.com")) { error in
            XCTAssertEqual(
                String(describing: error),
                "A closing brace with no opening brace was found. The portion of the URL preceeding the closing brace was 'scheme'"
            )
        }

        // nested variable brace
        XCTAssertNil(URLTemplate(rawValue: "{scheme}://website.com/{path{var}}"))
        XCTAssertThrowsError(try URLTemplate(templateString: "{scheme}://website.com/{path{var}}")) { error in
            XCTAssertEqual(
                String(describing: error),
                "An opening brace within another variable was found. The portion of the URL following the first opening brace up until the second opening brace was 'path'"
            )
        }

        // nested variable brace (doubled-up)
        XCTAssertNil(URLTemplate(rawValue: "{{scheme}}://website.com/{path}"))
        XCTAssertThrowsError(try URLTemplate(templateString: "{{scheme}}://website.com/{path}")) { error in
            XCTAssertEqual(
                String(describing: error),
                "An opening brace within another variable was found. The portion of the URL following the first opening brace up until the second opening brace was ''"
            )
        }
    }

    func test_componentSuccesses() {
        XCTAssertEqual(
            URLTemplate(rawValue: "{url}")?.components,
            [.variable(name: "url")]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{front}{back}")?.components,
            [.variable(name: "front"), .variable(name: "back")]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com")?.components,
            [.variable(name: "scheme"), .constant("://website.com")]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}")?.components,
            [.variable(name: "scheme"), .constant("://website.com/"), .variable(name: "path")]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "https://website.com/{path}?search=hello&page=2")?.components,
            [.constant("https://website.com/"), .variable(name: "path"), .constant("?search=hello&page=2")]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}?search={query}&page={page}")?.components,
            [
                .variable(name: "scheme"),
                .constant("://website.com/"),
                .variable(name: "path"),
                .constant("?search="),
                .variable(name: "query"),
                .constant("&page="),
                .variable(name: "page")
            ]
        )
    }

    func test_componentRawValues() {
        XCTAssertEqual(
            URLTemplate(rawValue: "{url}")?.components.map { $0.rawValue },
            ["{url}"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{front}{back}")?.components.map { $0.rawValue },
            ["{front}", "{back}"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com")?.components.map { $0.rawValue },
            ["{scheme}", "://website.com"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}")?.components.map { $0.rawValue },
            ["{scheme}", "://website.com/", "{path}"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "https://website.com/{path}?search=hello&page=2")?.components.map { $0.rawValue },
            ["https://website.com/", "{path}", "?search=hello&page=2"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}?search={query}&page={page}")?.components.map { $0.rawValue },
            [
                "{scheme}",
                "://website.com/",
                "{path}",
                "?search=",
                "{query}",
                "&page=",
                "{page}"
            ]
        )
    }

    func test_variableAccessor() {
        XCTAssertEqual(
            URLTemplate(rawValue: "{url}")?.variables,
            ["url"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{front}{back}")?.variables,
            ["front", "back"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com")?.variables,
            ["scheme"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}")?.variables,
            ["scheme", "path"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "https://website.com/{path}?search=hello&page=2")?.variables,
            ["path"]
        )

        XCTAssertEqual(
            URLTemplate(rawValue: "{scheme}://website.com/{path}?search={query}&page={page}")?.variables,
            [
                "scheme",
                "path",
                "query",
                "page"
            ]
        )
    }

    func test_componentsFromRawValues() {
        XCTAssertEqual(
            [URLTemplate.Component(rawValue: "{url}")],
            [.variable(name: "url")]
        )

        XCTAssertEqual(
            [URLTemplate.Component(rawValue: "{front}"), URLTemplate.Component(rawValue: "{back}")],
            [.variable(name: "front"), .variable(name: "back")]
        )

        XCTAssertEqual(
            [URLTemplate.Component(rawValue: "{scheme}"), URLTemplate.Component(rawValue: "://website.com")],
            [.variable(name: "scheme"), .constant("://website.com")]
        )

        XCTAssertEqual(
            [URLTemplate.Component(rawValue: "{scheme}"), URLTemplate.Component(rawValue: "://website.com/"), URLTemplate.Component(rawValue: "{path}")],
            [.variable(name: "scheme"), .constant("://website.com/"), .variable(name: "path")]
        )

        XCTAssertEqual(
            [URLTemplate.Component(rawValue: "https://website.com/"), URLTemplate.Component(rawValue: "{path}"), URLTemplate.Component(rawValue: "?search=hello&page=2")],
            [.constant("https://website.com/"), .variable(name: "path"), .constant("?search=hello&page=2")]
        )

        XCTAssertEqual(
            [
                URLTemplate.Component(rawValue: "{scheme}"),
                URLTemplate.Component(rawValue: "://website.com/"),
                URLTemplate.Component(rawValue: "{path}"),
                URLTemplate.Component(rawValue: "?search="),
                URLTemplate.Component(rawValue: "{query}"),
                URLTemplate.Component(rawValue: "&page="),
                URLTemplate.Component(rawValue: "{page}")
            ],
            [
                .variable(name: "scheme"),
                .constant("://website.com/"),
                .variable(name: "path"),
                .constant("?search="),
                .variable(name: "query"),
                .constant("&page="),
                .variable(name: "page")
            ]
        )
    }
}

// MARK: - Replacing Variables
extension URLTemplateTests {
    func test_noVariables() {
        let t = URLTemplate(rawValue: "https://website.com")
        let replaced1 = t?.replacing([:])
        let replaced2 = t?.replacing(["not in there": "value"])

        XCTAssertNotNil(t)
        XCTAssertEqual(t, replaced1)
        XCTAssertEqual(t, replaced2)
    }

    func test_replacingNothing() {
        let t = URLTemplate(rawValue: "{scheme}://{website}.com/{path}")
        let replaced = t?.replacing([:])

        XCTAssertNotNil(t)
        XCTAssertEqual(replaced?.components, [
                        .variable(name: "scheme"),
                        .constant("://"),
                        .variable(name: "website"),
                        .constant(".com/"),
                        .variable(name: "path")
        ])
    }

    func test_variedVariablePlacement() {
        let t1 = URLTemplate(rawValue: "{scheme}://website.com")
        let replaced1 = t1?.replacing(["scheme": "https"])
        let t2 = URLTemplate(rawValue: "https://{website}.com")
        let replaced2 = t2?.replacing(["website": "mysite"])
        let t3 = URLTemplate(rawValue: "https://website.{domain_space}")
        let replaced3 = t3?.replacing(["domain_space": "org"])

        XCTAssertNotNil(t1)
        XCTAssertNotNil(t2)
        XCTAssertNotNil(t3)

        XCTAssertEqual(replaced1?.components, [.constant("https://website.com")])
        XCTAssertEqual(replaced2?.components, [.constant("https://mysite.com")])
        XCTAssertEqual(replaced3?.components, [.constant("https://website.org")])
    }

    func test_replacingMany() {
        let t = URLTemplate(rawValue: "{scheme}://{website}.com/{path}")
        let replaced = t?.replacing(["scheme": "https", "website": "mysite", "path": "welcome"])

        XCTAssertEqual(replaced?.components, [.constant("https://mysite.com/welcome")])
    }

    func test_partialReplacement() {
        let t = URLTemplate(rawValue: "{scheme}://{website}.com/{path}")
        let replaced = t?.replacing(["website": "mysite"])

        XCTAssertEqual(replaced?.components, [.variable(name: "scheme"), .constant("://mysite.com/"), .variable(name: "path")])
    }
}

// MARK: - Codable
extension URLTemplateTests {
    func test_encode() throws {
        let t1 = TemplatedURLWrapper(
            url: URLTemplate(rawValue: "https://website.com")
        )

        assertJSONEquivalent(
            try orderUnstableTestStringFromEncoding(of: t1),
            """
            {
              "url" : "https:\\/\\/website.com"
            }
            """
        )
    }

    func test_decode() throws {
        let t1Data = """
        {
          "url": "https://website.com"
        }
        """.data(using: .utf8)!

        let t1 = try orderUnstableDecode(TemplatedURLWrapper.self, from: t1Data)

        XCTAssertEqual(
            t1.url,
            URLTemplate(rawValue: "https://website.com")
        )
    }

    func test_encode_withVariables() throws {
        let t1 = TemplatedURLWrapper(
            url: URLTemplate(rawValue: "{scheme}://{host}.com")
        )

        assertJSONEquivalent(
            try orderUnstableTestStringFromEncoding(of: t1),
            """
            {
              "url" : "{scheme}:\\/\\/{host}.com"
            }
            """
        )
    }

    func test_decode_withVariables() throws {
        let t1Data = """
        {
          "url": "{scheme}://{host}.com"
        }
        """.data(using: .utf8)!

        let t1 = try orderUnstableDecode(TemplatedURLWrapper.self, from: t1Data)

        XCTAssertEqual(
            t1.url,
            URLTemplate(rawValue: "{scheme}://{host}.com")
        )
    }
}

fileprivate struct TemplatedURLWrapper: Codable {
    let url: URLTemplate?
}
