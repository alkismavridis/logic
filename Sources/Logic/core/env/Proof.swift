class Proof:Scope {
//FIELDS
	private var parent:Scope?
	private var theory:LogicTheory
	private var vars:LogicObject
	private var ret:LogicSentense
	private var checks:Bool


//CONSTRUCTORS
	public init(parent:Scope, length1:UInt32 = 10, length2:UInt32 = 10) {
		self.parent = parent

		if parent is LogicTheory { theory = parent as! LogicTheory }
		else { theory = parent.getParentTheory()! }

		vars = LogicObject()
		ret = LogicSentense(length1:length1, length2:length2)
		checks = true
	}


//GETTERS AND SETTERS
	public func hasChecks() -> Bool { return checks }
	public func setChecks(_ checks:Bool) { self.checks = checks }



//OVERRIDES
	func getOwnVar(_ name:String) -> LogicValue? {
		return vars.getVar(name)
	}

	func getVar(_ name:String) -> LogicValue? {
		let ret:LogicValue? = vars.getVar(name)
		if ret != nil { return ret }
		if parent == nil { return nil }
		return parent!.getVar(name)
	}

	func putVar(_ name:String, _ val:LogicValue?) {
		vars.putVar(name, val)
	}

	func removeVar(_ name:String) {
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

	func getScopeWithVar(_ name:String) -> Scope? {
		if self.getOwnVar(name) != nil { return self }
		if parent == nil { return nil }
		return parent!.getScopeWithVar(name)
	}
}
