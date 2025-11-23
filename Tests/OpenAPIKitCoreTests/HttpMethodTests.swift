//
//  HttpTypeTests.swift
//

import OpenAPIKitCore
import XCTest

final class HttpMethodTests: XCTestCase {
    func test_builtinInits() {
        let methods: [Shared.HttpMethod] = [
            .get,
            .post,
            .patch,
            .put,
            .delete,
            .head,
            .options,
            .trace,
            .query
        ]

        XCTAssertEqual(methods, [
            .builtin(.get),
            .builtin(.post),
            .builtin(.patch),
            .builtin(.put),
            .builtin(.delete),
            .builtin(.head),
            .builtin(.options),
            .builtin(.trace),
            .builtin(.query)
        ])

        XCTAssertEqual(methods.map(\.rawValue), [
            "GET",
            "POST",
            "PATCH",
            "PUT",
            "DELETE",
            "HEAD",
            "OPTIONS",
            "TRACE",
            "QUERY"
        ])

        XCTAssertEqual(methods, [
            "GET",
            "POST",
            "PATCH",
            "PUT",
            "DELETE",
            "HEAD",
            "OPTIONS",
            "TRACE",
            "QUERY"
        ])

        XCTAssertEqual(methods.map(Optional.some), [
            .init(rawValue: "GET"),
            .init(rawValue: "POST"),
            .init(rawValue: "PATCH"),
            .init(rawValue: "PUT"),
            .init(rawValue: "DELETE"),
            .init(rawValue: "HEAD"),
            .init(rawValue: "OPTIONS"),
            .init(rawValue: "TRACE"),
            .init(rawValue: "QUERY")
        ])
    }

    func test_otherInit() {
        let otherMethod = Shared.HttpMethod.other("LINK")
        XCTAssertEqual(otherMethod, Shared.HttpMethod(rawValue: "LINK"))
        XCTAssertEqual(otherMethod, "LINK")
        XCTAssertEqual(otherMethod.rawValue, "LINK")
    }

    func test_knownBadCasing() {
        XCTAssertNil(Shared.HttpMethod(rawValue: "link"))
        XCTAssertEqual(Shared.HttpMethod.other("link"), "link")
        XCTAssertEqual(Shared.HttpMethod.problem(with: "link"), "'link' must be uppercased")
    }

    func test_encoding() throws {
        let methods: [Shared.HttpMethod] = [
            .get,
            .post,
            .patch,
            .put,
            .delete,
            .head,
            .options,
            .trace,
            .query,
            "LINK"
        ]
        
        for method in methods {
            let encoded = try orderUnstableTestStringFromEncoding(of: method)

            XCTAssertEqual(encoded, "\"\(method.rawValue)\"")
        }
    }

    func test_decoding() throws {
        let methods: [String] = [
            "GET",
            "POST",
            "PATCH",
            "PUT",
            "DELETE",
            "HEAD",
            "OPTIONS",
            "TRACE",
            "QUERY",
            "LINK"
        ]
        
        for method in methods {
            let decoded = try orderUnstableDecode(Shared.HttpMethod.self, from: "\"\(method)\"".data(using: .utf8)!)

            XCTAssertEqual(decoded, Shared.HttpMethod(rawValue: method))
        }
    }
}
