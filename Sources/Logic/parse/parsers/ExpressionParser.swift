import Foundation

class ExpressionParser {

	/**
		This parses an expression, with all operators that fit the syntax.
		It stops and returns when an operator is found that does not match the syntax.
		The caller decides what to do with it.
	*/
	public static func parse(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?, _ endCheck: ((Character) -> Bool)) -> LogicValue? {
		var reversePolish = [AnyObject]()
		var ops = [LogicOperator]()
		toReversePolishNotation(&reversePolish, &ops, stream, sc, &next, endCheck)
		if stream.hasError() { return nil }

		let ret = calculateResult(reversePolish, stream, sc)
		if stream.hasError() { return nil }

		return ret
	}


	public static func toReversePolishNotation(
		_ stack:inout [AnyObject],
		_ ops:inout [LogicOperator],
		_ stream:LogicStream,
		_ sc:Scope,
		_ next:inout Character?,
		_ endCheck: ((Character) -> Bool)) {

		//1. get first character
		if next == nil || ParsingUtils.isAlpha(next!) {
			ParsingUtils.skipWhite(stream, &next)
		}

		//build the token array
		while next != nil && !endCheck(next!) {
			let nextToken = parseNextToken(stream, sc, &next)
			if stream.hasError() || nextToken == nil { return }


			//if is an operand, just add it
			if !(nextToken! is LogicOperator) {
				stack.append(nextToken!)
				continue
			}


			//Ok... It is an operator. Right Parenthesis or not?
			let op = nextToken as! LogicOperator
			if op is RightParenthesis {
				while true {
					//we should not be empty
					if ops.count == 0 {
						stream.addError(1, "Unexpected closing parenthesis found.")
						return
					}

					//remove it and break
					if ops.last! is LeftParenthesis {
						ops.removeLast()
						//TODO 1: here we must check if it was a funcion call
						//TODO 2: open and closing parenthesis cancel out.
						//TODO       This means that somebody could just write () everywhere.
						//TODO       This should not be valid syntax
						break
					}
					else {
						stack.append(ops.removeLast() as! AnyObject)
					}
				}
			}
			else {
				//we have an operator! empty all higher priority operators from ops

				while true {
					if ops.count == 0 { break }
					if ops.last!.getPriority() < op.getPriority() { break }
					else if ops.last!.getPriority() > op.getPriority() || !op.isR2L() {
						stack.append(ops.removeLast() as! AnyObject)
					}
					else { break }
				}

				ops.append(op)
			}
		}

		//empty the ops stack
		var last = ops.popLast()
		while last != nil {
			if last is LeftParenthesis {
				stream.addError(1, "Closing parenthesis expected.")
				return
			}
			stack.append(last as! AnyObject)
			last = ops.popLast()
		}
	}


	public static func calculateResult(_ data:[AnyObject], _ stream:LogicStream, _ sc:Scope) -> LogicValue? {
		var stack:[AnyObject] = []

		for token in data {
			if token is LogicOperator {
				//do what you must
				(token as! LogicOperator).operate(&stack, sc, stream)
				if stream.hasError() { return nil }
			}
			else { stack.append(token) }
		}

		//after this mess, there should be just one element in the stack
		if stack.count != 1 {
			stream.addError(1, "More than one element remained in stack")
			return nil
		}

		//return the result according to its type
		if stack[0] is LogicValue {
			return stack[0] as! LogicValue
		}

		else if stack[0] is LogicMember {
			return (stack[0] as! LogicMember).get(sc)
		}

		else if stack[0] is SentenseAccess {
			return (stack[0] as! SentenseAccess).get()
		}

		else {
			stream.addError(1, "Unknown element in result stack")
			return nil
		}
	}

	/**
		One character must be already read (next)
	*/
	public static func parseNextToken(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?) -> AnyObject? {
		//check nil case
		if next == nil {
			stream.addError(1, "Character expected, got nil")
			return nil
		}

		//decide variable type
		switch next! {
			case "\"":
				let ret = AxiomParser.parse(stream, sc)
				if ret == nil { return nil }

				ParsingUtils.skipWhite(stream, &next)
				return ret

			case "{":
				var type = OperatorUtils.extendLeftCurly(stream, &next)
				if type == OperatorUtils.THEOREM_START {
					let ret = ProofParser.parse(stream, sc, &next)
					if ret == nil { return nil }

					ParsingUtils.skipWhite(stream, &next)
					return ret
				}
				else {
					let ret = ObjectParser.parse(stream, sc, &next)
					if ret == nil { return nil }

					ParsingUtils.skipWhite(stream, &next)
					return ret
				}


			case ".":
				ParsingUtils.skipWhite(stream, &next)
				return LogicMemberAccess.INSTANCE

			case "*":
				ParsingUtils.skipWhite(stream, &next)
				return ReplaceAllOperator.INSTANCE

			case "<":
				let ret = OperatorUtils.extendLeftPointed(stream, &next) as? AnyObject
				if next != nil && ParsingUtils.isAlpha(next!) {
					ParsingUtils.skipWhite(stream, &next)
				}
				return ret

			case ">":
				let ret = OperatorUtils.extendRightPointed(stream, &next) as? AnyObject
				if next != nil && ParsingUtils.isAlpha(next!) {
					ParsingUtils.skipWhite(stream, &next)
				}
				return ret

			case "~":
				ParsingUtils.skipWhite(stream, &next)
				return TheoremStarter.INSTANCE


			case "(":
				ParsingUtils.skipWhite(stream, &next)
				return LeftParenthesis.INSTANCE

			case ")":
				ParsingUtils.skipWhite(stream, &next)
				return RightParenthesis.INSTANCE

			case "}":
				let ret = OperatorUtils.extendRightCurly(stream, &next) as? AnyObject
				if next != nil && ParsingUtils.isAlpha(next!) {
					ParsingUtils.skipWhite(stream, &next)
				}
				return ret

			case "=":
				ParsingUtils.skipWhite(stream, &next)
				return LogicAssignment.INSTANCE

			case ",":
				ParsingUtils.skipWhite(stream, &next)
				return LogicComma.INSTANCE

			case "a"..."z",
				 "A"..."Z":
				var ret:String = ""
				while next != nil && ObjectParser.isValidKeyChar(next!, false) {
		 			ret.append(next!)
		 			next = stream.next()
		 		}

				if next != nil && ParsingUtils.isAlpha(next!) {
					ParsingUtils.skipWhite(stream, &next)
				}

				//check if it is a keyword
				let keyword = KeywordUtils.get(ret)
				if keyword != nil {
					return keyword as! AnyObject?
				}
				else {
					return (LogicMember(ret, nil) as AnyObject?)
				}

			case "0"..."9":
				var ret:String = ""
				while next != nil && isValidIntChar(next!) {
		 			ret.append(next!)
		 			next = stream.next()
		 		}

				if next != nil && ParsingUtils.isAlpha(next!) {
					ParsingUtils.skipWhite(stream, &next)
				}

				return (NSNumber(value:Int(ret)!) as! AnyObject?)

			default:
				stream.addError(1, "Unknown token start: \(next!)")
				return nil
		}
	}


//EXPRESSION END CALLBACKS
	public static func endOfObject(_ ch:Character) -> Bool {
		switch ch {
			case ",", "}":
				return true
			default:
				return false
		}
	}

	public static func endOfStatement(_ ch:Character) -> Bool {
		return ch == ";"
	}

	public static func endOfVarDeclaration(_ ch:Character) -> Bool {
		return ch == "," || ch == ";"
	}


//TOKEN ENDS
	public static func isValidIntChar(_ ch:Character) -> Bool {
		if ch >= "0" && ch <= "9" { return true }
		return false
	}
}
