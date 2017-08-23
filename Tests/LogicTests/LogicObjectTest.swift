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
		d.put("e", e)
		d.put("f", f)

		var c:LogicPhrase = LogicPhrase(num:3)
		c.add(theory.getWord("4"))
		c.add(theory.getWord("5"))
		c.add(theory.getWord("6"))


		var b:LogicObject = LogicObject()
		b.put("c", c)
		b.put("d", d)

		var a:LogicPhrase = LogicPhrase(num:3)
		a.add(theory.getWord("1"))
		a.add(theory.getWord("2"))
		a.add(theory.getWord("3"))

		var root:LogicObject = LogicObject()
		root.put("a", a)
		root.put("b", b)

		return root
	}



    func testSetAndGet() {
		let theory = LogicTheory()
		let root:LogicObject = self.getStructure(theory)

		XCTAssertNil(root.get("notExists"))
		XCTAssertEqual("\"1 2 3 \"", root.get("a")!.toJson())

		let b:LogicObject = root.get("b") as! LogicObject
		XCTAssertEqual("\"4 5 6 \"", b.get("c")!.toJson())

		b.remove("c")
		XCTAssertNil(b.get("c"))
    }

	func testGetPath() {
		let theory = LogicTheory()
		let root:LogicObject = self.getStructure(theory)

		XCTAssertEqual("\"7 8 9 \"", root.getPath("b", "d", "e")!.toJson())

		//fail cases
		XCTAssertNil(root.getPath("b", "d", "e", "class cast error"))
		XCTAssertNil(root.getPath("b", "Null pointer error", "e"))
	}


    static var allTests = [
        ("testSetAndGet", testSetAndGet),
		("testGetPath", testGetPath),
    ]
}
