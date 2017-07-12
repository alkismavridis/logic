import XCTest
@testable import Logic

class SentenseTest: XCTestCase {
	func testAxiom() {
		let theory = LogicTheory()

		//1. create the 2 word arrays
		let words1 = [
			theory.get("1"),
			theory.get("2"),
			theory.get("3"),
			theory.get("1"),
			theory.get("2")
		]

		let words2 = [
			theory.get("1"),
			theory.get("2")
		]

		//3. create the axiom
		var ax:LogicSentense = LogicSentense.generateAxiom(left:words1, right:words2, type:LogicBridge.TWO_WAY, grade:1)

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

	func testPhraseReplaceEqualSize() {
		let theory = LogicTheory()

		//1. create the target phrase
		let words1 = [
			theory.get("1"),
			theory.get("2"),
			theory.get("3"),
			theory.get("1"),
			theory.get("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.get("1"),
			theory.get("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.get("9"),
			theory.get("8"),
		]
		let replacePhrase = LogicPhrase(words:words3)
		phrase.replace(replacePhrase, 2, sel)
		XCTAssertEqual(phrase.toJson(), "\"9 8 3 9 8 \"")
		XCTAssertEqual(phrase.getLength(), 5)
	}

	func testPhraseReplaceToSmaller() {
		let theory = LogicTheory()

		//1. create the target phrase
		let words1 = [
			theory.get("1"),
			theory.get("2"),
			theory.get("3"),
			theory.get("1"),
			theory.get("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.get("1"),
			theory.get("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.get("9"),
		]
		let replacePhrase = LogicPhrase(words:words3)
		phrase.replace(replacePhrase, 2, sel)
		XCTAssertEqual(phrase.toJson(), "\"9 3 9 \"")
		XCTAssertEqual(phrase.getLength(), 3)
	}

	func testPhraseReplaceToBigger() {
		let theory = LogicTheory()

		//1. create the target phrase
		let words1 = [
			theory.get("1"),
			theory.get("2"),
			theory.get("3"),
			theory.get("1"),
			theory.get("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.get("1"),
			theory.get("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.get("9"),
			theory.get("8"),
			theory.get("7"),
			theory.get("9"),
		]
		let replacePhrase = LogicPhrase(words:words3)
		phrase.replace(replacePhrase, 2, sel)
		XCTAssertEqual(phrase.toJson(), "\"9 8 7 9 3 9 8 7 9 \"")
		XCTAssertEqual(phrase.getLength(), 9)
	}

	func testPhraseReplaceToBiggerNoCopy() {
		let theory = LogicTheory()

		//1. create the target phrase
		let words1 = [
			theory.get("1"),
			theory.get("2"),
			theory.get("3"),
			theory.get("1"),
			theory.get("2")
		]
		let phrase = LogicPhrase(words:words1)
		phrase.ensureCapacity(500)
		XCTAssertGreaterThan(phrase.getCapacity(), 500)


		//2. create the search phrase
		let words2 = [
			theory.get("1"),
			theory.get("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.get("9"),
			theory.get("8"),
			theory.get("7"),
			theory.get("9"),
		]
		let replacePhrase = LogicPhrase(words:words3)
		phrase.replace(replacePhrase, 2, sel)
		XCTAssertEqual(phrase.toJson(), "\"9 8 7 9 3 9 8 7 9 \"")
		XCTAssertEqual(phrase.getLength(), 9)
	}

	static var allTests = [
        ("testAxiom", testAxiom),
    ]
}
