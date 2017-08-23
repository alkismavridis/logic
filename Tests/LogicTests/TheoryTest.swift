import XCTest
@testable import Logic

class TheoryTest: XCTestCase {
    func testTheorySymbolAdding() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let theory = LogicTheory()
		XCTAssertEqual(theory.getWordCount(), 0)

		theory.getWord("Hello")
		XCTAssertEqual(theory.getWordCount(), 1)

		theory.getWord("World")
		XCTAssertEqual(theory.getWordCount(), 2)

		theory.getWord("hello")
		XCTAssertEqual(theory.getWordCount(), 3)

		theory.getWord("World")
		XCTAssertEqual(theory.getWordCount(), 3)

		theory.getWord("Hello")
		XCTAssertEqual(theory.getWordCount(), 3)
    }


    static var allTests = [
        ("testTheorySymbolAdding", testTheorySymbolAdding),
    ]
}
