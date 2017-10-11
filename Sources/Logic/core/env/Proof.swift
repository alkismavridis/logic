class Proof:Scope {
//FIELDS
	private var parent:Scope?
	private var theory:LogicTheory
	private var vars:LogicObject
	private var ret:LogicSentense?
	private var checks:Bool


//CONSTRUCTORS
	public init(parent:Scope) {
		self.parent = parent

		if parent is LogicTheory { theory = parent as! LogicTheory }
		else { theory = parent.getParentTheory()! }

		vars = LogicObject()
		ret = nil
		checks = true
	}


//GETTERS AND SETTERS
	public func hasChecks() -> Bool { return checks }
	public func setChecks(_ checks:Bool) { self.checks = checks }

	public func setSentense(_ sen:LogicSentense?) { self.ret = sen }
	public func getSentense() -> LogicSentense? { return self.ret }



//OVERRIDES
	public func getOwnVar(_ name:String) -> LogicValue? {
		return vars.getVar(name)
	}

	public func getVar(_ name:String) -> LogicValue? {
		let ret:LogicValue? = vars.getVar(name)
		if ret != nil { return ret }
		if parent == nil { return nil }
		return parent!.getVar(name)
	}

	public func putVar(_ name:String, _ val:LogicValue?) {
		vars.putVar(name, val)
	}

	public func removeVar(_ name:String) {
		vars.remove(name)
	}

	public func getWord(_ word:String)->LogicWord {
		return theory.getWord(word)
	}

	public func getParentScope() -> Scope? {
		return parent
	}

	public func getParentTheory() -> LogicTheory? {
		return theory
	}

	public func getScopeWithVar(_ name:String) -> Scope? {
		if self.getOwnVar(name) != nil { return self }
		if parent == nil { return nil }
		return parent!.getScopeWithVar(name)
	}

	public func getCurrentSelection() -> LogicSelection {
		return theory.getCurrentSelection()
	}
}
