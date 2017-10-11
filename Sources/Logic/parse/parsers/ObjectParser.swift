class ObjectParser {
	public static func parse(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?) -> LogicObject? {
		let ret = LogicObject()
		var key:String? = ""
		var value:LogicValue? = nil


		if next == "{" { next = stream.next() }

		//read the object
		A: while key != nil {
			key = getKey(stream, &next)
			if key == nil { break }

			//read value
			ParsingUtils.skipWhite(stream, &next)
			value = ExpressionParser.parse(stream, sc, &next, ExpressionParser.endOfObject)
			if stream.hasError() { return nil }
			else { ret.putVar(key!, value) }

			if next == nil { return nil }

			switch next! {
				case ",":
					next = stream.next()
					continue A
				case "}":
					break A
				default:
					stream.addMessage(ParseMessageType.ERROR, 1, "Comma, or end of object expected")
					return nil
			}
		}

		if stream.hasError() { return nil }
		return ret
	}


	public static func getKey(_ stream:LogicStream, _ next:inout Character?) -> String? {
		var ret = ""

		//find begining of key
		if next == nil || ParsingUtils.isAlpha(next!) {
			ParsingUtils.skipWhite(stream, &next)
		}

		//end of object?
		if next == "}" { return nil }

		//read the key
		var isFirst = true
		while next != nil && isValidKeyChar(next!, isFirst) {
			ret.append(next!)
			isFirst = false
			next = stream.next()
		}

		//check if key is empty
		if ret == "" {
			stream.addError(1, "Empty object key")
			skip(stream)
			return nil
		}

		//check if it is a keyword
		if KeywordUtils.get(ret) != nil {
			stream.addError(1, "Unexpecter keyword " + ret)
			skip(stream)
			return nil
		}

		//if ending caracter was a white space, find the first non white
		if next != nil && ParsingUtils.isAlpha(next!) { ParsingUtils.skipWhite(stream, &next) }
		if next == nil {
			stream.addError(1, "Character expected, nil was found")
			return nil
		}

		//see what comes next
		switch next! {
			case ":":
				return ret
			default:
				stream.addError(1, "\":\" expected but \(next!) was found.")
				skip(stream)
				return nil
		}
	}

	public static func isValidKeyChar(_ ch:Character, _ first:Bool) -> Bool {
		if first {
			return (ch >= "A" && ch <= "Z") || (ch >= "a" && ch <= "z") || ch == "_"
		}
		else {
			return (ch >= "A" && ch <= "Z") || (ch >= "a" && ch <= "z") || (ch >= "0" && ch<="9") || ch == "_"
		}
	}


	public static func skip(_ stream: LogicStream) {

	}
}
