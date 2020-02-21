import XCTest

import postTests

var tests = [XCTestCaseEntry]()
tests += postTests.allTests()
XCTMain(tests)
