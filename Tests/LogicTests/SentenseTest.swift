import XCTest
@testable import Logic

class SentenseTest: XCTestCase {
	func testAxiom() {
		let theory = LogicTheory()

		//1. create the 2 word arrays
		let words1 = [
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]

		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]

		//3. create the axiom
		let ax:LogicSentense = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:1)

		//4. test phrase getters
		XCTAssertEqual(ax.getPhrase(LogicMove.LEFT_SIDE).toJson(), "\"1 2 3 1 2 \"")
		XCTAssertEqual(ax.getPhrase(LogicMove.RIGHT_SIDE).toJson(), "\"1 2 \"")
		XCTAssertEqual(ax.getTheOther(LogicMove.RIGHT_SIDE).toJson(), "\"1 2 3 1 2 \"")
		XCTAssertEqual(ax.getTheOther(LogicMove.LEFT_SIDE).toJson(), "\"1 2 \"")

		XCTAssertEqual(ax.getBridge().type, LogicBridge.TWO_WAY)
		XCTAssertEqual(ax.getBridge().grade, 1)
		XCTAssertEqual(ax.getBridge().isTwoWay(), true)

		//5. test serializer
		XCTAssertEqual(ax.toJson(), "\"1 2 3 1 2 __1__ 1 2 \"")
	}

	public func testStart() {
		//TODO test isMoveLegal, selectAndReplace for legal and non legal moves

		//1. Create an Axiom to start
		let theory = LogicTheory()
		let words1 = [
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]

		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]

		let axiom1:LogicSentense = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:3)


		//Test legality of Starts
		XCTAssertEqual(LogicMove.LEGAL, LogicSentense.isStartLegal(base:axiom1, side:LogicMove.LEFT_SIDE))
		XCTAssertEqual(LogicMove.ILLEGAL_DIRECTION, LogicSentense.isStartLegal(base:axiom1, side:LogicMove.RIGHT_SIDE))
		XCTAssertEqual(LogicMove.LEGAL, LogicSentense.isStartLegal(base:axiom1, side:LogicMove.BOTH_SIDES))

		//Make 3 starts
		let th1:LogicSentense = LogicSentense(from:axiom1, side:LogicMove.LEFT_SIDE, check:false)
		let th2:LogicSentense = LogicSentense(from:axiom1, side:LogicMove.RIGHT_SIDE, check:true)
		let thBoth:LogicSentense = LogicSentense(from:axiom1, side:LogicMove.BOTH_SIDES, check:false)

		XCTAssertEqual("\"1 2 3 1 2 __3-- 1 2 3 1 2 \"", th1.toJson())
		XCTAssertEqual("\"__0-- \"", th2.toJson())
		XCTAssertEqual("\"1 2 3 1 2 __3-- 1 2 \"", thBoth.toJson())



		//Now try the same with a two-way axiom
		let axiom2:LogicSentense = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:2)

		let th1_2:LogicSentense = LogicSentense(from:axiom2, side:LogicMove.LEFT_SIDE, check:false)
		let th2_2:LogicSentense = LogicSentense(from:axiom2, side:LogicMove.RIGHT_SIDE, check:true)
		let thBoth_2:LogicSentense = LogicSentense(from:axiom2, side:LogicMove.BOTH_SIDES, check:false)

		XCTAssertEqual("\"1 2 3 1 2 __2__ 1 2 3 1 2 \"", th1_2.toJson())
		XCTAssertEqual("\"1 2 __2__ 1 2 \"", th2_2.toJson())
		XCTAssertEqual("\"1 2 3 1 2 __2__ 1 2 \"", thBoth_2.toJson())
	}

	public func testMoveLegal() {
		//TODO test isMoveLegal, selectAndReplace for legal and non legal moves
		let theory = LogicTheory()


		//TEST INDIVIDUAL REPLACEMENTS


		//TEST PHRASE REPLACEMENTS


		//TEST SENTENSE REPLACEMENTS

	}




//TEST ARRAY
	static var allTests = [
        ("testAxiom", testAxiom),
		("testMoveLegal", testMoveLegal),
		("testStart", testStart),
    ]
}
