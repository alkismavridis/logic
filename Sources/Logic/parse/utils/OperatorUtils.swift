class OperatorUtils {
//FIELDS
	public static let OBJECT_START:UInt8 = 1
	public static let OBJECT_END:UInt8 = 2
	public static let THEOREM_START:UInt8 = 3
	public static let THEOREM_END:UInt8 = 4





	public static func extendLeftCurly(_ stream:LogicStream, _ next:inout Character?) -> UInt8 {
		next = stream.next()
		return (next == "{" ) ? THEOREM_START : OBJECT_START
	}

	public static func extendRightCurly(_ stream:LogicStream, _ next:inout Character?) -> LogicOperator {
		next = stream.next()
		if next == nil { return LogicObjectEnd.INSTANCE }
		switch next! {
			case "}":
				next = stream.next()
				return ProofEnd.INSTANCE
			default:
				return LogicObjectEnd.INSTANCE
		}
	}


	public static func extendLeftPointed(_ stream:LogicStream, _ next:inout Character?) -> LogicOperator {
		next = stream.next()
		if next == nil { return FirstPhraseReplace.INSTANCE }
		switch next! {
			case "<":
				next = stream.next()
				return FirstPhraseReplace.INSTANCE
			default:
				return FirstSingleReplace.INSTANCE
		}
	}

	public static func extendRightPointed(_ stream:LogicStream, _ next:inout Character?) -> LogicOperator {
		next = stream.next()
		if next == nil { return SecondPhraseReplace.INSTANCE }
		switch next! {
			case ">":
				next = stream.next()
				return SecondPhraseReplace.INSTANCE
			default:
				return SecondSingleReplace.INSTANCE
		}
	}
}
