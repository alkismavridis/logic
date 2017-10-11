class ProofParser {
	public static func parse(_ stream:LogicStream, _ sc:Scope, _ next:inout Character?) -> LogicSentense? {
		var end = false
		let proof = Proof(parent:sc)

		while !stream.hasError() && !end {
			CommandParser.parse(stream, proof, &next, &end, CommandParser.endOfProof)
		}

		return proof.getSentense()
	}
}
