using xml

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
	
	private Str:NodeBucketMulti	buckets	:= Str:NodeBucketMulti[:] { caseInsensitive = true }
	private XElem				root
	private NodeBucketMulti		rootBucket
	
	private new make(XElem elem) {
		this.root = elem
		this.rootBucket = NodeBucketMulti(elem, true)
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

	** Returns the root element of the XML document
	XElem rootElement() {
		root
	}
	
	** Queries the xml document with the given CSS selector any returns any matching elements.
	XElem[] select(Str cssSelector) {
		// CASE-INSENSITIVITY
		matcher := selectorRegex.matcher(" " + cssSelector.lower)
		
		selectors := Selector[,]
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}

		if (selectors.isEmpty)
			throw SizzleErr(ErrMsgs.selectorNotValid(cssSelector))
		
		possibles := rootBucket.select(selectors.last)
		
		if (selectors.size == 1)
			return possibles

		survivors := possibles.findAll |XNode? elem -> Bool| {
			selectors[0..<-1].reverse.all |sel -> Bool| {
				elem = findElemMatch(elem, sel)
				return elem != null
			}
		}
		
		return survivors
	}
	
	** An alias for 'get()'
	@Operator
	XElem[] get(Str cssSelector) {
		select(cssSelector)
	}
	
	private XElem? findElemMatch(XNode? elem, Selector selector) {
		if (selector.combinator == Combinator.descendant) {
			elem = elem?.parent
			while (isElement(elem) && matches(elem, selector) == null) {
				elem = elem?.parent
			}
			return isElement(elem) ? elem : null
		}
		
		if (selector.combinator == Combinator.child) {
			elem = elem?.parent
			return matches(elem, selector)
		}

		if (selector.combinator == Combinator.sibling) {
			parent := elem?.parent
			if (!isElement(parent))
				return null
			index := (parent as XElem).elems.indexSame(elem)
			if (index < 1)
				return null
			elem = (parent as XElem).elems.getSafe(index - 1)
			return matches(elem, selector)
		}
		
		return null
	}
	
	private XElem? matches(XElem? elem, Selector selector) {
		if (elem == null)
			return null
		return NodeBucketSingle(elem).select(selector)
	}
	
	private static Bool isElement(XNode? node) {
		(node as XElem) != null
	}
}


