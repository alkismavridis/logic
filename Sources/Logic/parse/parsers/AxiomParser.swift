import Foundation

class AxiomParser {
	public static func parse(_ stream:LogicStream, _ sc:Scope) -> LogicSentense? {
		let ret = LogicSentense.getAxiomPlasi()
		var end = false

		//read first sentense and bridge
		while true {
			let str = nextString(stream, &end)
			if end {
				stream.addMessage(ParseMessageType.ERROR, 1, "Axiom ended before reading a bridge.")
				return nil
			}

			let bridge = toBridge(str!)
			if bridge != nil {
				ret.setBridge(bridge!)
				break
			}
			else { ret.addToFirst(sc.getWord(str!)) }
		}

		//read second sentense and closing "
		while true {
			let str = nextString(stream, &end)
			if str==nil { break }

			let bridge = toBridge(str!)
			if bridge != nil {
				stream.addMessage(ParseMessageType.ERROR, 1, "Second bridge found in Axiom")
				if !end { skip(stream) }
				return nil
			}
			else { ret.addToSecond(sc.getWord(str!)) }

			if end { break }
		}

		ret.stabilizeAxiom()
		return ret
	}

	public static func nextString(_ stream:LogicStream, _ end: inout Bool) -> String? {
		var ret = ""

		//skip white spaces
		var next:Character? = " "
		while next == " " { next = stream.next() }

		//read the string
		while next != nil && next != "\"" && next != " " {
			ret.append(next!)
			next = stream.next()
		}

		//set the end flag
		end = (next != " ")

		//return
		if ret == "" { return nil }
		return ret
	}


	//INFO
	public static func toBridge(_ str:String) -> LogicBridge? {
		if !str.hasPrefix("__") { return nil }
		if str.characters.count < 5 { return nil }

		//read grade
		let grade = UInt16( str[ str.index(str.startIndex, offsetBy:2) ... str.index(str.endIndex, offsetBy:-3) ] )
		if grade == nil { return nil }

		//read type
		let type = str.hasSuffix("__") ? LogicBridge.TWO_WAY : LogicBridge.ONE_WAY
		return LogicBridge(grade:grade!, type:type)
	}

	public static func skip(_ stream:LogicStream) {
		var next = stream.next()
		while next != nil && next != "\"" {
			next = stream.next()
		}
	}

}
