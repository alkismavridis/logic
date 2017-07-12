import XCTest
@testable import Logic

class PhraseTest: XCTestCase {
	func testPhraseSelection() {
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
		XCTAssertEqual(phrase.getLength(), 5)

		//2. create the search phrase
		let words2 = [
			theory.get("1"),
			theory.get("2")
		]
		let searchPhrase = LogicPhrase(words:words2)
		XCTAssertEqual(searchPhrase.getLength(), 2)

		//3. select
		var sel:[UInt32] = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)
		XCTAssertEqual(sel.count, 2)
		XCTAssertEqual(sel[0], 0)
		XCTAssertEqual(sel[1], 3)

		//4. inverted select
		searchPhrase.select(phrase, sel:&sel)
		XCTAssertEqual(sel.count, 0)

		//5. select self
		searchPhrase.select(searchPhrase, sel:&sel)
		XCTAssertEqual(sel.count, 1)
		XCTAssertEqual(sel[0], 0)
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
        ("testPhraseSelection", testPhraseSelection),
		("testPhraseReplaceEqualSize", testPhraseReplaceEqualSize),
		("testPhraseReplaceToSmaller", testPhraseReplaceToSmaller),
		("testPhraseReplaceToBigger", testPhraseReplaceToBigger),
		("testPhraseReplaceToBiggerNoCopy", testPhraseReplaceToBiggerNoCopy),
    ]
}
