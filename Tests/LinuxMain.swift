import XCTest
@testable import LogicTests

XCTMain([
    testCase(TheoryTest.allTests),
	testCase(PhraseTest.allTests),
	testCase(SentenseTest.allTests),
	testCase(LogicObjectTest.allTests),
	testCase(ProofTest.allTests),
	testCase(LogicStreamTest.allTests),
	testCase(AxiomParserTest.allTests)
])
