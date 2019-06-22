import XCTest

import OpenAPITests

var tests = [XCTestCaseEntry]()
tests += OpenAPITests.__allTests()

XCTMain(tests)
