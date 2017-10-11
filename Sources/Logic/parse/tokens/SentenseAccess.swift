class SentenseAccess {
//FIELDS
	public var sent: LogicSentense
	public var side: UInt8


//CONSTRUCTORS
	public init(_ sent:LogicSentense, _ side:UInt8) {
		self.sent = sent
		self.side = side
	}

//METHODS
	public func get() -> LogicPhrase {
		return sent.getPhrase(side)
	}
}
