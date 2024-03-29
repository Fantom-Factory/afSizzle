using xml::XElem

** An abstraction around various Elem implementations.
mixin SElem {
	
	** Create a Elem from an XML XElem instance.
	static new fromXml(XElem elem) {
		XmlElem(elem)
	}
	
	** Returns the tag name.
	abstract Str name()
	
	** Returns 'null' if attr is not defined.
	abstract Str? attr(Str attrName)
	
	** Returns a map of attribute name / value pairs.
	abstract Str:Str attrs()
	
	** Returns the tag text.
	abstract Str text()

	** Returns the parent tag.
	abstract SElem? parent()
	
	** Returns child Elems.
	abstract SElem[] children()
	
	** Returns the underlying elem object.
	@NoDoc
	virtual Obj? toNative() { throw UnsupportedErr() }
}
