class ProofEnd : LogicOperator {
	public static let INSTANCE = ProofEnd()

	public func getPriority() -> UInt8 { return 16 }
	public func isR2L() -> Bool { return false }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		stream.addError(1, "invalidOperator: ProofEnd")
	}
}
