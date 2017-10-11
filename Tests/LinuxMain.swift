import XCTest
@testable import LogicTests

XCTMain([
    testCase(TheoryTest.allTests),
	testCase(PhraseTest.allTests),
	testCase(SentenseTest.allTests),
	testCase(LogicObjectTest.allTests),
	testCase(LogicStreamTest.allTests),
	testCase(AxiomParserTest.allTests),
	testCase(ObjectParserTest.allTests),
	testCase(ExpressionParserTest.allTests),
	testCase(LogicalOperatorsTest.allTests),
	testCase(VariableDeclarationParserTest.allTests),
	testCase(CommandParserTest.allTests),
])
