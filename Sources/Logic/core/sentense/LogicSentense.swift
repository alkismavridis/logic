class LogicSentense : LogicValue {
//FIELDS
	private var ph1:LogicPhrase, ph2:LogicPhrase
	private var bridge:LogicBridge


//CONSTRUCTORS
	init(length1:UInt32 = 10, length2:UInt32 = 10) {
		ph1 = LogicPhrase(num:Int(length1))
		ph2 = LogicPhrase(num:Int(length2))
		bridge = LogicBridge()
	}


//GETTERS AND SETTERS
	public func getPhrase(_ side:UInt8) -> LogicPhrase {
		if side==LogicMove.LEFT_SIDE {return ph1}
		return ph2
	}

	public func getTheOther(_ side:UInt8) -> LogicPhrase {
		if side==LogicMove.LEFT_SIDE {return ph2}
		return ph1
	}

	public func getBridge()->LogicBridge {return bridge}



//LOGIC RULES
	public func isMoveLegal(_ mv:LogicMove, on base:LogicSentense)->UInt8 {
		let baseBridge:LogicBridge = base.bridge
		if mv.side == 2 && baseBridge.type == LogicBridge.ONE_WAY {
			return LogicMove.ILLEGAL_DIRECTION
		}

		switch(mv.type) {
			case LogicMove.ALL:
				if (bridge.type == LogicBridge.ONE_WAY && baseBridge.grade <= bridge.grade) {
					return LogicMove.ILEGAL_FIRST_PHRASE_EDIT
				}
				else { return LogicMove.LEGAL }

			case LogicMove.FIRST:
				if (bridge.type == LogicBridge.ONE_WAY) {return LogicMove.PLASI_IS_ONE_WAY}
				if(baseBridge.grade > bridge.grade) {return LogicMove.BASE_GRADE_TO_BIG}
				return LogicMove.LEGAL

			case LogicMove.SECOND:
				if (baseBridge.grade > bridge.grade) {return LogicMove.BASE_GRADE_TO_BIG}
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_FIRST:
				if (baseBridge.grade != 0) {return LogicMove.BASE_GRADE_NOT_ZERO}
				if(!ph1.match(base.getPhrase(mv.side), pos:mv.pos)) {return LogicMove.MATCH_FAILED}
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_SECOND:
				if (baseBridge.grade != 0) {return LogicMove.BASE_GRADE_NOT_ZERO}
				if (!ph2.match(base.getPhrase(mv.side), pos:mv.pos)) {return LogicMove.MATCH_FAILED}
				return LogicMove.LEGAL

			default: return LogicMove.UNKNOWN_MOVE
		}
	}

	public func isStartLegal(base:LogicSentense, side:UInt8)->UInt8 {
		if (side == LogicMove.LEFT_SIDE && !base.getBridge().isTwoWay()) {
			return LogicMove.ILLEGAL_DIRECTION
		}
		return LogicMove.LEGAL
	}



//AXIOM CREATION
	public class func generateAxiom(left:[LogicWord?], right:[LogicWord?], type:UInt8, grade:UInt16)->LogicSentense {
		let ret:LogicSentense = LogicSentense(length1:UInt32(left.count), length2:UInt32(right.count))

		ret.ph1 = LogicPhrase(words:left)
		ret.ph2 = LogicPhrase(words:right)
		ret.bridge.type = type
		ret.bridge.grade = grade

		return ret
	}


//THEOREM START
	public func start(from base:LogicSentense, side:UInt8, check:Bool, _ plus1:Int, _ plus2:Int) ->UInt8 {
		//check legal
		if check {
			let legal:UInt8 = isStartLegal(base:base, side:side)
			if legal != 0 {return legal}
		}

		//do it
		switch side {
			case LogicMove.ALL:
				ph1.copy(from:base.ph1, plus:plus1)
				ph2.copy(from:base.ph2, plus:plus2)

			case LogicMove.FIRST:
				ph2.copy(from:base.ph1, plus:plus2)
				ph1.copy(from:base.ph1, plus:plus1)

			case LogicMove.SECOND:
				ph1.copy(from:base.ph2, plus:plus1)
				ph2.copy(from:base.ph2, plus:plus2)

			default: return LogicMove.UNKNOWN_MOVE
		}

		bridge.grade = base.bridge.grade
		bridge.type = base.bridge.type
		return LogicMove.LEGAL
	}


//SELECTION
	public func select(base:LogicSentense, move:LogicMove, sel:LogicSelection, check:Bool)->UInt8 {
		//check legal
		var legal:UInt8;
		if check {
			legal = isMoveLegal(move, on:base)
			if legal != LogicMove.LEGAL { return legal }
		}

		switch move.type {
			case LogicMove.ALL:
				ph1.select(base.getPhrase(move.side), sel: &sel.getPtr1().pointee)
				ph2.select(base.getPhrase(move.side), sel: &sel.getPtr2().pointee)
				return LogicMove.LEGAL

			case LogicMove.FIRST:
				sel.clear1()
				ph1.select(base.getPhrase(move.side), sel: &sel.getPtr1().pointee)
				return LogicMove.LEGAL

			case LogicMove.SECOND:
				sel.clear2()
				ph2.select(base.getPhrase(move.side), sel: &sel.getPtr2().pointee)
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_FIRST:
				sel.clear1()
				sel.clear2()
				sel.addTo1(move.pos)
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_SECOND:
				sel.clear1()
				sel.clear2()
				sel.addTo2(move.pos)
				return LogicMove.LEGAL

			default: return LogicMove.UNKNOWN_MOVE
		}
	}

	public func replace(_ side:UInt8, of base:LogicSentense, sel:LogicSelection) {
		let old:LogicPhrase = base.getPhrase(side)
		let newPh:LogicPhrase = base.getTheOther(side)
		let oldLen:UInt32 = old.getLength()

		if sel.get1().count>0 { ph1.replace(newPh, oldLen, sel.get1()) }
		if sel.get2().count>0 { ph2.replace(newPh, oldLen, sel.get2()) }
	}

	public func selectAndReplace(base:LogicSentense, move:LogicMove, sel:LogicSelection, check:Bool) -> UInt8 {
		let s:UInt8 = select(base:base, move:move, sel:sel, check:check)
		if s==0 { replace(move.side, of:base, sel:sel) }
		return s
	}


//space managment
	public func saveSpace() {
		ph1.saveSpace()
		ph2.saveSpace()
	}


//SERIALIZATION
	public override func toJson() -> String {
		var ret = "\""
		let words1:[LogicWord?] = ph1.getWords()
		for i in 0..<Int(ph1.getLength()) {
			if words1[i] == nil { ret += "NULL " }
			else { ret += words1[i]!.toString() + " " }
		}

		ret += "__" + String(bridge.grade) + (bridge.isTwoWay() ? "__ " : "-- ")

		let words2:[LogicWord?] = ph2.getWords()
		for i in 0..<Int(ph2.getLength()) {
			if words2[i] == nil { ret += "NULL " }
			else { ret += words2[i]!.toString() + " " }
		}
		return ret + "\""
	}
}
