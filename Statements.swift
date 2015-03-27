﻿import Sugar
import Sugar.Collections
import Sugar.Linq

/* Statements */

public __abstract class CGStatement: CGEntity {
}

public __abstract class CGBaseMultilineStatement : CGStatement {
	public var Lines: List<String>

	public init(_ lines: List<String>) {
		Lines = lines
	}
	public init(_ lines: String) {
		Lines = lines.Replace("\r", "").Split("\n").ToList()
	}
}

public class CGRawStatement : CGBaseMultilineStatement { // not language-agnostic. obviosuly.
}

public class CGCommentStatement : CGBaseMultilineStatement {
}

public __abstract class CGBlockStatement : CGStatement {
	public var Statements: List<CGStatement>

	public init() {
		Statements = List<CGStatement>()
	}
	public init(_ statements: List<CGStatement>) {
		Statements = statements
	}
}

public __abstract class CGNestingStatement : CGStatement {
	public var NestedStatement: CGStatement

	public init(_ nestedStatement: CGStatement) {
		NestedStatement = nestedStatement
	}
}

public class CGBeginEndBlockStatement : CGBlockStatement { //"begin/end" or "{/}"
}

public class CGIfThenElseStatement: CGStatement {
	public var Condition: CGExpression
	public var IfStatement: CGStatement
	public var ElseStatement: CGStatement?
	
	public init(_ condition: CGExpression, _ ifStatement: CGStatement, _ elseStatement: CGStatement? = nil) {
		Condition = condition
		IfStatement = ifStatement
		ElseStatement = elseStatement
	}	
}

public enum CGLoopDirectionKind {
	case Forward
	case Backward
}

public class CGForToLoopStatement: CGNestingStatement {
	public var LoopVariableName: String
	public var LoopVariableType: CGTypeReference? // nil means it won't be declared, just used
	public var StartValue: CGIntegerLiteralExpression
	public var EndValue: CGIntegerLiteralExpression
	public var Directon: CGLoopDirectionKind = .Forward

	public init(_ loopVariableName: String, _ loopVariableType: CGTypeReference, _ startValue: CGIntegerLiteralExpression, _ endValue: CGIntegerLiteralExpression, _ statement: CGStatement) {
		super.init(statement)
		LoopVariableName = loopVariableName
		LoopVariableType = loopVariableType
		StartValue = startValue
		EndValue = endValue
	}
}

public class CGForEachLoopStatement: CGNestingStatement {
	public var LoopVariableName: String
	public var LoopVariableType: CGTypeReference //not all languages require this but some do, so we'll require it
	public var Collection: CGExpression
	
	public init(_ loopVariableName: String, _ loopVariableType: CGTypeReference, _ collection: CGExpression, _ statement: CGStatement) {
		super.init(statement)
		LoopVariableName = loopVariableName
		LoopVariableType = loopVariableType
		Collection = collection
	}
}

public class CGWhileDoLoopStatement: CGNestingStatement {
	public var Condition: CGExpression

	public init(_ condition: CGExpression, _ statement: CGStatement) {
		super.init(statement)
		Condition = condition
	}
}

public class CGDoWhileLoopStatement: CGBlockStatement { // also "repeat/until"
	public var Condition: CGExpression

	public init(_ condition: CGExpression, _ statements: List<CGStatement>) {
		super.init(statements)
		Condition = condition
	}
}

public class CGInfiniteLoopStatement: CGNestingStatement {}

public class CGSwitchStatement: CGStatement {
	public var Expression: CGExpression
	public var Cases: List<CGSwitchStatementCase>
	public var DefaultCase: CGSwitchStatementCase?

	public init(_ expression: CGExpression, _ cases: List<CGSwitchStatementCase>, _ defaultCase: CGSwitchStatementCase? = nil) {
		Expression = expression
		DefaultCase = defaultCase
		if let cases = cases {
			Cases = cases
		} else {
			Cases = List<CGSwitchStatementCase>()
		}
	}
}

public class CGSwitchStatementCase : CGEntity {
	public var CaseExpression: CGExpression
	public var Statements: List<CGStatement>

	public init(_ caseExpression: CGExpression, _ statements: List<CGStatement>) {
		CaseExpression = caseExpression
		Statements = statements
	}
}

public class CGLockingStatement: CGNestingStatement {
	var Expression: CGExpression
	
	public init(_ expression: CGExpression, _ nestedStatement: CGStatement) {
		super.init(nestedStatement)
		Expression = expression
	}
}

public class CGUsingStatement: CGNestingStatement {
	var Expression: CGExpression
	
	public init(_ expression: CGExpression, _ nestedStatement: CGStatement) {
		super.init(nestedStatement)
		Expression = expression
	}
}

public class CGAutoReleasePoolStatement: CGNestingStatement {}

public class CGTryFinallyCatchStatement: CGBlockStatement {
	public var FinallyStatements = List<CGStatement>()
	public var CatchBlocks = List<CGCatchBlockStatement>()	
}

public class CGCatchBlockStatement: CGBlockStatement {
	public var Name: String
	public var `Type`: CGTypeReference
	public var Filter: CGExpression?

	public init(_ name: String, _ type: CGTypeReference) {
		Name = name
		`Type` = type
	}
}

/* Simple Statements */

public class CGReturnStatement: CGStatement {
	public var Value: CGExpression?
	
	public init() {
	}
	public init(_ value: CGExpression?) {
		Value = value
	}
}

public class CGThrowStatement: CGStatement {
	var Exception: CGExpression?
	
	public init() {
	}
	public init(_ exception: CGExpression?) {
		Exception = exception
	}
}

public class CGBreakStatement: CGStatement {}

public class CGContinueStatement: CGStatement {}

public class CGEmptyStatement: CGStatement {}

public class CGConstructorCallStatement : CGStatement {
	public var CallSite: CGExpression = CGSelfExpression.SelfExpression //Should be set to CGSelfExpression or CHInheritedExpression
	public var ConstructorName: String? // an optionally be provided for languages that support named .ctors
	public var Parameters: List<CGCallParameter>
	public var PropertyInitializers = List<CGCallParameter>() // for Oxygene extnded .ctor calls

	public init(_ callSite: CGExpression, _ parameters: List<CGCallParameter>?) {
		CallSite = callSite
		if let parameters = parameters {
			Parameters = parameters
		} else {
			Parameters = List<CGCallParameter>()
		}
	}
}

/* Operator statements */

public class CGVariableDeclarationStatement: CGStatement {
	public var Name: String
	public var `Type`: CGTypeReference?
	public var Value: CGExpression?
	public var Constant = false

	public init(_ name: String, _ type: CGTypeReference?, value: CGExpression?) {
		Name = name
		`Type` = type
		Value = value
	}
}

public class CGAssignmentStatement: CGStatement {
	public var Target: CGExpression
	public var Value: CGExpression
	
	public init(_ target: CGExpression, _ value: CGExpression) {
		Target = target
		Value = value
	}
}