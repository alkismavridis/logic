enum GetParhError: Error {
	case NullPointerError
	case ClassCastError
}


class LogicObject : LogicValue {
//FIELDS
	var fields: [String: LogicValue?]


//CONSTRUCTORS
	override init() {
		self.fields = [String: LogicValue?]()
		super.init()
	}


//GETTERS
	public func get(_ name: String) -> LogicValue? {
		let ret:LogicValue?? = fields[name]
		if ret == nil { return nil }
		else { return  ret! }
	}


/**If safe is set to false, an exception is thrown instead of nil being returned*/
	public func get(safe:Bool, path:[String]) throws -> LogicValue? {
		var currentObj:LogicValue? = self

		for str in path {
			//check if nil
			if currentObj == nil {
				if safe { return nil }
				else { throw GetParhError.NullPointerError }
			}

			//check if type is object, and proceed the chain
			if let obj = currentObj as? LogicObject {
				currentObj = obj.get(str)
			}
			else {
				if safe { return nil }
				else { throw GetParhError.ClassCastError }
			}
		}

		return currentObj
	}

	public func getPath(_ path:String...) -> LogicValue? {
		do {
			return try self.get(safe: true, path:path)
		}
		catch let error1 as Error { return nil }
	}

	public func get(safe:Bool, path:String...) throws -> LogicValue? {
		return try self.get(safe:safe, path:path)
	}



//SETTERS
	public func put(_ name:String, _ val:LogicValue?) {
		fields[name] = val
	}

	public func remove(_ name:String) {
		fields.removeValue(forKey:name)
	}


//JSON SERIALIZATION
	public override func toJson() -> String {
		var ret = "{"

		for (key, val) in fields {
			if val != nil { ret += "\"\(key)\":\(val!.toJson())," }
			else { ret += "\"\(key)\":null," }
		}

		ret += "}"
		return ret
	}
}
