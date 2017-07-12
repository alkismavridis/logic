class LogicSelection {
	//FIELDS
	private var s1:[UInt32]
	private var s2: [UInt32]


	//CONSTRUCTORS
	init(_ i1:Int = 100, _ i2:Int = 100) {
		self.s1 = [UInt32](repeating:0, count:i1)
		self.s2 = [UInt32](repeating:0, count:i2)
	}


	//GETTERS AND SETTERS
	public func get1()->[UInt32] { return s1 }
	public func get2()->[UInt32] { return s2 }

	public func getPtr1()->UnsafeMutablePointer<[UInt32]> {
		return withUnsafeMutablePointer(to: &s1, { $0 })
	}
	public func getPtr2()->UnsafeMutablePointer<[UInt32]> {
		return withUnsafeMutablePointer(to: &s2, { $0 })
	}

	public func addTo1(_ i:UInt32) { s1.append(i) }
	public func addTo2(_ i:UInt32) { s2.append(i) }

	public func clear1() { s1.removeAll() }
	public func clear2() { s2.removeAll() }
}
