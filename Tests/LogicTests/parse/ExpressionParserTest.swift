import XCTest
import Foundation
@testable import Logic

class ExpressionParserTest: XCTestCase {
	func tokenizeTest() {
		let th = LogicTheory()
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()

		//read just one sentense
		var stream = LogicStream.fromString("\"hello __1__ world\"")
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(1, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicSentense)
		XCTAssertEqual("\"hello __1__ world \"", (tokenArray[0] as! LogicSentense).toJson())
		XCTAssertEqual(nil, next)
		XCTAssertFalse(stream.hasError())

		//read just one string, on sentense, and two operators no spaces
		stream = LogicStream.fromString("something99\"hello __1__ world\"..")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(4, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicMember)
		XCTAssertTrue(tokenArray[1] is LogicSentense)
		XCTAssertTrue(tokenArray[2] is LogicMemberAccess)
		XCTAssertTrue(tokenArray[3] is LogicMemberAccess)
		XCTAssertEqual("something99", (tokenArray[0] as! LogicMember).name)
		XCTAssertEqual(nil, next)
		XCTAssertFalse(stream.hasError())

		//read just one string, on sentense, and two operators with spaces
		stream = LogicStream.fromString("( something99  \"hello __1__ world\" .  )  ")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(3, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicMember)
		XCTAssertTrue(tokenArray[1] is LogicSentense)
		XCTAssertTrue(tokenArray[2] is LogicMemberAccess)
		XCTAssertEqual("something99", (tokenArray[0] as! LogicMember).name)
		XCTAssertEqual(nil, next)
		XCTAssertFalse(stream.hasError())

		//test end of phrase
		stream = LogicStream.fromString("an object {key:\"1 __1__ 2\"}h; ..; something else;V")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(4, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicMember)
		XCTAssertTrue(tokenArray[1] is LogicMember)
		XCTAssertTrue(tokenArray[2] is LogicObject)
		XCTAssertTrue(tokenArray[3] is LogicMember)
		XCTAssertEqual("an", (tokenArray[0] as! LogicMember).name)
		XCTAssertEqual("object", (tokenArray[1] as! LogicMember).name)
		XCTAssertEqual("{\"key\":\"1 __1__ 2 \",}", (tokenArray[2] as! LogicObject).toJson())
		XCTAssertEqual("h", (tokenArray[3] as! LogicMember).name)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual(";", next)


		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(2, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicMemberAccess)
		XCTAssertTrue(tokenArray[1] is LogicMemberAccess)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual(";", next)

		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertEqual(2, tokenArray.count)
		XCTAssertTrue(tokenArray[0] is LogicMember)
		XCTAssertTrue(tokenArray[1] is LogicMember)
		XCTAssertEqual("something", (tokenArray[0] as! LogicMember).name)
		XCTAssertEqual("else", (tokenArray[1] as! LogicMember).name)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual(";", next)
		XCTAssertEqual("V", stream.next())


		//REVERSE POLISH NOTATION FAIL CASES
		stream = LogicStream.fromString("( something99  \"hello __1__ world\" .    ")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertTrue(stream.hasError())

		stream = LogicStream.fromString("something99  \"hello __1__ world\" .)    ")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		XCTAssertTrue(stream.hasError())
	}


	func calculateResultTest() {
		let th = LogicTheory()
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()

		//calculate single value
		var stream = LogicStream.fromString("\"hello __1__ world\"")
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		var result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertTrue(result as! AnyObject === tokenArray[0] as AnyObject)
		XCTAssertFalse(stream.hasError())

		//add this object to the theory
		th.putVar("key", result)

		//calculate single value
		stream = LogicStream.fromString("key")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __1__ world \"", result!.toJson())

		//calculate logic phrase
		stream = LogicStream.fromString("key.L")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello \"", result!.toJson())

		stream = LogicStream.fromString("key.R")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"world \"", result!.toJson())
	}

	func testAssignmants() {
		let th = LogicTheory()
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"key={ };" +
			"key.field = \"hello __2__ world\";" +
			"key.field2 = key.field;" +
			"key.newField = key.newField2 = {};" +
			"key.newField.child = \"1 2 __4__ 3\";"
		)

		//key = {}
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		var result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("{}", result!.toJson())
		XCTAssertNotNil(th.getVar("key"))
		XCTAssertEqual("{}", th.getVar("key")!.toJson())

		//key.field = \"hello __2__ world;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __2__ world \"", result!.toJson())
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVar("field"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVar("field")!.toJson(), "\"hello __2__ world \"")

		//key.field2 = key.field;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __2__ world \"", result!.toJson())
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVar("field2"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVar("field2")!.toJson(), "\"hello __2__ world \"")

		//key.newField = key.neyField2 = {};
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("{}", result!.toJson())
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVar("newField"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVar("newField")!.toJson(), "{}")
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVar("newField2"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVar("newField2")!.toJson(), "{}")

		//key.newField.child = \"1 2 __4__ 3\";
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"1 2 __4__ 3 \"", result!.toJson())
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVarPath("newField", "child"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVarPath("newField", "child")!.toJson(), "\"1 2 __4__ 3 \"")
		XCTAssertNotNil((th.getVar("key") as! LogicObject).getVarPath("newField2", "child"))
		XCTAssertEqual((th.getVar("key") as! LogicObject).getVarPath("newField2", "child")!.toJson(), "\"1 2 __4__ 3 \"")
	}


	static var allTests = [
        ("tokenizeTest", tokenizeTest),
		("calculateResultTest", calculateResultTest),
		("testAssignmants", testAssignmants),
    ]
}
