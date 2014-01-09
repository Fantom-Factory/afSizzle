using xml

** Test Str:
** attr1[wot] attr2[wot=ever] attr3[wot~=ever] attr4[wot|=ever] attr5[wot~="ever"] attr6[wot|='ever']
internal const class Selector {
	private static const Str 	attrStr 	:= Str<|\[(\w+)(?:([\~|])?=[\'\"]?([^\]\'\"]+)[\'\"]?)?\]|>.replace("\\w", Str<| [^#\.\s\[\]\<\+\~|=] |>.trim)
	private static const Regex 	attrRegex	:= Regex.fromStr(attrStr)
	
	const Str 	type
	const Str 	id
	const Str[]	classes
	const AttrSelector[] 	attrSelectors
	const PseudoSelector	pseudoSelector
	const Combinator		combinator

	new make(RegexMatcher matcher) {
		attrValue 		:= matcher.group(4) ?: ""
		attrMatcher		:= attrRegex.matcher(attrValue)
		selectors 		:= AttrSelector[,]
		while (attrMatcher.find) {
			selectors.add(AttrSelector(attrMatcher))
		}
		
		this.type 		= matcher.group(1) ?: ""
		this.id 		= matcher.group(2) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.combinator	= Combinator.fromCombinator(matcher.group(5) ?: "")
		this.attrSelectors 	= selectors
		this.pseudoSelector	= PseudoSelector(matcher) 

		// if this selector has nothing to match - ensure it doesn't match everything!
		if (this.attrSelectors.isEmpty && this.type.isEmpty && this.id.isEmpty && this.classes.isEmpty && !pseudoSelector.active)
			this.type = ""
		else
			if (type.isEmpty)
				this.type = "*"
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

	XElem[] matchMultiNode(Str:ElemBucket buckets) {
		if (isAny) {
			return buckets[name]?.all ?: XElem#.emptyList
		}
		if (isExact) {
			return buckets[name]?.elems?.findAll |val, key -> Bool| { 
				key == value
			}?.vals?.flatten ?: XElem#.emptyList
		}
		if (isWhitespace) {
			return buckets[name]?.elems?.findAll |val, key -> Bool| { 
				key.split.contains(value)
			}?.vals?.flatten ?: XElem#.emptyList
		}
		if (isLang) {
			return buckets[name]?.elems?.findAll |val, key -> Bool| { 
				key == value || key.startsWith("${value}-")
			}?.vals?.flatten ?: XElem#.emptyList
		}
		throw Err("WTF is a ${toStr}?")
	}

	Bool matchSingleNode(Str:Str attrs) {
		if (isAny) {
			return attrs.containsKey(name)
		}
		if (isExact) {
			return attrs[name] == value
		}
		if (isWhitespace) {
			return attrs[name]?.split?.contains(value) ?: false
		}
		if (isLang) {
			return attrs[name] == value || attrs[name].startsWith("${value}-") 
		}
		throw Err("WTF is a ${toStr}?")
	}
	
	Bool isAny() {
		value == null && type == null
	}

	Bool isExact() {
		value != null && type == null
	}

	Bool isWhitespace() {
		value != null && type == "~"
	}

	Bool isLang() {
		value != null && type == "|"
	}
	
	override Str toStr() {
		eq	:= value != null ? (type ?: "") + "=${value}" : ""
		return "[${name}${eq}]"
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

internal const class PseudoSelector {
	const Str? 	name
	const Str?	value

	new make(RegexMatcher matcher) {
		this.name 	= matcher.group(6)
		this.value 	= matcher.group(7)
	}
	
	Bool active() {
		if (name == "lang")
			return value != null
		return name != null 
	}
	
	Bool matches(XElem elem) {
		if (!active)
			return true
		if (name == "first-child") {
			return (elem.parent as XElem)?.elems?.first == elem
		}
		if (name == "lang") {
			lang := findLang(elem)
			Env.cur.err.printLine(value+lang)
			return lang == value || (lang?.startsWith("${value}-") ?: false)
		}
		throw Err("WTF is a '$name($value)' pseudo selector?")
	}
	
	private Str? findLang(XNode? elem) {
		if (elem == null)
			return null
		// CASE-INSENSITIVITY
		lang := (elem as XElem)?.attrs?.find { it.name.equalsIgnoreCase("lang") || it.name.equalsIgnoreCase("xml:lang") }?.val
		return (lang != null) ? lang.lower : findLang(elem.parent)
	}
}
