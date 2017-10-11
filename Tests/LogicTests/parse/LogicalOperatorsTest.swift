import XCTest
import Foundation
@testable import Logic

class LogicalOperatorsTest: XCTestCase {

	func testTheoremStart() {
		let th = LogicTheory()
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"vars = {};" +
			"vars.ax1 = \" hello __1__ world\";" +
			"vars.th ~ vars.ax1;" +
			"vars.th ~ vars.ax1.L;" +
			"vars.th ~ vars.ax1.R;" +
			"~ vars.ax1;" +
			"~ vars.notExists"
		)

		//vars = {};
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		var result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())

		//vars.ax1 = \" hello __1-- world\";
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())

		//vars.th ~ vars.ax1;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __1__ world \"", result!.toJson())
		XCTAssertEqual("\"hello __1__ world \"", (th.getVar("vars")! as! LogicObject).getVar("th")!.toJson())

		//vars.th ~ vars.ax1.L;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __1__ hello \"", result!.toJson())
		XCTAssertEqual("\"hello __1__ hello \"", (th.getVar("vars")! as! LogicObject).getVar("th")!.toJson())

		//vars.th ~ vars.ax1.R;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"world __1__ world \"", result!.toJson())
		XCTAssertEqual("\"world __1__ world \"", (th.getVar("vars")! as! LogicObject).getVar("th")!.toJson())



		//~ vars.ax1; THIS MUST FAIL, we do not have a poof scope
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertNil(result)
		XCTAssertTrue(stream.hasError())


		//~ vars.notExists THIS UST FAIL TOO
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, th, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, th)
		XCTAssertNil(result)
		XCTAssertTrue(stream.hasError())


		//test a Proof
		var proof = Proof(parent:th)
		XCTAssertNil(proof.getSentense())
		stream = LogicStream.fromString(
			"~ vars.ax1;" +
			"~ vars.ax1.L;" +
			"~vars.ax1.R;" + //no space...
			"~ vars.notExists"
		)

		//~ vars.ax1;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertNotNil(proof.getSentense())
		XCTAssertEqual("\"hello __1__ world \"", result!.toJson())
		XCTAssertEqual("\"hello __1__ world \"", proof.getSentense()!.toJson())

		//~ vars.ax1.L;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertNotNil(proof.getSentense())
		XCTAssertEqual("\"hello __1__ hello \"", result!.toJson())
		XCTAssertEqual("\"hello __1__ hello \"",  proof.getSentense()!.toJson())

		//vars.th ~ vars.ax1.L;
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(result)
		XCTAssertNotNil(proof.getSentense())
		XCTAssertEqual("\"world __1__ world \"", result!.toJson())
		XCTAssertEqual("\"world __1__ world \"",  proof.getSentense()!.toJson())

		//~ vars.notExists
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
		XCTAssertNil(result)
		//the following should not change, because operation failed...
		XCTAssertEqual("\"world __1__ world \"", proof.getSentense()!.toJson())
	}

	func replaceAllTest() {
		let th = LogicTheory()
		let proof = Proof(parent:th)
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()
		var result:LogicValue?

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"ax1 = \"N __1__ ( N + 0 )\";" +
			"th1 ~ ax1;" +
			"~ ax1;"
		)

		//execute the variable declaration commands
		for _ in 0..<3 {
			tokenArray.removeAll(keepingCapacity:true)
			ParsingUtils.skipWhite(stream, &next)
			ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
			result = ExpressionParser.calculateResult(tokenArray, stream, proof)
			XCTAssertFalse(stream.hasError())
		}

		//we are here:
		XCTAssertEqual("\"N __1__ ( N + 0 ) \"", proof.getVar("th1")!.toJson())

		//we do a move: th1 * ax1.L;
		stream = LogicStream.fromString("th1 * ax1.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + 0 ) __1__ ( ( N + 0 ) + 0 ) \"", proof.getVar("th1")!.toJson())

		//revert it:
		stream = LogicStream.fromString("th1 * ax1.R;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"N __1__ ( N + 0 ) \"", proof.getVar("th1")!.toJson())

		//test this
		XCTAssertEqual("\"N __1__ ( N + 0 ) \"", proof.getSentense()!.toJson())

		stream = LogicStream.fromString("* ax1.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + 0 ) __1__ ( ( N + 0 ) + 0 ) \"", proof.getSentense()!.toJson())


		//this should generate an error
		stream = LogicStream.fromString("th1 * ax1;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//this also
		stream = LogicStream.fromString("th1 *  \"N __1__ 1\";")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
	}


	func replaceFirstPhraseTest() {
		let th = LogicTheory()
		let proof = Proof(parent:th)
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var result:LogicValue?
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"ax1 = \"( N + N ) __1__ ( N * 2 )\";" +
			"ax2 = \"N __1__ ( N * 1 )\";" +
			"th1 ~ ax1;" +
			"~ ax1;"
		)

		//execute the variable declaration commands
		for _ in 0..<4 {
			tokenArray.removeAll(keepingCapacity:true)
			ParsingUtils.skipWhite(stream, &next)
			ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
			result = ExpressionParser.calculateResult(tokenArray, stream, proof)
			XCTAssertFalse(stream.hasError())
		}

		//we are here:
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 ) \"", proof.getVar("th1")!.toJson())

		//we do a move: th1 << ax1.L;
		stream = LogicStream.fromString("th1 << ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( ( N * 1 ) + ( N * 1 ) ) __1__ ( N * 2 ) \"", proof.getVar("th1")!.toJson())

		//revert it:
		stream = LogicStream.fromString("th1 << ax2.R;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 ) \"", proof.getVar("th1")!.toJson())

		//test this
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 ) \"", proof.getSentense()!.toJson())

		stream = LogicStream.fromString("<< ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( ( N * 1 ) + ( N * 1 ) ) __1__ ( N * 2 ) \"", proof.getSentense()!.toJson())


		//this should generate an error
		stream = LogicStream.fromString("th1 << ax2;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//this also
		stream = LogicStream.fromString("th1 <<  \"N __1__ 1\";")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
	}


	func replaceSecondPhraseTest() {
		let th = LogicTheory()
		let proof = Proof(parent:th)
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var result:LogicValue?
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"ax1 = \"( N + N ) __1__ ( N * 2 + N * 0 )\";" +
			"ax2 = \"N __1__ ( N * 1 )\";" +
			"th1 ~ ax1;" +
			"~ ax1;"
		)

		//execute the variable declaration commands
		for _ in 0..<4 {
			tokenArray.removeAll(keepingCapacity:true)
			ParsingUtils.skipWhite(stream, &next)
			ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
			result = ExpressionParser.calculateResult(tokenArray, stream, proof)
			XCTAssertFalse(stream.hasError())
		}

		//we are here:
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//we do a move: th1 * ax1.L;
		stream = LogicStream.fromString("th1>>ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( ( N * 1 ) * 2 + ( N * 1 ) * 0 ) \"", proof.getVar("th1")!.toJson())

		//revert it:
		stream = LogicStream.fromString("th1 >> ax2.R;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//test this
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getSentense()!.toJson())

		stream = LogicStream.fromString(">> ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( ( N * 1 ) * 2 + ( N * 1 ) * 0 ) \"", proof.getSentense()!.toJson())


		//this should generate an error
		stream = LogicStream.fromString("th1 >> ax1;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//this also
		stream = LogicStream.fromString("th1 >>  \"N __1__ 1\";")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
	}


	func replaceFirstSingleTest() {
		let th = LogicTheory()
		let proof = Proof(parent:th)
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var result:LogicValue?
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"ax1 = \"( N + N ) __1__ ( N * 2 + N * 0 )\";" +
			"ax2 = \"N __0__ ( N + 0 )\";" +
			"th1 ~ ax1;" +
			"~ ax1;"
		)

		//execute the variable declaration commands
		for _ in 0..<4 {
			tokenArray.removeAll(keepingCapacity:true)
			ParsingUtils.skipWhite(stream, &next)
			ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
			result = ExpressionParser.calculateResult(tokenArray, stream, proof)
			XCTAssertFalse(stream.hasError())
		}

		//we are here:
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//we do a move: th1 * ax1.L;
		stream = LogicStream.fromString("th1 <1 ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( ( N + 0 ) + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//revert it:
		stream = LogicStream.fromString("th1 <1 ax2.R;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//test this
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getSentense()!.toJson())

		stream = LogicStream.fromString("<3 ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + ( N + 0 ) ) __1__ ( N * 2 + N * 0 ) \"", proof.getSentense()!.toJson())


		//this should generate an error
		stream = LogicStream.fromString("th1 <1 ax1;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//this also
		stream = LogicStream.fromString("th1 <1  \"N __1__ 1\";")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//no position
		stream = LogicStream.fromString("th1 <  ax1.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
	}


	func replaceSecondSingleTest() {
		let th = LogicTheory()
		let proof = Proof(parent:th)
		var next:Character? = nil
		var tokenArray = [AnyObject]()
		var result:LogicValue?
		var ops = [LogicOperator]()

		//we will test each statement, one by one
		var stream = LogicStream.fromString(
			"ax1 = \"( N + N ) __1__ ( N * 2 + N * 0 )\";" +
			"ax2 = \"N __0__ ( N + 0 )\";" +
			"th1 ~ ax1;" +
			"~ ax1;"
		)

		//execute the variable declaration commands
		for _ in 0..<4 {
			tokenArray.removeAll(keepingCapacity:true)
			ParsingUtils.skipWhite(stream, &next)
			ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
			result = ExpressionParser.calculateResult(tokenArray, stream, proof)
			XCTAssertFalse(stream.hasError())
		}

		//we are here:
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//we do a move: th1 * ax1.L;
		stream = LogicStream.fromString("th1 >1 ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( ( N + 0 ) * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//revert it:
		stream = LogicStream.fromString("th1 >1 ax2.R;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getVar("th1")!.toJson())

		//test this
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + N * 0 ) \"", proof.getSentense()!.toJson())

		stream = LogicStream.fromString(">5 ax2.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"( N + N ) __1__ ( N * 2 + ( N + 0 ) * 0 ) \"", proof.getSentense()!.toJson())


		//this should generate an error
		stream = LogicStream.fromString("th1 >1 ax1;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//this also
		stream = LogicStream.fromString("th1 >1  \"N __1__ 1\";")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())

		//no position
		stream = LogicStream.fromString("th1 > ax1.L;")
		tokenArray.removeAll(keepingCapacity:true)
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertTrue(stream.hasError())
	}


	static var allTests = [
        ("testTheoremStart", testTheoremStart),
		("replaceAllTest", replaceAllTest),
		("replaceFirstPhraseTest", replaceFirstPhraseTest),
		("replaceSecondPhraseTest", replaceSecondPhraseTest),
		("replaceFirstSingleTest", replaceFirstSingleTest),
		("replaceSecondSingleTest", replaceSecondSingleTest),
    ]
}
