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
		//create some words array to create sentenses from
		let th = LogicTheory()
		let words1 = [
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("3"),
			th.getWord("1"),
		]

		let words2 = [
			th.getWord("4"),
			th.getWord("4"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("3"),
			th.getWord("1"),
			th.getWord("4"),
		]

		let words3 = [
			th.getWord("1"),
			th.getWord("2"),
		]

		let words4 = [
			th.getWord("3"),
			th.getWord("1"),
		]

		//create 2 sentenses
		var plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		var base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.ONE_WAY, grade:0)



		//TEST INDIVIDUAL REPLACEMENTS
		var move = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.LEFT_TO_RIGHT, 2)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//grade not zero
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.ONE_WAY, grade:2)
		XCTAssertEqual(LogicMove.BASE_GRADE_NOT_ZERO, plasi.isMoveLegal(move, from:base))

		//match failure
		move = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.LEFT_TO_RIGHT, 3)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.ONE_WAY, grade:0)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.isMoveLegal(move, from:base))

		//illegal right to left
		move = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.RIGHT_TO_LEFT, 0)
		XCTAssertEqual(LogicMove.ILLEGAL_DIRECTION, plasi.isMoveLegal(move, from:base))

		//But it should be allowed with TWO_WAY base
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:0)
		move = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.RIGHT_TO_LEFT, 4)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//if plasi is one way, editing the first phrase is forbidden
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:0)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//but trying it on the second phrase should be legal, no matter what the plasi direction is
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:0)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:0)
		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.LEFT_TO_RIGHT, 2)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//still, matching failures should work
		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.LEFT_TO_RIGHT, 3)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.isMoveLegal(move, from:base))

		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.RIGHT_TO_LEFT, 3)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.isMoveLegal(move, from:base))

		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.RIGHT_TO_LEFT, 5)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//and base direction rules too
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.ONE_WAY, grade:0)
		XCTAssertEqual(LogicMove.ILLEGAL_DIRECTION, plasi.isMoveLegal(move, from:base))

		//base with greater base should still be forbidden
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:2)
		XCTAssertEqual(LogicMove.BASE_GRADE_NOT_ZERO, plasi.isMoveLegal(move, from:base))


		//TEST PHRASE REPLACEMENTS
		//Start with an illegal direction
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:0)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:0)
		move = LogicMove(LogicMove.FIRST, LogicMove.LEFT_TO_RIGHT)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//Make plasi two way. Now it should be allowed
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade less than plasis
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade equal to plasis
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade grater than to plasis
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.BASE_GRADE_TO_BIG, plasi.isMoveLegal(move, from:base))


		//Test base grade less than plasis (ONE_WAY plasi)
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//Test base grade equal to plasis (ONE_WAY plasi)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//Test base grade grater than to plasis (ONE_WAY plasi)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))


		//now test the second side
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:0)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:0)
		move = LogicMove(LogicMove.SECOND, LogicMove.LEFT_TO_RIGHT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Make plasi two way. It should be allowed too
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade less than plasis
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade equal to plasis
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade grater than to plasis
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.BASE_GRADE_TO_BIG, plasi.isMoveLegal(move, from:base))


		//Test base grade less than plasis (ONE_WAY plasi)
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade equal to plasis (ONE_WAY plasi)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//Test base grade grater than to plasis (ONE_WAY plasi)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.BASE_GRADE_TO_BIG, plasi.isMoveLegal(move, from:base))


		//TEST SENTENSE REPLACEMENTS
		//one way plasi (base grade smaller)
		move = LogicMove(LogicMove.ALL, LogicMove.LEFT_TO_RIGHT)
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.ONE_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//one way plasi (base grade equal)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.ILEGAL_FIRST_PHRASE_EDIT, plasi.isMoveLegal(move, from:base))

		//one way plasi (base grade greater)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//two way plasi (base grade smaller)
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:5)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:4)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//two way plasi (base grade equal)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:5)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))

		//two way plasi (base grade greater)
		base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:6)
		XCTAssertEqual(LogicMove.LEGAL, plasi.isMoveLegal(move, from:base))
	}


	public func testReplacements() {
		//create 2 sentenses
		let th = LogicTheory()
		let words1 = [
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("3"),
			th.getWord("1"),
		]

		let words2 = [
			th.getWord("4"),
			th.getWord("4"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("3"),
			th.getWord("1"),
			th.getWord("4"),
		]

		let words3 = [
			th.getWord("1"),
			th.getWord("2"),
		]

		let words4 = [
			th.getWord("3"),
			th.getWord("1"),
		]

		var sel:LogicSelection = LogicSelection(10, 10)
		var plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		plasi.setType(SentenseType.PLASI)
		var base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.ONE_WAY, grade:0)


		//test an illegal move
		var move:LogicMove = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.LEFT_TO_RIGHT, 3)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.select(base:base, move:move, sel:sel, check:true))

		//disable checking
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:false))
		XCTAssertEqual([3], sel.get1())

		plasi.replace(LogicMove.LEFT_SIDE, of:base, sel:sel)
		XCTAssertEqual("\"1 2 1 3 1 1 __0__ 4 4 1 2 1 3 1 4 \"", plasi.toJson())

		//test select andReplace in the whole sentese
		plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		plasi.setType(SentenseType.PLASI)
		move = LogicMove(LogicMove.ALL, LogicMove.LEFT_TO_RIGHT)

		XCTAssertEqual(LogicMove.LEGAL, plasi.selectAndReplace(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual("\"3 1 3 1 3 1 __0__ 4 4 3 1 1 3 1 4 \"", plasi.toJson())
	}

	public func testSelection() {
		//create 2 sentenses
		let th = LogicTheory()
		let words1 = [
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("3"),
			th.getWord("1"),
		]

		let words2 = [
			th.getWord("4"),
			th.getWord("4"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("3"),
			th.getWord("1"),
			th.getWord("2"),
		]

		let words3 = [
			th.getWord("1"),
			th.getWord("2"),
		]

		let words4 = [
			th.getWord("3"),
			th.getWord("1"),
		]

		var sel:LogicSelection = LogicSelection(10, 10)
		var plasi = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:0)
		plasi.setType(SentenseType.PLASI)
		var base = LogicSentense.generateAxiom(left:words3, right:words4, type:LogicBridge.TWO_WAY, grade:0)

		//assertions
		var move:LogicMove = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.LEFT_TO_RIGHT, 2)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([2], sel.get1())
		XCTAssertEqual([], sel.get2())

		//illegal select one in first
		move = LogicMove(LogicMove.ONE_IN_FIRST, LogicMove.LEFT_TO_RIGHT, 3)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.select(base:base, move:move, sel:sel, check:true))

		//select in second
		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.LEFT_TO_RIGHT, 6)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([], sel.get1())
		XCTAssertEqual([6], sel.get2())

		move = LogicMove(LogicMove.ONE_IN_SECOND, LogicMove.LEFT_TO_RIGHT, 3)
		XCTAssertEqual(LogicMove.MATCH_FAILED, plasi.select(base:base, move:move, sel:sel, check:true))

		//select in first phrase
		move = LogicMove(LogicMove.FIRST, LogicMove.LEFT_TO_RIGHT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([0, 2], sel.get1())
		XCTAssertEqual([], sel.get2())

		move = LogicMove(LogicMove.FIRST, LogicMove.RIGHT_TO_LEFT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([4], sel.get1())
		XCTAssertEqual([], sel.get2())


		//select in second phrase
		move = LogicMove(LogicMove.SECOND, LogicMove.LEFT_TO_RIGHT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([], sel.get1())
		XCTAssertEqual([2, 6], sel.get2())

		move = LogicMove(LogicMove.SECOND, LogicMove.RIGHT_TO_LEFT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([], sel.get1())
		XCTAssertEqual([5], sel.get2())


		//select in whole sentense
		move = LogicMove(LogicMove.ALL, LogicMove.LEFT_TO_RIGHT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([0, 2], sel.get1())
		XCTAssertEqual([2, 6], sel.get2())

		move = LogicMove(LogicMove.ALL, LogicMove.RIGHT_TO_LEFT)
		XCTAssertEqual(LogicMove.LEGAL, plasi.select(base:base, move:move, sel:sel, check:true))
		XCTAssertEqual([4], sel.get1())
		XCTAssertEqual([5], sel.get2())
	}



//TEST ARRAY
	static var allTests = [
        ("testAxiom", testAxiom),
		("testMoveLegal", testMoveLegal),
		("testStart", testStart),
		("testReplacements", testReplacements),
		("testSelection", testSelection)
    ]
}
