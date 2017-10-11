class CommandParser {
	@discardableResult
	public static func parse(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?, _ end:inout Bool, _ endCheck: ((AnyObject) -> Bool)) -> LogicValue? {
		let first = ExpressionParser.parseNextToken(stream, sc, &next)
		if stream.hasError() { return nil }

		if first == nil {
			end = true
			return nil
		}

		if first is VariableDeclarator {
			if next != nil && ParsingUtils.isAlpha(next!) {
				ParsingUtils.skipWhite(stream, &next)
			}
			VariableDeclarationParser.parse(stream, sc, &next)
			return LogicNull.INSTANCE
		}
		//more special cases

		else {
			//check end
			if endCheck(first!) {
				end = true
				return nil
			}

			if next != nil && ParsingUtils.isAlpha(next!) {
				ParsingUtils.skipWhite(stream, &next)
			}

			var stack = [AnyObject]()
			var ops = [LogicOperator]()

			if first is LogicOperator { ops.append(first as! LogicOperator) }
			else { stack.append(first!) }

			ExpressionParser.toReversePolishNotation(&stack, &ops, stream, sc, &next, ExpressionParser.endOfStatement)
			end = false
			return ExpressionParser.calculateResult(stack, stream, sc)
		}
	}


//SCOPE ENDERS
	public static func endOfProof(_ token:AnyObject) -> Bool {
		return token is ProofEnd
	}

}
