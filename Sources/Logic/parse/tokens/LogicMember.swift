class LogicMember {
	public var name:String
	public var parent: LogicObject?

	public init(_ str:String, _ par:LogicObject?) {
		self.name = str
		self.parent = par
	}


//GETTERS AND SETTERS
	public func get(_ sc:Scope) -> LogicValue? {
		if parent == nil { return sc.getVar(name) }
		else { return parent!.getVar(name) }
	}

	public func put(_ val:LogicValue?, _ sc:Scope) {
		if parent == nil {
			let targetScope = sc.getScopeWithVar(name)
			if targetScope == nil { sc.putVar(name, val) }
			else { targetScope!.putVar(name, val) }
		}
		else { parent!.putVar(name, val) }
	}
}
