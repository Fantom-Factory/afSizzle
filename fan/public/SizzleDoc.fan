using xml

class SizzleDoc {
	
	private Str:DomBucket	buckets	:= Str:DomBucket[:] { caseInsensitive = true }
	private XElem			root
	private Str				rootPath
	private DomBucket		rootBucket
	
	
	private new make(XElem elem) {
		this.root = elem
		this.rootPath = pathTo(elem)
		this.rootBucket = DomBucket(elem, true)
	}
	
	static new fromStr(Str xml) {
		fromXDoc(XParser(xml.in).parseDoc)
	}

	static new fromXDoc(XDoc doc) {
		fromXElem(doc.root)
	}

	static new fromXElem(XElem elem) {
		SizzleDoc.make(elem)
	}
	
	
	
	@Operator
	XElem[] get(Str selector) {
		// TODO: make static
		s := Str<| \s+(\w1+)?(#\w1+)?(\.[\w2\.]+)?((?:\[[^\]]+\])+)?(?:\s*([>+]))? |>.trim.replace("\\w1", Str<| [^#\.\s\[\]\<\+] |>.trim).replace("\\w2", Str<| [^#\s\[\]\<\+] |>.trim)
		regex	:= Regex.fromStr(s)
		
		matcher := regex.matcher(" " + selector)
		
		selectors := Selector[,]
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}		

		// FIXME: better err msg
		if (selectors.isEmpty)
			throw Err("Shitty css selector: $selector")
		
		got := rootBucket.select(selectors.last)
		
		if (selectors.size == 1)
			return got

		Env.cur.err.printLine(selectors)
		
		got = got.findAll |element| {
			elem := (XNode?) element
			matches := true
			selectors[0..<-1].eachr |sel| {
				elem = findElemMatch(elem, sel)
				Env.cur.err.printLine(elem)
				if (!isElement(elem)) {
					matches = false
					return
				}
			}
			return matches
		}
		
		return got
	}
	
	private XNode? findElemMatch(XNode? elem, Selector selector) {
		if (selector.type == SelectorType.descendant) {
			elem = elem?.parent
			while (isElement(elem)) {
				bucket := buckets.getOrAdd(pathTo(elem)) { DomBucket(elem, false) }
				matches := bucket.select(selector)
				if (matches.size > 1)
					throw Err("WTF! Should have ONE or ZERO elements: ${matches}")
				if (matches.size == 1)
					return matches.first
				elem = elem.parent
			}
			return null
		}
		if (selector.type == SelectorType.child) {
			elem = elem.parent
			if (!isElement(elem))
				return null
			bucket := buckets.getOrAdd(pathTo(elem)) { DomBucket(elem, false) }
			matches := bucket.select(selector)
			if (matches.size > 1)
				throw Err("WTF! Should have ONE or ZERO elements: ${matches}")
			if (matches.size == 1)
				return matches.first
			return null
		}
		// TODO
		return elem
	}
	
	** An alias for 'get()'
	XElem[] select(Str selector) {
		get(selector)
	}
	
	internal static Str pathTo(XElem elem, StrBuf path := StrBuf()) {
		name := "/${elem.name}"
		if (isElement(elem.parent)) {
			sibs := ((XElem) elem.parent).elems.findAll { it.name == elem.name }
			if (sibs.size > 1)
				name += "[" + sibs.indexSame(elem).toStr + "]"
			pathTo(elem.parent, path)
		}
		path.add(name)
		return path.toStr
	}

	internal static XElem[] path(XElem elem, XElem[] elemPath := XElem[,]) {
		if (isElement(elem.parent)) {
			path(elem.parent, elemPath)
		}
		return elemPath.add(elem)
	}
	
	private static Bool isElement(XNode? node) {
		(node as XElem) != null
	}
}


internal class DomBucket {
	
	ElemBucket 		typeBucket	:= ElemBucket() 
	ElemBucket 		classBucket	:= ElemBucket() 
	Str:ElemBucket 	attrBuckets	:= Str:ElemBucket[:] { caseInsensitive = true }
	
	new make(XElem elem, Bool recurse) {
		walk(elem, recurse)
	}
	
	private Void walk(XElem elem, Bool recurse) {
		typeBucket[elem.name] = elem
		
		elem.attr("class", false)?.val?.split?.each {
			classBucket[it] = elem
		}

		elem.attrs.each {
			bucket := attrBuckets.getOrAdd(it.name) { ElemBucket() }
			bucket[it.val.trim] = elem
		}
		
		if (recurse)
			elem.elems.each { walk(it, recurse) }
	}
	
	XElem[] select(Selector selector) {
		nmaes 	:= (selector.name == "*") ? typeBucket.all : typeBucket[selector.name]
		gotten	:= nmaes
		
		if (!selector.id.isEmpty) {
			ids 	:= attrBuckets["id"]?.get(selector.id)
			gotten	= gotten.intersection(ids)
		}

		selector.classes.each {
			css	:= classBucket[it]
			gotten	= gotten.intersection(css)
		}
		
		return gotten
	}
}

internal class ElemBucket {
	Str:XElem[]	elems	:= [:]

	@Operator
	XElem[] get(Str? name) {
		elems[name ?: Str.defVal] ?: XElem#.emptyList
	}

	@Operator
	Void set(Str name, XElem elem) {
		elems.getOrAdd(name) { XElem[,] }.add(elem)
	}
	
	once XElem[] all() {
		elems.vals.flatten.unique
	}
}

internal const class Selector {
	
	const Str 	name
	const Str 	id
	const Str[]	classes
	const Str 	attrs
	const SelectorType	type
	
	new make(RegexMatcher matcher) {
		this.name 		= matcher.group(1) ?: "*"
		this.id 		= matcher.group(2)?.getRange(1..-1) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.attrs 		= matcher.group(4) ?: ""
		this.type 		= SelectorType.fromSelector(matcher.group(5) ?: "")
	}
	
	override Str toStr() {
		sId := id.isEmpty ? "" : "#${id}"
		sClasses := classes.isEmpty ? "" : "." + classes.join(".") 
		return "${name}${sId}${sClasses}"
	}
}

internal enum class SelectorType {
	descendant	(""),
	child		(">"),
	sibling		("+");
	
	const Str selector;
	
	private new make(Str selector) {
		this.selector = selector
	}
	
	static SelectorType fromSelector(Str selector) {
		SelectorType.vals.find { it.selector == selector } ?: throw Err("Selector '${selector}' not known")
	}
}
