import XCTest
import Foundation
@testable import Logic

class CommandParserTest: XCTestCase {
	func testParser() {
		let th = LogicTheory()
		var next:Character? = nil
		var end = false
		var tokenArray = [AnyObject]()

		//Test "let" keyword parser
		var stream = LogicStream.fromString("let v1, v2;")
		ParsingUtils.skipWhite(stream, &next)
		var result = CommandParser.parse(stream, th, &next, &end, CommandParser.endOfProof)
		XCTAssertFalse(stream.hasError())
		XCTAssertFalse(end)
		XCTAssertNotNil(th.getVar("v1"))
		XCTAssertNotNil(th.getVar("v2"))
		XCTAssertTrue(th.getVar("v1") is LogicNull)
		XCTAssertTrue(th.getVar("v2") is LogicNull)

		//start with operand
		stream = LogicStream.fromString("v3 = \"hello __1__ world\";")
		ParsingUtils.skipWhite(stream, &next)
		result = CommandParser.parse(stream, th, &next, &end, CommandParser.endOfProof)
		XCTAssertFalse(stream.hasError())
		XCTAssertFalse(end)
		XCTAssertNotNil(th.getVar("v3"))
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __1__ world \"", th.getVar("v3")!.toJson())

		//start with operator
		let proof = Proof(parent:th)
		stream = LogicStream.fromString("~ v3.L;")
		ParsingUtils.skipWhite(stream, &next)
		result = CommandParser.parse(stream, proof, &next, &end, CommandParser.endOfProof)
		XCTAssertFalse(end)
		XCTAssertFalse(stream.hasError())
		XCTAssertNotNil(proof.getSentense())
		XCTAssertNotNil(result)
		XCTAssertEqual("\"hello __1__ hello \"", proof.getSentense()!.toJson())


		//test end
		stream = LogicStream.fromString("}}")
		ParsingUtils.skipWhite(stream, &next)
		result = CommandParser.parse(stream, proof, &next, &end, CommandParser.endOfProof)
		XCTAssertNil(result)
		XCTAssertTrue(end)
	}

	static var allTests = [
        ("testParser", testParser),
    ]
}
