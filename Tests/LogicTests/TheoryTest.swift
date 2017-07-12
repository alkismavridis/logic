import XCTest
@testable import Logic

class TheoryTest: XCTestCase {
    func testTheorySymbolAdding() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let theory = LogicTheory()
		XCTAssertEqual(theory.getWordCount(), 0)

		theory.get("Hello")
		XCTAssertEqual(theory.getWordCount(), 1)

		theory.get("World")
		XCTAssertEqual(theory.getWordCount(), 2)

		theory.get("hello")
		XCTAssertEqual(theory.getWordCount(), 3)

		theory.get("World")
		XCTAssertEqual(theory.getWordCount(), 3)

		theory.get("Hello")
		XCTAssertEqual(theory.getWordCount(), 3)
    }


    static var allTests = [
        ("testTheorySymbolAdding", testTheorySymbolAdding),
    ]
}
