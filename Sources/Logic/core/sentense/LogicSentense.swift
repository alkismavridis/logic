enum SentenseType {
	case AXIOM
	case THEOREM
	case PLASI
	case AXIOM_PLASI
}


class LogicSentense : LogicValue {
//FIELDS
	private var ph1:LogicPhrase, ph2:LogicPhrase
	private var bridge:LogicBridge
	private var type:SentenseType


//CONSTRUCTORS
	init(length1:UInt32 = 10, length2:UInt32 = 10) {
		ph1 = LogicPhrase(num:Int(length1))
		ph2 = LogicPhrase(num:Int(length2))
		bridge = LogicBridge()
		type = SentenseType.PLASI
	}

	convenience init(from base:LogicSentense, side:UInt8, check:Bool = true) {
		self.init(length1:base.ph1.getLength(), length2:base.ph2.getLength())
		self.start(from:base, side:side, check:check, 0, 0)
	}

	public static func getAxiomPlasi() -> LogicSentense {
		var ret = LogicSentense()
		ret.type = SentenseType.AXIOM_PLASI
		return ret
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

	public func getType() -> SentenseType { return type }
	public func setType(_ t:SentenseType) { self.type = t }





//LOGIC RULES
	public func isMoveLegal(_ mv:LogicMove, from base:LogicSentense)->UInt8 {
		let baseBridge:LogicBridge = base.bridge
		if mv.dir == LogicMove.RIGHT_TO_LEFT && baseBridge.type == LogicBridge.ONE_WAY {
			return LogicMove.ILLEGAL_DIRECTION
		}

		switch(mv.type) {
			case LogicMove.ALL:
				if (bridge.type == LogicBridge.ONE_WAY && baseBridge.grade <= bridge.grade) {
					return LogicMove.ILEGAL_FIRST_PHRASE_EDIT
				}
				else { return LogicMove.LEGAL }

			case LogicMove.FIRST:
				if (bridge.type == LogicBridge.ONE_WAY) {
					return LogicMove.ILEGAL_FIRST_PHRASE_EDIT
				}
				if(baseBridge.grade > bridge.grade) {return LogicMove.BASE_GRADE_TO_BIG}
				return LogicMove.LEGAL

			case LogicMove.SECOND:
				if (baseBridge.grade > bridge.grade) {return LogicMove.BASE_GRADE_TO_BIG}
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_FIRST:
				if (bridge.type == LogicBridge.ONE_WAY) {
					return LogicMove.ILEGAL_FIRST_PHRASE_EDIT
				}

				let side:UInt8 = mv.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
				if (baseBridge.grade != 0) {return LogicMove.BASE_GRADE_NOT_ZERO}
				if(!ph1.match(base.getPhrase(side), pos:mv.pos)) {return LogicMove.MATCH_FAILED}
				return LogicMove.LEGAL

			case LogicMove.ONE_IN_SECOND:
				let side:UInt8 = mv.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
				if (baseBridge.grade != 0) {return LogicMove.BASE_GRADE_NOT_ZERO}
				if (!ph2.match(base.getPhrase(side), pos:mv.pos)) {return LogicMove.MATCH_FAILED}
				return LogicMove.LEGAL

			default: return LogicMove.UNKNOWN_MOVE
		}
	}

	public static func isStartLegal(base:LogicSentense, side:UInt8)->UInt8 {
		if (side == LogicMove.RIGHT_SIDE && !base.getBridge().isTwoWay()) {
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
		ret.type = SentenseType.AXIOM

		return ret
	}

	public func setBridge(_ br:LogicBridge) -> Bool {
		if type != SentenseType.AXIOM_PLASI { return false }
		self.bridge = br
		return true
	}

	public func addToFirst(_ w:LogicWord) -> Bool {
		if type != SentenseType.AXIOM_PLASI { return false }
		ph1.add(w)
		return true
	}

	public func addToSecond(_ w:LogicWord) -> Bool {
		if type != SentenseType.AXIOM_PLASI { return false }
		ph2.add(w)
		return true
	}

	public func stabilizeAxiom() -> Bool {
		if type != SentenseType.AXIOM_PLASI { return false }
		self.type = SentenseType.AXIOM
		return true
	}


//THEOREM START
	public func start(from base:LogicSentense, side:UInt8, check:Bool, _ plus1:Int, _ plus2:Int) ->UInt8 {
		//check legal
		if check {
			let legal:UInt8 = LogicSentense.isStartLegal(base:base, side:side)
			if legal != LogicMove.LEGAL { return legal }
		}


		//do it
		switch side {
			case LogicMove.BOTH_SIDES:
				ph1.copy(from:base.ph1, plus:plus1)
				ph2.copy(from:base.ph2, plus:plus2)

			case LogicMove.LEFT_SIDE:
				ph2.copy(from:base.ph1, plus:plus2)
				ph1.copy(from:base.ph1, plus:plus1)

			case LogicMove.RIGHT_SIDE:
				ph1.copy(from:base.ph2, plus:plus1)
				ph2.copy(from:base.ph2, plus:plus2)

			default: return LogicMove.UNKNOWN_MOVE
		}

		bridge.grade = base.bridge.grade
		bridge.type = base.bridge.type

		type = SentenseType.PLASI
		return LogicMove.LEGAL
	}


//SELECTION
	public func select(base:LogicSentense, move:LogicMove, sel:LogicSelection, check:Bool)->UInt8 {
		//check legal
		var legal:UInt8;
		if check {
			legal = isMoveLegal(move, from:base)
			if legal != LogicMove.LEGAL { return legal }
		}

		switch move.type {
			case LogicMove.ALL:
				let side:UInt8 = move.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
				ph1.select(base.getPhrase(side), sel: &sel.getPtr1().pointee)
				ph2.select(base.getPhrase(side), sel: &sel.getPtr2().pointee)
				return LogicMove.LEGAL

			case LogicMove.FIRST:
				sel.clear2()
				let side:UInt8 = move.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
				ph1.select(base.getPhrase(side), sel: &sel.getPtr1().pointee)
				return LogicMove.LEGAL

			case LogicMove.SECOND:
				sel.clear1()
				let side:UInt8 = move.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
				ph2.select(base.getPhrase(side), sel: &sel.getPtr2().pointee)
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
		if (type != SentenseType.PLASI) { return }
		let old:LogicPhrase = base.getPhrase(side)
		let newPh:LogicPhrase = base.getTheOther(side)
		let oldLen:UInt32 = old.getLength()

		if sel.get1().count>0 { ph1.replace(newPh, oldLen, sel.get1()) }
		if sel.get2().count>0 { ph2.replace(newPh, oldLen, sel.get2()) }
	}

	public func selectAndReplace(base:LogicSentense, move:LogicMove, sel:LogicSelection, check:Bool) -> UInt8 {
		let s:UInt8 = select(base:base, move:move, sel:sel, check:check)

		let side:UInt8 = move.dir == LogicMove.LEFT_TO_RIGHT ? LogicMove.LEFT_SIDE : LogicMove.RIGHT_SIDE
		if s==LogicMove.LEGAL { replace(side, of:base, sel:sel) }
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
