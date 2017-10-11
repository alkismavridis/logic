class LogicNull : LogicValue {
	public static let INSTANCE = LogicNull()
	public override func toJson() -> String { return "null" }
}
