
internal const class Selector {
	private static const Regex attrRegex := Regex<|\[(\w+)(?:(.)=[\'\"](\w*)[\'\"])?\]|>
	
	const Str 	type
	const Str 	id
	const Str[]	classes
//	const Str 	attrs
	const Combinator	combinator
	
	new make(RegexMatcher matcher) {
		this.type 		= matcher.group(1) ?: "*"
		this.id 		= matcher.group(2)?.getRange(1..-1) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.combinator	= Combinator.fromCombinator(matcher.group(5) ?: "")
//		this.attrs 		= matcher.group(4) ?: ""

		attrValue 		:= matcher.group(4) ?: ""
		attrMatcher		:= attrRegex.matcher(attrValue)
		
//		grp1=name
//		grp1=type
//		grp3=val
	}
	
	override Str toStr() {
		sId := id.isEmpty ? "" : "#${id}"
		sClasses := classes.isEmpty ? "" : "." + classes.join(".") 
		return "${type}${sId}${sClasses}"
	}
}

internal const class AttrSelector {
	
	new make(RegexMatcher matcher) {
		
	}
}

internal enum class Combinator {
	descendant	(""),
	child		(">"),
	sibling		("+");
	
	const Str combinator;
	
	private new make(Str combinator) {
		this.combinator = combinator
	}
	
	static Combinator fromCombinator(Str combinator) {
		Combinator.vals.find { it.combinator == combinator } ?: throw Err("Combinator '${combinator}' not known")
	}
}
