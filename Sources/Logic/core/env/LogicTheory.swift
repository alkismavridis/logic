class LogicTheory : LogicValue, Scope {
//Fields
	private var words:[LogicWord]
	private var parent:Scope?
	private var vars:LogicObject


//Constructors
	init(parent:Scope? = nil) {
		self.words = [LogicWord]()
		self.parent = parent
		self.vars = LogicObject()
		super.init()
	}


//GETTERS AND SETTERS
	public func getWords()->[LogicWord] { return self.words }
	public func getWordCount()->Int { return self.words.count }

	public func getWord(_ word:String)->LogicWord {
		let ind:Int? = self.words.index(where: { (el)->Bool in
			return el.toString() == word
		})

		if ind == nil {
			let ret:LogicWord = LogicWord(word)
			self.words.append(ret)
			return ret
		}
		return words[ind!]
	}

	public func getParentScope() -> Scope? {
		return parent
	}

	public func getParentTheory() -> LogicTheory? {
		if parent == nil { return nil }
		if parent is LogicTheory { return (parent as! LogicTheory) }
		return parent!.getParentTheory()
	}

	func getScopeWithVar(_ name:String) -> Scope? {
		if self.getOwnVar(name) != nil { return self }
		if parent == nil { return nil }
		return parent!.getScopeWithVar(name)
	}

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
}
