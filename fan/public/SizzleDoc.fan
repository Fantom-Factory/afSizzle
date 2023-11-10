using xml::XElem
using xml::XDoc
using xml::XParser

** Holds a document that may be queried with CSS selectors. 
class SizzleDoc {	
	private static const Regex	selectorRegex	:= theMainSelector
	
	private NodeBucketMulti		rootBucket

	** Returns the root element of the XML document.
	Elem root { private set }
	
	** Create a 'SizzleDoc' from the given root Elem.
	new make(Elem root) {
		this.root = root
		this.rootBucket = NodeBucketMulti(root, true)
	}
	
	** Create a 'SizzleDoc' from the given XML string.
	static new fromXml(Str xml) {
		SizzleXml(xml)->doc
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

	** Queries the document with the given CSS selector any returns any matching elements.
	** 
	** Throws 'ParseErr' if the CSS selector is invalid and 'checked' is 'true'.
	Elem[] select(Str cssSelector, Bool checked := true) {
		// this is just a quick hack for now - but it gets me out of a hole
		// if I need to support a complicated selector with a "," then I probably reconsider the selector!
		cssSelector.split(',').flatMap { doSelect(it, checked) }
	}

	private Elem[] doSelect(Str cssSelector, Bool checked := true) {
		// CASE-INSENSITIVITY
		cssSelectorStr := " " + cssSelector.lower
		if (checked)
			selectorRegex.split(cssSelectorStr, 1000).each |leftovers| {
				if (!leftovers.isEmpty)
					throw ParseErr("CSS selector is not valid: ${cssSelector}")
			}

		matcher := selectorRegex.matcher(cssSelectorStr)
		
		selectors := Selector[,]
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}

		if (selectors.isEmpty)
			return !checked ? Elem#.emptyList : throw ParseErr("CSS selector is not valid: ${cssSelector}")
		
		possibles := rootBucket.select(selectors.last)
		
		if (selectors.size == 1)
			return possibles

		survivors := possibles.findAll |Elem? elem -> Bool| {
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
	Elem[] selectFrom(Elem parent, Str cssSelector, Bool checked := true) {
		survivors := select(cssSelector, checked)
		
		// make sure our base node is in the hierarchy
		survivors = survivors.findAll |Elem? elem->Bool| {
			survivor := false
			while (survivor == false && elem != null) {
				survivor = elem.parent == parent
				elem = elem.parent
			}
			return survivor
		}
		
		return survivors
	}
	
	** An alias for 'select()'
	@Operator
	Elem[] get(Str cssSelector, Bool checked := true) {
		select(cssSelector, checked)
	}
	
	** Adds another root element.
	Void add(Elem elem) {
		rootBucket.add(elem)
	}

	** Updates / refreshes the given Elem - must have already been added. 
	Void update(Elem elem, Bool recurse := false) {
		rootBucket.update(elem, recurse)
	}	

	** Removed the the given Elem.
	Void remove(Elem elem) {
		rootBucket.remove(elem, true)
	}

	private Elem? findMatch(Elem? elem, Selector selector) {
		if (selector.combinator == Combinator.descendant) {
			elem = elem?.parent
			while (elem != null && matches(elem, selector) == null) {
				elem = elem?.parent
			}
			return elem
		}
		
		if (selector.combinator == Combinator.child) {
			elem = elem?.parent
			return matches(elem, selector)
		}

		if (selector.combinator == Combinator.sibling) {
			parent := elem?.parent
			if (parent == null)
				return null
			index := parent.children.index(elem)
			if (index < 1)
				return null
			elem = parent.children.getSafe(index - 1)
			return matches(elem, selector)
		}
		
		return null
	}
	
	private Elem? matches(Elem? elem, Selector selector) {
		if (elem == null)
			return null
		return NodeBucketSingle(elem).select(selector)
	}
}
