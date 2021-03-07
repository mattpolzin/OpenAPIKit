//
//  ParameterContextTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit30

final class ParameterContextTests: XCTestCase {
    typealias Context = OpenAPI.Parameter.Context

    func test_query() {
        let t1: Context = .query
        XCTAssertEqual(t1, Context.query(required: false, allowEmptyValue: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inQuery)
        XCTAssertFalse(t1.inHeader)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inCookie)

        let t2: Context = .query(allowEmptyValue: true)
        XCTAssertEqual(t2, Context.query(required: false, allowEmptyValue: true))
        XCTAssertFalse(t2.required)
        XCTAssertTrue(t2.inQuery)
        XCTAssertFalse(t2.inHeader)
        XCTAssertFalse(t2.inPath)
        XCTAssertFalse(t2.inCookie)

        let t3: Context = .query(required: true)
        XCTAssertEqual(t3, Context.query(required: true, allowEmptyValue: false))
        XCTAssertTrue(t3.required)
        XCTAssertTrue(t3.inQuery)
        XCTAssertFalse(t3.inHeader)
        XCTAssertFalse(t3.inPath)
        XCTAssertFalse(t3.inCookie)
    }

    func test_header() {
        let t1: Context = .header
        XCTAssertEqual(t1, Context.header(required: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inHeader)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inCookie)

        XCTAssertTrue(Context.header(required: true).required)
    }

    func test_cookie() {
        let t1: Context = .cookie
        XCTAssertEqual(t1, Context.cookie(required: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inCookie)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inHeader)

        XCTAssertTrue(Context.cookie(required: true).required)
    }

    func test_path() {
        let t1: Context = .path
        XCTAssertTrue(t1.required)
        XCTAssertTrue(t1.inPath)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inCookie)
        XCTAssertFalse(t1.inHeader)
    }

    func test_location() {
        let t1: Context = .cookie
        let t2: Context = .header
        let t3: Context = .path
        let t4: Context = .query

        XCTAssertEqual(t1.location, .cookie)
        XCTAssertEqual(t2.location, .header)
        XCTAssertEqual(t3.location, .path)
        XCTAssertEqual(t4.location, .query)

        XCTAssertEqual(t1.location.rawValue, "cookie")
        XCTAssertEqual(t2.location.rawValue, "header")
        XCTAssertEqual(t3.location.rawValue, "path")
        XCTAssertEqual(t4.location.rawValue, "query")
    }
}
