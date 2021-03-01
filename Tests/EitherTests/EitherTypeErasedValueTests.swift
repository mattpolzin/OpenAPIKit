//
//  EitherTypeErasedValueTests.swift
//  
//
//  Created by Mathew Polzin on 11/4/19.
//

import XCTest
import OpenAPIKitCore

final class EitherTypeErasedValueTests: XCTestCase {

    func test_either() {
        let t1 = Either<String, Void>("hello")
        XCTAssert(type(of: t1.value) == String.self)
        XCTAssertEqual(t1.value as? String, "hello")

        let t2 = Either<Void, String>("hello")
        XCTAssert(type(of: t2.value) == String.self)
        XCTAssertEqual(t2.value as? String, "hello")
    }
}
