protocol Scope {
	func getVar(_ name:String) -> LogicValue?
	func getOwnVar(_ name:String) -> LogicValue?

	func putVar(_ name:String, _ val:LogicValue?)
	func removeVar(_ name:String)

	func getWord(_ word:String)->LogicWord

	func getParentScope() -> Scope?
	func getParentTheory() -> LogicTheory?

	func getScopeWithVar(_ name:String) -> Scope?
}
