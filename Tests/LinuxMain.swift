import XCTest
@testable import LogicTests

XCTMain([
    testCase(TheoryTest.allTests),
	testCase(PhraseTest.allTests),
	testCase(SentenseTest.allTests),
])