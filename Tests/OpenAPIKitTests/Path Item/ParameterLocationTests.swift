//
//  ParameterLocationTests.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import XCTest
import OpenAPIKit

final class ParameterLocationTests: XCTestCase {
    typealias Location = OpenAPI.PathItem.Parameter.Location

    func test_query() {
        let t1: Location = .query
        XCTAssertEqual(t1, Location.query(required: false, allowEmptyValue: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inQuery)
        XCTAssertFalse(t1.inHeader)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inCookie)

        let t2: Location = .query(allowEmptyValue: true)
        XCTAssertEqual(t2, Location.query(required: false, allowEmptyValue: true))
        XCTAssertFalse(t2.required)
        XCTAssertTrue(t2.inQuery)
        XCTAssertFalse(t2.inHeader)
        XCTAssertFalse(t2.inPath)
        XCTAssertFalse(t2.inCookie)

        let t3: Location = .query(required: true)
        XCTAssertEqual(t3, Location.query(required: true, allowEmptyValue: false))
        XCTAssertTrue(t3.required)
        XCTAssertTrue(t3.inQuery)
        XCTAssertFalse(t3.inHeader)
        XCTAssertFalse(t3.inPath)
        XCTAssertFalse(t3.inCookie)
    }

    func test_header() {
        let t1: Location = .header
        XCTAssertEqual(t1, Location.header(required: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inHeader)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inCookie)
    }

    func test_cookie() {
        let t1: Location = .cookie
        XCTAssertEqual(t1, Location.cookie(required: false))
        XCTAssertFalse(t1.required)
        XCTAssertTrue(t1.inCookie)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inPath)
        XCTAssertFalse(t1.inHeader)
    }

    func test_path() {
        let t1: Location = .path
        XCTAssertTrue(t1.required)
        XCTAssertTrue(t1.inPath)
        XCTAssertFalse(t1.inQuery)
        XCTAssertFalse(t1.inCookie)
        XCTAssertFalse(t1.inHeader)
    }
}
