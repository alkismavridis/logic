class FirstPhraseReplace : LogicOperator {
	public static let INSTANCE = FirstPhraseReplace()

	public func getPriority() -> UInt8 { return 13 }
	public func isR2L() -> Bool { return true }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		let baseArg = stack.popLast()
		let plasiArg = stack.popLast()

		if !(sc is Proof) {
			stream.addError(1, "FirstPhraseReplace is allowed only inside a Logic Proof.")
			return
		}
		let proof = sc as! Proof

		//decode BASE
		var base:LogicSentense
		var side:UInt8

		if baseArg == nil {
			stream.addError(1, "FirstPhraseReplace with null base.")
			return
		}
		else if baseArg is SentenseAccess {
			base = (baseArg as! SentenseAccess).sent
			side = (baseArg as! SentenseAccess).side
		}
		else {
			stream.addError(1, "FirstPhraseReplace base is not a SentenseAccess.")
			return
		}


		//	DECODE PLASI
		if plasiArg == nil {
			let plasi = proof.getSentense()
			if plasi == nil {
				stream.addError(1, "FirstPhraseReplace cannot operate on null Plasi.")
				return
			}

			let result = plasi!.selectAndReplace(base:base, move:LogicMove(LogicMove.FIRST, side), sel:sc.getCurrentSelection(), check:proof.hasChecks())
			if result == LogicMove.LEGAL {
				stack.append(plasi!)
				return
			}
			else {
				stream.addError(1, "Illegal FirstPhraseReplace attemted." + String(result))
				return
			}
		}
		else if plasiArg is LogicMember {
			let plasiOpt = (plasiArg as! LogicMember).get(sc)
			if plasiOpt == nil || !(plasiOpt is LogicSentense) {
				stream.addError(1, "FirstPhraseReplace: Plasi is not a LogicSentense.")
				return
			}
			let plasi = (plasiOpt as! LogicSentense)

			let result = plasi.selectAndReplace(base:base, move:LogicMove(LogicMove.FIRST, side), sel:sc.getCurrentSelection(), check:proof.hasChecks())
			if result == LogicMove.LEGAL {
				stack.append(plasi)
				return
			}
			else {
				stream.addError(1, "Illegal FirstPhraseReplace attemted. \(result)")
				return
			}
		}
		else {
			stream.addError(1, "FirstPhraseReplace: Plasi is not a LogicSentense.")
			return
		}
	}
}
