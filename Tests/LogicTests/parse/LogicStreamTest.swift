import XCTest
import Foundation
@testable import Logic

class LogicStreamTest: XCTestCase {
	func fromStringTest() {
		/*let str = "12345"
		var it = str.characters.makeIterator()

		while let c = it.next() {
			print(c)
		}

		let inp = FileHandle(forReadingAtPath:"/tmp/test")
		let data = inp!.readDataToEndOfFile()
		print(String(data:data, encoding:String.Encoding.utf8)!)*/

		let stream = LogicStream.fromString("1\n234\n\n5\n")

		XCTAssertEqual("1", stream.next()!)
		XCTAssertEqual(1, stream.getLine())

		XCTAssertEqual("\n", stream.next()!)
		XCTAssertEqual(2, stream.getLine())

		XCTAssertEqual("2", stream.next()!)
		XCTAssertEqual(2, stream.getLine())

		XCTAssertEqual("3", stream.next()!)
		XCTAssertEqual(2, stream.getLine())

		XCTAssertEqual("4", stream.next()!)
		XCTAssertEqual(2, stream.getLine())

		XCTAssertEqual("\n", stream.next()!)
		XCTAssertEqual(3, stream.getLine())

		XCTAssertEqual("\n", stream.next()!)
		XCTAssertEqual(4, stream.getLine())

		XCTAssertEqual("5", stream.next()!)
		XCTAssertEqual(4, stream.getLine())

		XCTAssertEqual("\n", stream.next()!)
		XCTAssertEqual(5, stream.getLine())

		XCTAssertNil(stream.next())
		XCTAssertEqual(5, stream.getLine())

		XCTAssertNil(stream.next())
		XCTAssertEqual(5, stream.getLine())
	}

	func fromFileTest() {
		//TODO
	}

	static var allTests = [
        ("fromStringTest", fromStringTest),
		("fromFileTest", fromFileTest)
    ]
}
