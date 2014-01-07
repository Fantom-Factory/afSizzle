
** Test Str:
** attr1[wot] attr2[wot=ever] attr3[wot~=ever] attr4[wot|=ever] attr5[wot~="ever"] attr6[wot|='ever']
internal const class Selector {
	private static const Str 	attrStr 	:= Str<|\[(\w+)(?:([\~|])?=[\'\"]?([^\]\'\"]+)[\'\"]?)?\]|>.replace("\\w", Str<| [^#\.\s\[\]\<\+\~|] |>.trim)
	private static const Regex 	attrRegex	:= Regex.fromStr(attrStr)
	
	const Str 	type
	const Str 	id
	const Str[]	classes
	const AttrSelector[] 	attrSelectors
	const Combinator		combinator

	new make(RegexMatcher matcher) {
		attrValue 		:= matcher.group(4) ?: ""
		attrMatcher		:= attrRegex.matcher(attrValue)
		selectors 		:= AttrSelector[,]
		while (attrMatcher.find) {
			selectors.add(AttrSelector(attrMatcher))
		}
		
		this.type 		= matcher.group(1) ?: "*"
		this.id 		= matcher.group(2)?.getRange(1..-1) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.combinator	= Combinator.fromCombinator(matcher.group(5) ?: "")
		this.attrSelectors = selectors
	}
	
	override Str toStr() {
		sId := id.isEmpty ? "" : "#${id}"
		sClasses := classes.isEmpty ? "" : "." + classes.join(".") 
		return "${type}${sId}${sClasses}"
	}
}

internal const class AttrSelector {
	const Str 	name
	const Str?	type
	const Str?	value

	new make(RegexMatcher matcher) {
		this.name 	= matcher.group(1)
		this.type 	= matcher.group(2)
		this.value	= matcher.group(3)
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
