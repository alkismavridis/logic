struct LogicMove {
	//SIDES
	public static let LEFT_SIDE:UInt8 = 1
	public static let RIGHT_SIDE:UInt8 = 2
	public static let BOTH_SIDES:UInt8 = 3

	//DIRECTIONS
	public static let LEFT_TO_RIGHT:UInt8 = 1
	public static let RIGHT_TO_LEFT:UInt8 = 2


	//Moves
    public static let ALL:UInt8 = 1
	public static let FIRST:UInt8 = 2
	public static let SECOND:UInt8 = 3
	public static let ONE_IN_FIRST:UInt8 = 4
	public static let ONE_IN_SECOND:UInt8 = 5

	//MOVE LEGAL STATUS
	public static let LEGAL:UInt8 = 1
	public static let ILLEGAL_DIRECTION:UInt8 = 2
	public static let ILEGAL_FIRST_PHRASE_EDIT:UInt8 = 3
	public static let BASE_GRADE_TO_BIG:UInt8 = 4
	public static let BASE_GRADE_NOT_ZERO:UInt8 = 5
	public static let MATCH_FAILED:UInt8 = 6
	public static let UNKNOWN_MOVE:UInt8 = 7

//FIELDS
	public var type:UInt8		//MOVE_ALL or MOVE_FIRST or MOVE_SECOND or MOVE_ONE_IN_FIRST or MOVE_ONE_IN_SECOND
	public var dir:UInt8		//MOVE_FIRST or MOVE_SECOND
	public var pos:UInt32		//for MOVE_ONE_IN_FIRST and MOVE_ONE_IN_SECOND only

//CONSTRUCTORS
  	init(_ t:UInt8, _ d:UInt8 = LogicMove.LEFT_TO_RIGHT, _ p:UInt32 = 0) {
		type=t
		dir=d
		pos=p
	}

//GETTERS AND SETTERS
	public func isSingle()->Bool {return type >= LogicMove.ONE_IN_FIRST}
};
