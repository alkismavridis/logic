protocol LogicOperator  {
	func getPriority() -> UInt8
	func isR2L() -> Bool

	func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream)
}
