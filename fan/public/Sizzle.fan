using xml

** The main service class for selecting XML elements by means of CSS Selectors.
const class Sizzle {
	
	XElem[] selectFromStr(Str xml, Str cssSelector) {
		SizzleDoc(xml).select(cssSelector)
	}

	XElem[] selectFromDoc(XDoc doc, Str cssSelector) {
		SizzleDoc(doc).select(cssSelector)
	}

	XElem[] selectFromElem(XElem elem, Str cssSelector) {
		SizzleDoc(elem).select(cssSelector)
	}
	
}
