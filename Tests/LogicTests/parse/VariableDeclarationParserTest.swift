import XCTest
import Foundation
@testable import Logic

class VariableDeclarationParserTest: XCTestCase {

	func variableDeclerationParseTest() {
		let th = LogicTheory()
		th.putVar("v1", LogicObject())
		th.putVar("v2", LogicObject())
		th.putVar("v3", LogicObject())

		let proof = Proof(parent:th)
		var tokenArray = [AnyObject]()
		var ops = [LogicOperator]()

		//declate v1 in proof
		var next:Character? = nil
		var stream = LogicStream.fromString("v1;")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(proof.getOwnVar("v1"))

		stream = LogicStream.fromString("v1 = \"proof __1__ v1\";")
		ParsingUtils.skipWhite(stream, &next)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		var result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"proof __1__ v1 \"", proof.getOwnVar("v1")!.toJson())
		XCTAssertEqual("{}", th.getOwnVar("v1")!.toJson()) //v1 in theory should stay untouched

		stream = LogicStream.fromString("v2 = \"proof __2__ v2\";")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"proof __2__ v2 \"", proof.getOwnVar("v2")!.toJson())
		XCTAssertEqual("{}", th.getOwnVar("v2")!.toJson()) //v1 in theory should stay untouched

		stream = LogicStream.fromString("v3 =  \"proof __3__ v3\";")
		ParsingUtils.skipWhite(stream, &next)
		tokenArray.removeAll(keepingCapacity:true)
		ExpressionParser.toReversePolishNotation(&tokenArray, &ops, stream, proof, &next, ExpressionParser.endOfStatement)
		result = ExpressionParser.calculateResult(tokenArray, stream, proof)
		XCTAssertFalse(stream.hasError())
		XCTAssertNil(proof.getOwnVar("v3"))
		XCTAssertEqual("\"proof __3__ v3 \"", th.getOwnVar("v3")!.toJson())

		stream = LogicStream.fromString("v4 = \"proof __1__ only\";")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("\"proof __1__ only \"", proof.getOwnVar("v4")!.toJson())
		XCTAssertNil(th.getOwnVar("v4"))

		//MULTIPLE DECLARATION
		stream = LogicStream.fromString("m1,m2;")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(proof.getOwnVar("m1"))
		XCTAssertNotNil(proof.getOwnVar("m2"))

		stream = LogicStream.fromString("m3 = \"m3 __1__ isCool\", m4;")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(proof.getOwnVar("m3"))
		XCTAssertEqual("\"m3 __1__ isCool \"", proof.getOwnVar("m3")!.toJson())
		XCTAssertNotNil(proof.getOwnVar("m4"))

		stream = LogicStream.fromString("m5 = \"m5 __1__ isCool\", m6 =  \"m6 __1__ m6\";")
		ParsingUtils.skipWhite(stream, &next)
		VariableDeclarationParser.parse(stream, proof, &next)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(proof.getOwnVar("m5"))
		XCTAssertEqual("\"m5 __1__ isCool \"", proof.getOwnVar("m5")!.toJson())
		XCTAssertNotNil(proof.getOwnVar("m6"))
		XCTAssertEqual("\"m6 __1__ m6 \"", proof.getOwnVar("m6")!.toJson())
	}

	static var allTests = [
        ("variableDeclerationParseTest", variableDeclerationParseTest),
    ]
}
