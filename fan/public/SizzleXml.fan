using xml::XElem
using xml::XDoc
using xml::XParser

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
class SizzleXml {	

	private SizzleDoc	doc

	** Returns the root element of the XML document.
	XElem root {
		get { doc.root.toNative }	
		private set { }
	}
	
	private new make(SElem elem) {
		this.doc = SizzleDoc(elem)
	}

	** Create a 'SizzleXml' from an XML string.
	static new fromXml(Str xml) {
		fromXDoc(XParser(xml
			// see http://fantom.org/sidewalk/topic/2233
			//.replace("&nbsp;", "&#160;")
		.in).parseDoc)
	}

	** Create a 'SizzleXml' from an XML document.
	static new fromXDoc(XDoc doc) {
		fromXElem(doc.root)
	}

	** Create a 'SizzleXml' from an XML element.
	static new fromXElem(XElem elem) {
		SizzleXml.make(SElem(elem))
	}

	** Queries the document with the given CSS selector any returns any matching elements.
	** 
	** Throws 'ParseErr' if the CSS selector is invalid and 'checked' is 'true'.
	XElem[] select(Str cssSelector, Bool checked := true) {
		doc.select(cssSelector, checked).map { it.toNative }
	}
	
	** Queries the document for elements under the given parent, returning any matches.
	** 
	** Throws 'ParseErr' if the CSS selector is invalid and 'checked' is 'true'.
	XElem[] selectFrom(XElem parent, Str cssSelector, Bool checked := true) {
		doc.selectFrom(SElem(parent), cssSelector, checked).map { it.toNative }
	}
	
	** An alias for 'select()'
	@Operator
	XElem[] get(Str cssSelector, Bool checked := true) {
		doc.get(cssSelector, checked).map { it.toNative }
	}
	
	** Adds another root element.
	Void add(XElem elem) {
		doc.add(SElem(elem))
	}

	** Updates / refreshes the given Elem - must have already been added. 
	Void update(XElem elem, Bool recurse := false) {
		doc.update(SElem(elem), recurse)
	}	

	** Removed the the given Elem.
	Void remove(XElem elem) {
		doc.remove(SElem(elem))
	}
}



internal class XmlElem : SElem {
	private XElem		elem
	private XmlElem?	parent_
	private [Str:Str]?	attrs_
	private XmlElem[]?	children_

	new make(XElem elem) {
		this.elem = elem
	}
	
	override Str name() {
		elem.name
	}
	
	override Str? attr(Str attrName) {
		elem.attr(attrName, false)?.val
	}
	
	override Str:Str attrs() {
		if (attrs_ == null) {
			attrs_ = Str:Str[:]
			attrs_.ordered = true
			elem.attrs.each |attr| {
				attrs[attr.name] = attr.val
			}
		}
		return attrs_
	}
	
	override Str text() {
		elem.text?.val ?: ""
	}
	
	override SElem? parent() {
		if (parent_ == null)
			parent_ = (elem.parent as XElem) == null ? null : XmlElem(elem.parent)
		return parent_
	}
	
	override SElem[] children() {
		if (children_ == null)
			children_ = elem.elems.map { XmlElem(it) }
		return children_
	}
	
	override Obj? toNative()		{ elem }
	override Str  toStr()			{ elem.toStr }
	override Int  hash()			{ elem.hash }
	override Bool equals(Obj? that)	{ this.elem == (that as XmlElem)?.elem }  
}
