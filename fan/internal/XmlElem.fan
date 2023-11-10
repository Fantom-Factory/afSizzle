using xml::XElem

internal class XmlElem : Elem {
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
			elem.attrs.each |attr| {
				attrs[attr.name] = attr.val
			}
		}
		return attrs_
	}
	
	override Str text() {
		elem.text?.val ?: ""
	}
	
	override Elem? parent() {
		if (parent_ == null)
			parent_ = (elem.parent as XElem) == null ? null : XmlElem(elem.parent)
		return parent_
	}
	
	override Elem[] children() {
		if (children_ == null)
			children_ = elem.elems.map { XmlElem(it) }
		return children_
	}
	
	override Obj? toNative()		{ elem }
	override Str  toStr()			{ elem.toStr }
	override Int  hash()			{ elem.hash }
	override Bool equals(Obj? that)	{ this.elem == (that as XmlElem)?.elem }  
}
