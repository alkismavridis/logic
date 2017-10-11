import XCTest
@testable import Logic

class ObjectParserTest: XCTestCase {

	func parseKeyTest() {
		var stream = LogicStream.fromString("myKey:")
		var next:Character? = nil
		var key = ObjectParser.getKey(stream, &next)

		XCTAssertEqual("myKey", key)
		XCTAssertNil(stream.next())
		XCTAssertFalse(stream.hasError())

		//test spaces before
		stream = LogicStream.fromString("  otherKey:V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertEqual("otherKey", key)
		XCTAssertEqual("V", stream.next())
		XCTAssertFalse(stream.hasError())

		//test spaces after
		stream = LogicStream.fromString("key3   :V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertEqual("key3", key)
		XCTAssertEqual("V", stream.next())
		XCTAssertFalse(stream.hasError())

		//test first input character
		stream = LogicStream.fromString("har   :V")
		next = "c"
		key = ObjectParser.getKey(stream, &next)
		XCTAssertEqual("char", key)
		XCTAssertEqual("V", stream.next())
		XCTAssertFalse(stream.hasError())

		//test end of object
		stream = LogicStream.fromString("}V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("V", stream.next())

		//test of object with spaces
		stream = LogicStream.fromString("   }V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertFalse(stream.hasError())
		XCTAssertEqual("V", stream.next())

		//test empty key
		stream = LogicStream.fromString(":V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertEqual("V", stream.next())
		XCTAssertTrue(stream.hasError())

		//test spaced only key
		stream = LogicStream.fromString("     :V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertEqual("V", stream.next())
		XCTAssertTrue(stream.hasError())

		//test : expected
		stream = LogicStream.fromString("key someGoofyStuff :V")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())

		stream = LogicStream.fromString("key ")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())

		//test invalid key: start with digit
		stream = LogicStream.fromString("9hello:")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())

		//test invalid key: start with digit
		stream = LogicStream.fromString("hello:")
		next = "9"
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())

		//test invalid key: #
		stream = LogicStream.fromString("hell#o:")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())

		//test keyword
		stream = LogicStream.fromString("let:")
		next = nil
		key = ObjectParser.getKey(stream, &next)
		XCTAssertNil(key)
		XCTAssertTrue(stream.hasError())
	}


	func parseObjectTest() {
		var th = LogicTheory()
		var next:Character? = nil

		//tes empty object parsing
		var stream = LogicStream.fromString("}")
		var obj = ObjectParser.parse(stream, th, &next)

		XCTAssertNotNil(obj)
		XCTAssertEqual("{}", obj!.toJson())

		//test object with two properties, no spaces
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\",key2:\"4 5 6 __2-- 6 5 4\"}V")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)

		XCTAssertNotNil(obj)
		XCTAssertNotNil(obj!.getVar("key1"))
		XCTAssertNotNil(obj!.getVar("key2"))
		XCTAssertEqual("\"1 2 3 __1__ 3 2 1 \"", obj!.getVar("key1")!.toJson())
		XCTAssertEqual("V", stream.next())

		//test object with two properties, with random spaces
		stream = LogicStream.fromString("    key_1  :  \"1 2 3 __1__ 3 2 1\",   key2 :   \"4 5 6 __2-- 6 5 4\"   }V")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)

		XCTAssertNotNil(obj)
		XCTAssertNotNil(obj!.getVar("key_1"))
		XCTAssertNotNil(obj!.getVar("key2"))
		XCTAssertEqual("\"1 2 3 __1__ 3 2 1 \"", obj!.getVar("key_1")!.toJson())
		XCTAssertEqual("V", stream.next())

		//test nested objects
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\",key2:{nested: \"4 5 6 __2-- 6 5 4\"}}V")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)


		XCTAssertNotNil(obj)
		XCTAssertNotNil(obj!.getVar("key1"))
		XCTAssertNotNil(obj!.getVar("key2"))
		XCTAssertEqual("\"1 2 3 __1__ 3 2 1 \"", obj!.getVar("key1")!.toJson())
		XCTAssertEqual("\"4 5 6 __2-- 6 5 4 \"", obj!.getVarPath("key2", "nested")!.toJson())
		XCTAssertEqual("V", stream.next())

		//test end with comma no spaces
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\",key2: \"4 5 6 __2-- 6 5 4\",}V")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)


		XCTAssertNotNil(obj)
		XCTAssertNotNil(obj!.getVar("key1"))
		XCTAssertNotNil(obj!.getVar("key2"))
		XCTAssertEqual("\"1 2 3 __1__ 3 2 1 \"", obj!.getVar("key1")!.toJson())
		XCTAssertEqual("\"4 5 6 __2-- 6 5 4 \"", obj!.getVar("key2")!.toJson())
		XCTAssertEqual("V", stream.next())


		//test end with comma, random spaces
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\",key2: \"4 5 6 __2-- 6 5 4\"  ,   }V")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)

		XCTAssertNotNil(obj)
		XCTAssertNotNil(obj!.getVar("key1"))
		XCTAssertNotNil(obj!.getVar("key2"))
		XCTAssertEqual("\"1 2 3 __1__ 3 2 1 \"", obj!.getVar("key1")!.toJson())
		XCTAssertEqual("\"4 5 6 __2-- 6 5 4 \"", obj!.getVar("key2")!.toJson())
		XCTAssertEqual("V", stream.next())

		//test invalid end
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\" ,")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)
		XCTAssertNil(obj)

		//test no commas
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\" key2:\"1 __6-- 2\"}")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)
		XCTAssertNil(obj)

		//test multiple commas
		stream = LogicStream.fromString("key1:\"1 2 3 __1__ 3 2 1\" ,, key2:\"1 __6-- 2\"}")
		next = "{"
		obj = ObjectParser.parse(stream, th, &next)
		XCTAssertNil(obj)
	}




	static var allTests = [
		("parseKeyTest", parseKeyTest),
        ("parseObjectTest", parseObjectTest),
    ]
}
