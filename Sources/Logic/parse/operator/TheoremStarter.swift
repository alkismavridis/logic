class TheoremStarter : LogicOperator {
	public static let INSTANCE = TheoremStarter()

	public func getPriority() -> UInt8 { return 13 }
	public func isR2L() -> Bool { return true }

	public func operate(_ stack:inout [AnyObject], _ sc:Scope, _ stream:LogicStream) {
		let baseArg = stack.popLast()
		let plasiArg = stack.popLast()

		//decode BASE
		var base:LogicSentense
		var side:UInt8

		if baseArg == nil {
			stream.addError(1, "nullBase")
			return
		}

		//we have a Logic member. It MUST have a Sentense
		else if baseArg is LogicMember {
			let baseOpt = (baseArg as! LogicMember).get(sc)

			if baseOpt is LogicSentense {
				base = baseOpt as! LogicSentense
				side = LogicMove.BOTH_SIDES
			}
			else {
				stream.addError(1, "notASentense")
				return
			}
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
			if !(sc is Proof) {
				stream.addError(1, "notAProof")
				return
			}
			let plasi = LogicSentense()
			if plasi.start(from:base, side:side, check:true, 0, 0) == LogicMove.LEGAL {
				(sc as! Proof).setSentense(plasi)
				stack.append(plasi)
				return
			}
			else {
				stream.addError(1, "illegalStart")
				return
			}
		}
		else if plasiArg is LogicMember {
			let plasi = LogicSentense()
			if plasi.start(from:base, side:side, check:true, 0, 0) == LogicMove.LEGAL {
				(plasiArg as! LogicMember).put(plasi, sc)
				stack.append(plasi)
				return
			}
			else {
				stream.addError(1, "illegalStart")
				return
			}
		}
		else {
			stream.addError(1, "notALogicMember")
			return
		}
	}
}
