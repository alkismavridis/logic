class LogicTheory : LogicObject {
//Fields
	private var words:[LogicWord]


//Constructors
	override init() {
		words = [LogicWord]()
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
}
