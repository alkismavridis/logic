class LogicMemberAccess : LogicOperator {
	public static let INSTANCE = LogicMemberAccess()

	public func getPriority() -> UInt8 { return 19 }
	public func isR2L() -> Bool { return false }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		//get the string
		let memberOpt = stack.popLast()
		if memberOpt == nil || !(memberOpt is LogicMember) {
			stream.addError(1, "notALogicMember.")
			return
		}
		let member = memberOpt as! LogicMember

		//get the object
		var parentOpt = stack.popLast()
		if parentOpt == nil {
			stream.addError(1, "operandExpected.")
			return
		}

		else if parentOpt is LogicMember {
			//get from object
			let parent = parentOpt as! LogicMember

			//if no object is found, it means we have just a MemberAccess. Get from scope
			//same case if we dont have a LogicObjects before us...
			var obj:LogicValue?
			if parent.parent == nil { obj = sc.getVar(parent.name) }
			else { obj = parent.parent!.getVar(parent.name) }

			if obj == nil  {
				stream.addError(1, "Cannot access member null.")
				return
			}
			else if obj is LogicObject {
				member.parent = obj as! LogicObject
				stack.append(member)
				return
			}
			else if obj is LogicSentense {
				var access:SentenseAccess
				if member.name == "L" { access = SentenseAccess(obj as! LogicSentense, LogicMove.LEFT_SIDE) }
				else if member.name == "R" { access = SentenseAccess(obj as! LogicSentense, LogicMove.RIGHT_SIDE) }
				else {
					stream.addError(1, "notAMember.")
					return
				}

				stack.append(access)
				return
			}
			else {
				stream.addError(1, "notALogicSentense.")
				return
			}
		}
		else {
			stream.addError(1, "notALogicMember.")
			return
		}
	}
}
