using xml

// TODO: Make SizzleDoc const - we shouldn't need to cache the single element buckets - which could be simplified anyway

** Holds a representation of an XML document that may be queried with CSS selectors. 
** 
** 'SizzleDoc' is intended for re-use with multiple CSS selections:
**
**    doc    := SizzleDoc("""<html><p class="welcome">Hello from Sizzle!</p></html>""")
**    elems1 := doc.select("p.welcome")
**    elems2 := doc.select("html p")
** 
class SizzleDoc {
	
	private static const Str	selectorStr		:= Str<| \s+(\w1+)?(#\w1+)?(\.[\w2\.]+)?((?:\[[^\]]+\])+)?(?:\s*([>+]))? |>.trim.replace("\\w1", Str<| [^#\.\s\[\]\<\+] |>.trim).replace("\\w2", Str<| [^#\s\[\]\<\+] |>.trim)
	private static const Regex	selectorRegex	:= Regex.fromStr(selectorStr)
	
	private Str:DomBucket	buckets	:= Str:DomBucket[:] { caseInsensitive = true }
	private XElem			root
	private DomBucket		rootBucket
	
	private new make(XElem elem) {
		this.root = elem
		this.rootBucket = DomBucket(elem, true)
	}

	** Create a 'SizzleDoc' from an XML string.
	static new fromStr(Str xml) {
		fromXDoc(XParser(xml.in).parseDoc)
	}

	** Create a 'SizzleDoc' from an XML document.
	static new fromXDoc(XDoc doc) {
		fromXElem(doc.root)
	}

	** Create a 'SizzleDoc' from an XML element.
	static new fromXElem(XElem elem) {
		SizzleDoc.make(elem)
	}

	** Queries the xml document with the given CSS selector any returns any matching elements.
	@Operator
	XElem[] get(Str cssSelector) {
		matcher := selectorRegex.matcher(" " + cssSelector)
		
		selectors := Selector[,]
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}		

		if (selectors.isEmpty)
			throw SizzleErr(ErrMsgs.selectorNotValid(cssSelector))
		
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
	
	** An alias for 'get()'
	XElem[] select(Str selector) {
		get(selector)
	}
	
	private XNode? findElemMatch(XNode? elem, Selector selector) {
		if (selector.combinator == Combinator.descendant) {
			elem = elem?.parent
			while (isElement(elem)) {
				bucket := buckets.getOrAdd(pathTo(elem)) { DomBucket(elem, false) }
				matches := bucket.select(selector)
				if (matches.size == 1)
					return matches.first
				elem = elem.parent
			}
			return null
		}
		
		if (selector.combinator == Combinator.child) {
			elem = elem?.parent
			if (!isElement(elem))
				return null
			bucket := buckets.getOrAdd(pathTo(elem)) { DomBucket(elem, false) }
			matches := bucket.select(selector)
			if (matches.size == 1)
				return matches.first
			return null
		}

		if (selector.combinator == Combinator.sibling) {
			parent := elem?.parent
			if (!isElement(parent))
				return null
			index := (parent as XElem).elems.indexSame(elem) - 1
			if (index < 1)
				return null
			elem = (parent as XElem).elems.getSafe(index-1)
			if (!isElement(elem))
				return null			
			bucket := buckets.getOrAdd(pathTo(elem)) { DomBucket(elem, false) }
			matches := bucket.select(selector)
			if (matches.size == 1)
				return matches.first
			return null
		}
		
		return null
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
		types 	:= (selector.type == "*") ? typeBucket.all : typeBucket[selector.type]
		gotten	:= types
		
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
	
	const Str 	type
	const Str 	id
	const Str[]	classes
	const Str 	attrs
	const Combinator	combinator
	
	new make(RegexMatcher matcher) {
		this.type 		= matcher.group(1) ?: "*"
		this.id 		= matcher.group(2)?.getRange(1..-1) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.attrs 		= matcher.group(4) ?: ""
		this.combinator	= Combinator.fromCombinator(matcher.group(5) ?: "")
	}
	
	override Str toStr() {
		sId := id.isEmpty ? "" : "#${id}"
		sClasses := classes.isEmpty ? "" : "." + classes.join(".") 
		return "${type}${sId}${sClasses}"
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
