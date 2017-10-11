import XCTest
import Foundation
@testable import Logic

class AxiomParserTest: XCTestCase {
	func nextStringTest() {
		var stream = LogicStream.fromString("This is a cool  test öld   ÜlÖ ελληνικά\"")
		var end = false

		XCTAssertEqual("This", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("is", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("a", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("cool", AxiomParser.nextString(stream, &end))

		XCTAssertFalse(end)

		XCTAssertEqual("test", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("öld", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("ÜlÖ", AxiomParser.nextString(stream, &end))
		XCTAssertEqual("ελληνικά", AxiomParser.nextString(stream, &end))
		XCTAssertNil(AxiomParser.nextString(stream, &end))
		XCTAssertNil(AxiomParser.nextString(stream, &end))
		XCTAssertNil(AxiomParser.nextString(stream, &end))

		XCTAssertTrue(end)


		//test endings
		stream = LogicStream.fromString("test     \"")
		XCTAssertEqual("test", AxiomParser.nextString(stream, &end))
		XCTAssertFalse(end)

		XCTAssertNil(AxiomParser.nextString(stream, &end))
		XCTAssertTrue(end)

		stream = LogicStream.fromString("test\"")
		XCTAssertEqual("test", AxiomParser.nextString(stream, &end))
		XCTAssertTrue(end)
	}


	func bridgeTest() {
		var bridge = AxiomParser.toBridge("__2__")
		XCTAssertNotNil(bridge)
		XCTAssertEqual(2, bridge!.grade)
		XCTAssertEqual(LogicBridge.TWO_WAY, bridge!.type)

		bridge = AxiomParser.toBridge("__223--")
		XCTAssertNotNil(bridge)
		XCTAssertEqual(223, bridge!.grade)
		XCTAssertEqual(LogicBridge.ONE_WAY, bridge!.type)

		bridge = AxiomParser.toBridge("__0--")
		XCTAssertNotNil(bridge)
		XCTAssertEqual(0, bridge!.grade)
		XCTAssertEqual(LogicBridge.ONE_WAY, bridge!.type)

		bridge = AxiomParser.toBridge("__0__")
		XCTAssertNotNil(bridge)
		XCTAssertEqual(0, bridge!.grade)
		XCTAssertEqual(LogicBridge.TWO_WAY, bridge!.type)


		//fail cases
		XCTAssertNil(AxiomParser.toBridge("_s_0--"))
		XCTAssertNil(AxiomParser.toBridge("__--"))
		XCTAssertNil(AxiomParser.toBridge("--"))
		XCTAssertNil(AxiomParser.toBridge("__  55--"))
		XCTAssertNil(AxiomParser.toBridge("_s_0--"))
		XCTAssertNil(AxiomParser.toBridge("__55 --"))
	}

	func parseTest() {
		let th = LogicTheory()
		var end = false

		//test sentense without ending tag
		var stream = LogicStream.fromString("a __2__ b")
		var sent = AxiomParser.parse(stream, th)
		XCTAssertEqual("\"a __2__ b \"", sent!.toJson())

		//try an ending tag
		stream = LogicStream.fromString("a  b   __4--   b a\" this must not be parsed")
		sent = AxiomParser.parse(stream, th)
		XCTAssertEqual("\"a b __4-- b a \"", sent!.toJson())

		//try sentense without bridge
		stream = LogicStream.fromString("a  b      b a\" this must not be parsed")
		sent = AxiomParser.parse(stream, th)
		XCTAssertNil(sent)
		XCTAssertEqual("this", AxiomParser.nextString(stream, &end))

		//try sentense with 2 bridges
		stream = LogicStream.fromString("a  b    __4--  b a __6__ a \" this must not be parsed")
		sent = AxiomParser.parse(stream, th)
		XCTAssertNil(sent)
		XCTAssertEqual("this", AxiomParser.nextString(stream, &end))

		//same, with ending tag with no space
		stream = LogicStream.fromString("a  b    __4--  b a __6__\" this must not be parsed")
		sent = AxiomParser.parse(stream, th)
		XCTAssertNil(sent)
		XCTAssertEqual("this", AxiomParser.nextString(stream, &end))
	}

	func testMessages() {
		//TODO
	}


	static var allTests = [
        ("bridgeTest", bridgeTest),
		("nextStringTest", nextStringTest),
		("parseTest", parseTest),
		("testMessages", testMessages)
    ]
}
