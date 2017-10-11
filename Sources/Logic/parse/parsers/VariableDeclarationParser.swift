class VariableDeclarationParser {

	/** THIS IS INVOKED AFTER let KEYWORD IS READ*/
	public static func parse(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?) {
		while true {
			//read key
			var key:String = ""
			while next != nil && ObjectParser.isValidKeyChar(next!, false) {
				key.append(next!)
				next = stream.next()
			}

			//check if we have also a value
			if next != nil && ParsingUtils.isAlpha(next!) {
				ParsingUtils.skipWhite(stream, &next)
			}

			if next == nil {
				sc.putVar(key, LogicNull.INSTANCE)
				return
			}

			switch next! {
				case ",":
					sc.putVar(key, LogicNull.INSTANCE)
					ParsingUtils.skipWhite(stream, &next)
					continue

				case ";":
					sc.putVar(key, LogicNull.INSTANCE)
					return

				case "=":
					ParsingUtils.skipWhite(stream, &next)
					var reversePolish = [AnyObject]()
					var ops = [LogicOperator]()
			 		ExpressionParser.toReversePolishNotation(&reversePolish, &ops, stream, sc, &next, ExpressionParser.endOfVarDeclaration)
					if stream.hasError() { return }

					var value = ExpressionParser.calculateResult(reversePolish, stream, sc)
					if stream.hasError() { return }

					//put the variable
					sc.putVar(key, value)

					//check end
					if next == nil { return }
					switch next! {
						case ",":
							ParsingUtils.skipWhite(stream, &next)
							continue
						case ";": return
						default:
							stream.addError(1, "Unexpeced end of declaration: " + String(next!))
							return
					}


				default:
					stream.addError(1, "Unexpeced end of declaration: " + String(next!))
					return
			}
		}
	}


}
