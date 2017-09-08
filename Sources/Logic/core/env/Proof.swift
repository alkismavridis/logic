class Proof:Scope {
//FIELDS
	private var parent:Scope?
	private var theory:LogicTheory
	private var vars:LogicObject
	private var ret:LogicSentense


//CONSTRUCTORS
	public init(parent:Scope, length1:UInt32 = 10, length2:UInt32 = 10) {
		self.parent = parent

		if parent is LogicTheory { theory = parent as! LogicTheory }
		else { theory = parent.getParentTheory()! }

		vars = LogicObject()
		ret = LogicSentense(length1:length1, length2:length2)
	}


//GETTERS AND SETTERS



//OVERRIDES
	func getVar(_ name:String) -> LogicValue? {
		return vars.getVar(name)
	}

	func getVar(safe:Bool, path:[String]) throws -> LogicValue? {
		do { return try vars.getVar(safe:safe, path:path) }
	}

	func getVarPath(_ path:String...) -> LogicValue? {
		do { return try vars.getVar(safe:true, path:path) }
		catch _ { return nil }
	}

	func getVar(safe:Bool, path:String...) throws -> LogicValue? {
		do { return try vars.getVar(safe:safe, path:path) }
	}

	func putVar(_ name:String, _ val:LogicValue?) {
		vars.putVar(name, val)
	}

	func remove(_ name:String) {
		vars.remove(name)
	}

	func getWord(_ word:String)->LogicWord {
		return theory.getWord(word)
	}

	func getParentScope() -> Scope? {
		return parent
	}

	func getParentTheory() -> LogicTheory? {
		return theory
	}
}
