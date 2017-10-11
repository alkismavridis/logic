class LeftParenthesis : LogicOperator {
	public static let INSTANCE = LeftParenthesis()


	public func getPriority() -> UInt8 { return 0 }
	public func isR2L() -> Bool { return false }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		stream.addError(1, "Trying to operate on LeftParenthesis")
	}
}
