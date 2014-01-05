using xml

const class Sizzle {
	
	XElem[] select(Str xml, Str selector) {
		SizzleDoc(xml).select(selector)
	}
	
}
