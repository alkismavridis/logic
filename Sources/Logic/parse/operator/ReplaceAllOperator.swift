class ReplaceAllOperator : LogicOperator {
	public static let INSTANCE = ReplaceAllOperator()

	public func getPriority() -> UInt8 { return 13 }
	public func isR2L() -> Bool { return true }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		let baseArg = stack.popLast()
		let plasiArg = stack.popLast()

		if !(sc is Proof) {
			stream.addError(1, "notAProof")
			return
		}
		let proof = sc as! Proof

		//decode BASE
		var base:LogicSentense
		var side:UInt8

		if baseArg == nil {
			stream.addError(1, "nullBase")
			return
		}
		else if baseArg is SentenseAccess {
			base = (baseArg as! SentenseAccess).sent
			side = (baseArg as! SentenseAccess).side
		}
		else {
			stream.addError(1, "notALogicSentenseAccess")
			return
		}


		//	DECODE PLASI
		if plasiArg == nil {
			let plasi = proof.getSentense()
			if plasi == nil {
				stream.addError(1, "nullPlasi")
				return
			}

			if plasi!.selectAndReplace(base:base, move:LogicMove(LogicMove.ALL, side), sel:sc.getCurrentSelection(), check:proof.hasChecks()) == LogicMove.LEGAL {
				stack.append(plasi!)
				return
			}
			else {
				stream.addError(1, "illegalMove")
				return
			}
		}
		else if plasiArg is LogicMember {
			let plasiOpt = (plasiArg as! LogicMember).get(sc)
			if plasiOpt == nil || !(plasiOpt is LogicSentense) {
				stream.addError(1, "notALogicSentense")
				return
			}
			let plasi = (plasiOpt as! LogicSentense)

			if plasi.selectAndReplace(base:base, move:LogicMove(LogicMove.ALL, side), sel:sc.getCurrentSelection(), check:proof.hasChecks()) == LogicMove.LEGAL {
				stack.append(plasi)
				return
			}
			else {
				stream.addError(1, "illegalMove")
				return
			}
		}
		else {
			stream.addError(1, "notALogicMember")
			return
		}
	}
}
