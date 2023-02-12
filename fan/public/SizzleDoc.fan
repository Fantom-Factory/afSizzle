using xml

** Holds a representation of an XML document that may be queried with CSS selectors. 
** 
** 'SizzleDoc' is intended for re-use with multiple CSS selections:
**
**    syntax: fantom
** 
**    sizzDoc := SizzleDoc("<html><p class='welcome'>Hello from Sizzle!</p></html>")
**    elems1  := sizzDoc.select("p.welcome")
**    elems2  := sizzDoc.select("html p")
** 
class SizzleDoc {	
	private static const Regex	selectorRegex	:= theMainSelector
	
	private Str:NodeBucketMulti	buckets	:= Str:NodeBucketMulti[:] { caseInsensitive = true }
	private XElem				root
	private NodeBucketMulti		rootBucket
	
	private new make(XElem elem) {
		this.root = elem
		this.rootBucket = NodeBucketMulti(elem, true)
	}

	private static Regex theMainSelector() {
		Str nonWord1		:= Str<| [^,#<+:\s\[\]\(\)\\\.]	|>.trim
		Str nonWord2		:= Str<| [^,#<+:\s\[\]\(\)\\]	|>.trim

		Str	typeSelector	:= Str<| (\w+)? 				|>.trim.replace("\\w", nonWord1)
		Str	idSelector		:= Str<| (?:#(\w+))?			|>.trim.replace("\\w", nonWord1)
		Str	classesSelector	:= Str<| (\.[\w\.]+)?			|>.trim.replace("\\w", nonWord2)
		Str	attrSelector	:= Str<| ((?:\[[^\]]+\])+)?(?:\s*([>+]))?		|>.trim
		// Note :first-child & :last-child do NOT have a parameter
		Str	pseudoSelector	:= Str<| (?::(first-child|lang|last-child|nth-child|nth-last-child)(?:\((\w+)\))?)?	|>.trim

		return Regex.fromStr("\\s+${typeSelector}${idSelector}${classesSelector}${attrSelector}${pseudoSelector}")
	}

	** Create a 'SizzleDoc' from an XML string.
	static new fromStr(Str xml) {
		fromXDoc(XParser(xml
			// see http://fantom.org/sidewalk/topic/2233
			//.replace("&nbsp;", "&#160;")
		.in).parseDoc)
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
	XElem rootElement {
		get { root }
		set { }
	}
	
	** Queries the xml document with the given CSS selector any returns any matching elements.
	** 
	** Throws 'ParseErr' if the CSS selector is invalid and 'checked' is 'true'.
	XElem[] select(Str cssSelector, Bool checked := true) {
		// CASE-INSENSITIVITY
		cssSelectorStr := " " + cssSelector.lower
		if (checked)
			selectorRegex.split(cssSelectorStr, 1000).each |leftovers| {
				if (!leftovers.isEmpty)
					throw ParseErr(ErrMsgs.selectorNotValid(cssSelector))			
			}

		matcher := selectorRegex.matcher(cssSelectorStr)
		
		selectors := Selector[,]
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}

		if (selectors.isEmpty)
			return !checked ? XElem#.emptyList : throw ParseErr(ErrMsgs.selectorNotValid(cssSelector))
		
		possibles := rootBucket.select(selectors.last)
		
		if (selectors.size == 1)
			return possibles

		survivors := possibles.findAll |XNode? elem -> Bool| {
			selectors[0..<-1].reverse.all |sel -> Bool| {
				elem = findMatch(elem, sel)
				return elem != null
			}
		}
		
		return survivors
	}

	** Queries the document for elements under the given parent, returning any matches.
	** 
	** Throws 'ParseErr' if the CSS selector is invalid and 'checked' is 'true'.
	XElem[] selectFrom(XElem parent, Str cssSelector, Bool checked := true) {
		survivors := select(cssSelector, checked)
		
		// make sure our base node is in the hierarchy
		survivors = survivors.findAll |XElem? elem->Bool| {
			survivor := false
			while (survivor == false && elem != null) {
				survivor = elem.parent == parent
				elem = elem.parent as XElem
			}
			return survivor
		}
		
		return survivors
	}
	
	** An alias for 'select()'
	@Operator
	XElem[] get(Str cssSelector, Bool checked := true) {
		select(cssSelector, checked)
	}
	
	Void add(XElem elem) {
		rootBucket.add(elem)
	}

	Void update(XElem elem) {
		rootBucket.update(elem)
	}	

	Void remove(XElem elem) {
		rootBucket.remove(elem)
	}
	
	private XElem? findMatch(XNode? elem, Selector selector) {
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


