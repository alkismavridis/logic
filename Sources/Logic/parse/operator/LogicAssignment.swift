class LogicAssignment : LogicOperator {
	public static let INSTANCE = LogicAssignment()

	public func getPriority() -> UInt8 { return 3 }
	public func isR2L() -> Bool { return true }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		let valOpt = stack.popLast()
		let memberOpt = stack.popLast()

		//member to act uppon: LogicMember (only)
		if memberOpt == nil || !(memberOpt is LogicMember) {
			stream.addError(1, "Invalid operand for LogicAssignment: expected variable or member.")
			return
		}
		let member = memberOpt as! LogicMember

		//value: LogicValue or LogicMember nil
		if valOpt == nil || valOpt is LogicValue {
			member.put(valOpt as? LogicValue, sc)
			stack.append(member)
			return
		}
		else if valOpt is LogicMember {
			member.put((valOpt as! LogicMember).get(sc), sc)
			stack.append(member)
			return
		}
		else {
			stream.addError(1, "Invalid operand for LogicAssignment.")
			return
		}
	}
}
