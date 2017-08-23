import XCTest
@testable import Logic

class PhraseTest: XCTestCase {
	func testPhraseSelection() {
		let theory = LogicTheory()

		//1. create the target phrase
		let words1 = [
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]

		let phrase = LogicPhrase(words:words1)
		XCTAssertEqual(phrase.getLength(), 5)

		//2. create the search phrase
		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
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
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.getWord("9"),
			theory.getWord("8"),
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
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.getWord("9"),
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
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]
		let phrase = LogicPhrase(words:words1)

		//2. create the search phrase
		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.getWord("9"),
			theory.getWord("8"),
			theory.getWord("7"),
			theory.getWord("9"),
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
			theory.getWord("1"),
			theory.getWord("2"),
			theory.getWord("3"),
			theory.getWord("1"),
			theory.getWord("2")
		]
		let phrase = LogicPhrase(words:words1)
		phrase.ensureCapacity(500)
		XCTAssertGreaterThan(phrase.getCapacity(), 500)


		//2. create the search phrase
		let words2 = [
			theory.getWord("1"),
			theory.getWord("2")
		]
		let searchPhrase = LogicPhrase(words:words2)

		//select
		var sel = [UInt32]()
		phrase.select(searchPhrase, sel:&sel)

		let words3 = [
			theory.getWord("9"),
			theory.getWord("8"),
			theory.getWord("7"),
			theory.getWord("9"),
		]
		let replacePhrase = LogicPhrase(words:words3)
		phrase.replace(replacePhrase, 2, sel)
		XCTAssertEqual(phrase.toJson(), "\"9 8 7 9 3 9 8 7 9 \"")
		XCTAssertEqual(phrase.getLength(), 9)

		phrase.saveSpace()
		XCTAssertEqual(9, phrase.getCapacity())
	}

	func testAddWords() {
		//create an empty phrase
		let phrase:LogicPhrase = LogicPhrase(num:4)
		XCTAssertEqual(0, phrase.getLength())
		XCTAssertEqual(4, phrase.getCapacity())


		//add 4 symbols. Capacity should stay 4, but length should increase
		let th:LogicTheory = LogicTheory()
		for i in 0..<4 {
			phrase.add(th.getWord("s"))
			XCTAssertEqual(UInt32(i+1), phrase.getLength())
			XCTAssertEqual(4, phrase.getCapacity())
		}

		//check phrase state
		XCTAssertEqual("\"s s s s \"", phrase.toJson())

		//add one more symbol. Now capacity must also change
		phrase.add(th.getWord("s"))
		XCTAssertEqual(5, phrase.getLength())
		XCTAssertGreaterThan(phrase.getCapacity(), 4)

	}

	func testCopy() {
		//create a word array, and a phrase from it
		let th:LogicTheory = LogicTheory()
		let words:[LogicWord] = [
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("3"),
		]
		let phrase:LogicPhrase = LogicPhrase(words:words)

		//try to copy it
		let copied:LogicPhrase = LogicPhrase(num:1)
		XCTAssertEqual(0, copied.getLength())
		XCTAssertEqual(1, copied.getCapacity())

		//check that everything is ok
		copied.copy(from:phrase)
		XCTAssertEqual(phrase.getLength(), copied.getLength())
		XCTAssertEqual(phrase.getCapacity(), copied.getCapacity())
		XCTAssertEqual(phrase.toJson(), copied.toJson())

		//do it once more and test that everything stayed the same
		copied.copy(from:phrase)
		XCTAssertEqual(phrase.getLength(), copied.getLength())
		XCTAssertEqual(phrase.getCapacity(), copied.getCapacity())
		XCTAssertEqual(phrase.toJson(), copied.toJson())

		//now copy from words
		copied.copy(words:words)
		XCTAssertEqual(phrase.getLength(), UInt32(words.count))
		XCTAssertEqual(phrase.getCapacity(), UInt32(words.count))
		XCTAssertEqual(phrase.toJson(), copied.toJson())

	}

	func testMatch() {
		//create phrase to be searched
		let th:LogicTheory = LogicTheory()
		let words:[LogicWord] = [
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("3"),
			th.getWord("1"),
			th.getWord("2"),
			th.getWord("2"),
			th.getWord("1"),
			th.getWord("2"),
		]
		let src:LogicPhrase = LogicPhrase(words:words)


		//create target phrase
		let words2:[LogicWord] = [
			th.getWord("1"),
			th.getWord("2")
		]
		let target:LogicPhrase = LogicPhrase(words:words2)


		//test match cases
		XCTAssertTrue(src.match(target, pos:0))
		XCTAssertFalse(src.match(target, pos:1))
		XCTAssertFalse(src.match(target, pos:2))
		XCTAssertFalse(src.match(target, pos:3))
		XCTAssertTrue(src.match(target, pos:4))
		XCTAssertFalse(src.match(target, pos:5))
		XCTAssertFalse(src.match(target, pos:6))
		XCTAssertTrue(src.match(target, pos:7))
		XCTAssertFalse(src.match(target, pos:8))
		XCTAssertFalse(src.match(target, pos:2362))

		XCTAssertTrue(src.match(src, pos:0))
		XCTAssertFalse(src.match(src, pos:1))

		XCTAssertFalse(target.match(src, pos:0))
		XCTAssertFalse(target.match(src, pos:1))
	}


	static var allTests = [
        ("testPhraseSelection", testPhraseSelection),
		("testPhraseReplaceEqualSize", testPhraseReplaceEqualSize),
		("testPhraseReplaceToSmaller", testPhraseReplaceToSmaller),
		("testPhraseReplaceToBigger", testPhraseReplaceToBigger),
		("testPhraseReplaceToBiggerNoCopy", testPhraseReplaceToBiggerNoCopy),
		("testAddWords", testAddWords),
		("testCopy", testCopy),
		("testMatch", testMatch)
    ]
}
