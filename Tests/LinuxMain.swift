import XCTest

import OpenAPITests

var tests = [XCTestCaseEntry]()
tests += OpenAPITests.allTests()
XCTMain(tests)
