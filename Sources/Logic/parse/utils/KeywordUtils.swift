enum KeywordUtils {
//FUNCTIONS
	public static func getExpressionKeyword(_ str:String) -> LogicOperator? {
		return nil
	}

	public static func get(_ str:String) -> LogicOperator? {
		switch str {
			case "let": return VariableDeclarator.INSTANCE
			default: return nil
		}
	}
}
