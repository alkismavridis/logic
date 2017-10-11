import Foundation

class FirstSingleReplace : LogicOperator {
	public static let INSTANCE = FirstSingleReplace()

	public func getPriority() -> UInt8 { return 13 }
	public func isR2L() -> Bool { return true }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		let baseArg = stack.popLast()
		let positionArg = stack.popLast()
		let plasiArg = stack.popLast()

		if !(sc is Proof) {
			stream.addError(1, "FirstSingleReplace is allowed only inside a Logic Proof.")
			return
		}
		let proof = sc as! Proof

		//decode numberArg: it MUST be a NSNumber
		if positionArg == nil || !(positionArg is NSNumber) {
			stream.addError(1, "numberExpected.")
			return
		}
		let position = (positionArg as! NSNumber).uint32Value

		//decode BASE
		var base:LogicSentense
		var side:UInt8

		if baseArg == nil {
			stream.addError(1, "nullBase.")
			return
		}
		else if baseArg is SentenseAccess {
			base = (baseArg as! SentenseAccess).sent
			side = (baseArg as! SentenseAccess).side
		}
		else {
			stream.addError(1, "notASentenseAccess")
			return
		}


		//	DECODE PLASI
		if plasiArg == nil {
			var plasi = proof.getSentense()
			if plasi == nil {
				stream.addError(1, "nullPlasi")
				return
			}

			let result = plasi!.selectAndReplace(base:base, move:LogicMove(LogicMove.ONE_IN_FIRST, side, position), sel:sc.getCurrentSelection(), check:proof.hasChecks())
			if result == LogicMove.LEGAL {
				stack.append(plasi!)
				return
			}
			else {
				stream.addError(1, "illegalMove \(result)")
				return
			}
		}
		else if plasiArg is LogicMember {
			var plasiOpt = (plasiArg as! LogicMember).get(sc)
			if plasiOpt == nil || !(plasiOpt is LogicSentense) {
				stream.addError(1, "notASentense")
				return
			}
			let plasi = (plasiOpt as! LogicSentense)

			let result = plasi.selectAndReplace(base:base, move:LogicMove(LogicMove.ONE_IN_FIRST, side, position), sel:sc.getCurrentSelection(), check:proof.hasChecks())
			if result == LogicMove.LEGAL {
				stack.append(plasi)
				return
			}
			else {
				stream.addError(1, "illegalMove " + String(result))
				return
			}
		}
		else {
			stream.addError(1, "notALogicMember")
			return
		}
	}
}
