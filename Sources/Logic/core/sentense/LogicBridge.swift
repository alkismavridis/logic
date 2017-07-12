struct LogicBridge {
//STATIC
	public static let ONE_WAY:UInt8 = 1
	public static let TWO_WAY:UInt8 = 2

//FIELDS
	public var type:UInt8 = 0
	public var grade:UInt16 = 0

//CONSTRUCTORS
	init(grade:UInt16 = 0, type:UInt8 = LogicBridge.ONE_WAY) {
		self.grade = grade
		self.type = type
	}

//GETTERS AND SETTERS
	public func isTwoWay()->Bool { return self.type == LogicBridge.TWO_WAY }
}
