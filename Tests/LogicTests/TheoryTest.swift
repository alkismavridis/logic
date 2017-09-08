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

	func testScopeFunctions() {
		let th = LogicTheory()
		let th2 = LogicTheory(parent:th)
		let th3 = LogicTheory(parent:th2)

		//assertions
		XCTAssertFalse(th === th2)
		XCTAssertFalse(th2 === th3)
		XCTAssertFalse(th === th3)

		XCTAssertNil(th.getParentScope())
		XCTAssertNil(th.getParentTheory())
		XCTAssertTrue(th2.getParentScope() as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(th2.getParentTheory() as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(th3.getParentScope() as! AnyObject? === th2 as! AnyObject?)
		XCTAssertTrue(th3.getParentTheory() as! AnyObject === th2 as! AnyObject?)
	}


    static var allTests = [
        ("testTheorySymbolAdding", testTheorySymbolAdding),
		("testScopeFunctions", testScopeFunctions)
    ]
}
