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

	func testParentGetters() {
		//create a tree
		let th = LogicTheory()
		let th2 = LogicTheory(parent:th)
		let pr1 = Proof(parent:th2)
		let th3 = LogicTheory(parent:pr1)


		//add some variables
		let val = LogicValue()
		th.putVar("name1", val)
		th2.putVar("name2", val)
		pr1.putVar("namePr", val)
		th3.putVar("name1", val)


		//assertions
		XCTAssertFalse(th === th2)
		XCTAssertFalse(th2 === th3)
		XCTAssertFalse(th === th3)

		XCTAssertNil(th.getParentScope())
		XCTAssertNil(th.getParentTheory())
		XCTAssertTrue(th2.getParentScope() as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(th2.getParentTheory() as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(pr1.getParentScope() as! AnyObject? === th2 as! AnyObject?)
		XCTAssertTrue(pr1.getParentTheory() as! AnyObject? === th2 as! AnyObject?)
		XCTAssertTrue(th3.getParentScope() as! AnyObject? === pr1 as! AnyObject?)
		XCTAssertTrue(th3.getParentTheory() as! AnyObject === th2 as! AnyObject?)


		//getScopeWithVar
		XCTAssertNil( th.getScopeWithVar("not exist") )
		XCTAssertTrue(th.getScopeWithVar("name1") as! AnyObject? === th as! AnyObject?)

		XCTAssertNil( th2.getScopeWithVar("not exist") )
		XCTAssertTrue(th2.getScopeWithVar("name1") as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(th2.getScopeWithVar("name2") as! AnyObject? === th2 as! AnyObject?)

		XCTAssertNil( pr1.getScopeWithVar("not exist") )
		XCTAssertTrue(pr1.getScopeWithVar("name1") as! AnyObject? === th as! AnyObject?)
		XCTAssertTrue(pr1.getScopeWithVar("name2") as! AnyObject? === th2 as! AnyObject?)
		XCTAssertTrue(pr1.getScopeWithVar("namePr") as! AnyObject? === pr1 as! AnyObject?)

		XCTAssertNil( th3.getScopeWithVar("not exist") )
		XCTAssertTrue(th3.getScopeWithVar("name1") as! AnyObject? === th3 as! AnyObject?)
		XCTAssertTrue(th3.getScopeWithVar("name2") as! AnyObject? === th2 as! AnyObject?)
		XCTAssertTrue(th3.getScopeWithVar("namePr") as! AnyObject? === pr1 as! AnyObject?)


		//remove some vars
		th3.removeVar("name1")
		th2.removeVar("name2")

		//check for changes
		XCTAssertTrue(th3.getScopeWithVar("name1") as! AnyObject? === th as! AnyObject?)
		XCTAssertNil(th3.getScopeWithVar("name2"))
	}


	public func testVarGetters() {
		//create a tree
		let th = LogicTheory()
		let th2 = LogicTheory(parent:th)
		let pr1 = Proof(parent:th2)
		let th3 = LogicTheory(parent:pr1)


		//add some variables
		let val = LogicValue()
		let val2 = LogicValue()
		let val3 = LogicValue()
		th.putVar("name1", val)
		th2.putVar("name2", val)
		pr1.putVar("namePr", val2)
		th3.putVar("name1", val3)

		XCTAssertFalse(val as! AnyObject? === val2 as! AnyObject?)



		//assertions
		XCTAssertNil( th.getOwnVar("not exist") )
		XCTAssertNil( th.getVar("not exist") )
		XCTAssertTrue(val as! AnyObject? === th.getOwnVar("name1") as! AnyObject?)
		XCTAssertTrue(val as! AnyObject? === th.getVar("name1") as! AnyObject?)

		XCTAssertNil( th2.getOwnVar("not exist") )
		XCTAssertNil( th2.getVar("not exist") )
		XCTAssertTrue(val as! AnyObject? === th2.getVar("name1") as! AnyObject?)
		XCTAssertNil(th2.getOwnVar("name1"))
		XCTAssertTrue(val as! AnyObject? === th2.getOwnVar("name2") as! AnyObject?)
		XCTAssertTrue(val as! AnyObject? === th2.getVar("name2") as! AnyObject?)

		XCTAssertNil( pr1.getOwnVar("not exist") )
		XCTAssertNil( pr1.getVar("not exist") )
		XCTAssertNil(pr1.getOwnVar("name1"))
		XCTAssertTrue(val as! AnyObject? === pr1.getVar("name1") as! AnyObject?)
		XCTAssertTrue(val2 as! AnyObject? === pr1.getOwnVar("namePr") as! AnyObject?)
		XCTAssertTrue(val2 as! AnyObject? === pr1.getVar("namePr") as! AnyObject?)

		XCTAssertNil( th3.getOwnVar("not exist") )
		XCTAssertNil( th3.getVar("not exist") )
		XCTAssertTrue(val3 as! AnyObject? === th3.getOwnVar("name1"))
		XCTAssertTrue(val3 as! AnyObject? === th3.getVar("name1") as! AnyObject?)
		XCTAssertNil(th3.getOwnVar("namePr"))
		XCTAssertTrue(val2 as! AnyObject? === th3.getVar("namePr") as! AnyObject?)

		//remove some values
		th2.removeVar("name2")
		th3.removeVar("name1")

		//check for changes
		XCTAssertNil(th2.getOwnVar("name2"))
		XCTAssertNil(th2.getVar("name2"))
		XCTAssertNil(th3.getOwnVar("name2"))
		XCTAssertNil(th3.getVar("name2"))

		XCTAssertNil(th3.getOwnVar("name1"))
		XCTAssertTrue(val as! AnyObject? === th3.getVar("name1") as! AnyObject?)
	}


    static var allTests = [
        ("testTheorySymbolAdding", testTheorySymbolAdding),
		("testParentGetters", testParentGetters),
		("testVarGetters", testVarGetters)
    ]
}
