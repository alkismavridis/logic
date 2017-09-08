import XCTest
@testable import Logic

class LogicObjectTest: XCTestCase {
	private func getStructure(_ theory:LogicTheory) -> LogicObject {
		//create some object hierarchy
		/*
			{
				"a": "1 2 3",
				"b": {
					"c": "4 5 6",
					"d": {
						"e": "7 8 9"
						"f": nil
					}
				},
			}
		*/
		let theory = LogicTheory()

		var f:LogicValue? = nil

		var e:LogicPhrase = LogicPhrase(num:3)
		e.add(theory.getWord("7"))
		e.add(theory.getWord("8"))
		e.add(theory.getWord("9"))

		var d:LogicObject = LogicObject()
		d.putVar("e", e)
		d.putVar("f", f)

		var c:LogicPhrase = LogicPhrase(num:3)
		c.add(theory.getWord("4"))
		c.add(theory.getWord("5"))
		c.add(theory.getWord("6"))


		var b:LogicObject = LogicObject()
		b.putVar("c", c)
		b.putVar("d", d)

		var a:LogicPhrase = LogicPhrase(num:3)
		a.add(theory.getWord("1"))
		a.add(theory.getWord("2"))
		a.add(theory.getWord("3"))

		var root:LogicObject = LogicObject()
		root.putVar("a", a)
		root.putVar("b", b)

		return root
	}



    func testSetAndGet() {
		let theory = LogicTheory()
		let root:LogicObject = self.getStructure(theory)

		XCTAssertNil(root.getVar("notExists"))
		XCTAssertEqual("\"1 2 3 \"", root.getVar("a")!.toJson())

		let b:LogicObject = root.getVar("b") as! LogicObject
		XCTAssertEqual("\"4 5 6 \"", b.getVar("c")!.toJson())

		b.remove("c")
		XCTAssertNil(b.getVar("c"))
    }

	func testGetPath() {
		let theory = LogicTheory()
		let root:LogicObject = self.getStructure(theory)

		XCTAssertEqual("\"7 8 9 \"", root.getVarPath("b", "d", "e")!.toJson())

		//fail cases
		XCTAssertNil(root.getVarPath("b", "d", "e", "class cast error"))
		XCTAssertNil(root.getVarPath("b", "Null pointer error", "e"))
	}


    static var allTests = [
        ("testSetAndGet", testSetAndGet),
		("testGetPath", testGetPath),
    ]
}
