class LogicStream  {
//FIELDS
	private var it:IndexingIterator<String.CharacterView>
	private var name:String
	private var onMessage: ((_ m:ParseMessage) -> Void)?
	private var errorFlag:Bool

	private var line:UInt32



//CONSTRUCTORS
	public init(
		_ it:IndexingIterator<String.CharacterView>,
		_ name:String,
		 _ onMessage: ((_ m:ParseMessage) -> Void)? = nil) {

		self.it = it
		self.name = name
		self.onMessage = onMessage
		self.errorFlag = false
		self.line = 1
	}

	public static func fromString(_ str:String, _ onMessage: ((_ m:ParseMessage) -> Void)? = nil) -> LogicStream {
		return LogicStream(str.characters.makeIterator(), "String source", onMessage)
	}

	public static func fromFile(_ url:String, _ onMessage: ((_ m:ParseMessage) -> Void)? = nil) -> LogicStream {
		//TODO
		return LogicStream(url.characters.makeIterator(), "String source", onMessage)
	}



//GETTERS AND SETTERS
	public func next() -> Character? {
		let ret = it.next()
		if ret == "\n" { line += 1 }
		return ret
	}

	public func getLine() -> UInt32 {
		return line
	}

	public func hasError() -> Bool {
		return errorFlag
	}



//MESSAGES
	public func addMessage(_ type:ParseMessageType, _ id:Int, _ str:String) {
		if type == ParseMessageType.ERROR { errorFlag = true }

		if onMessage == nil { return }
		let mes = ParseMessage(type, id, str)
		onMessage!(mes)
	}

	public func addError(_ id:Int, _ str:String) {
		errorFlag = true
		print(str)
		if onMessage == nil { return }
		let mes = ParseMessage(ParseMessageType.ERROR, id, str)
		onMessage!(mes)
	}
}
