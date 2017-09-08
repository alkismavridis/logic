protocol Scope {
	func getVar(_ name:String) -> LogicValue?
	func getVar(safe:Bool, path:[String]) throws -> LogicValue?
	func getVarPath(_ path:String...) -> LogicValue?
	func getVar(safe:Bool, path:String...) throws -> LogicValue?
	func putVar(_ name:String, _ val:LogicValue?)
	func remove(_ name:String)
	
	func getWord(_ word:String)->LogicWord

	func getParentScope() -> Scope?
	func getParentTheory() -> LogicTheory?
}
