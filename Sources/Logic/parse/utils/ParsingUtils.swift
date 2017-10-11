class ParsingUtils {
	public static let WHITES:[Character] = [" ", "\t", "\n", "\r"]

	public static func isAlpha(_ ch:Character) -> Bool {
		for wh in WHITES {
			if ch == wh { return true }
		}

		return false
	}

	public static func skipWhite(_ stream:LogicStream, _ end: inout Character?) {
		var ch = stream.next()
		while ch != nil && isAlpha(ch!) {
			ch = stream.next()
		}

		end = ch
	}
}
