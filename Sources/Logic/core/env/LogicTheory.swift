class LogicTheory : LogicObject, Scope {
//Fields
	private var words:[LogicWord]
	private var parent:Scope?


//Constructors
	init(parent:Scope? = nil) {
		words = [LogicWord]()
		self.parent = parent
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
}
