//MAYBE NOT NEEDED AND NOT USED

class LogicObjectField {
//FIELDS
	private var name:String
	private var value:LogicValue?
	private var next:LogicObjectField? = nil


//CONSTRUCTOR
	init(name:String, value:LogicValue?) {
		self.name = name
		self.value = value
	}

//GETTERS
	public func getNext() ->  LogicObjectField? { return next }
	public func getValue() -> LogicValue? { return value }


//SETTERS
	public func setNext(_ next:LogicObjectField) { self.next = next }
	public func setValue(_ val:LogicValue) { self.value = val }
}
