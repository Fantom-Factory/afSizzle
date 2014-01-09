
internal class TestLang : SizzleTest {
	
	Void testLang() {
		doc := SizzleDoc("""<html lang="en"><h1 lang="po-ish">names</h1><p><span lang="tom">tom</span><span xml:lang="fr">dick</span><span lang="french">harry</span></p></html>""")
		
		elems := doc.select("html h1:lang(po)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(":lang(en)")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "p", null)
		verifyElem(elems[1], "html", null)

		elems = doc.select(":lang(po)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(":lang(fr)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("html:lang(en) span:first-child")	// test single node match
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("html :lang(poo)")
		verifyEq(elems.size, 0)
		
		// case insensitivity test
		doc = SizzleDoc("""<html lang="en"><h1 Lang="po-ish">names</h1></html>""")
		elems = doc.select("h1:LANG(PO)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")
		
		// test no default language
		doc = SizzleDoc("""<html><h1>names</h1></html>""")
		elems = doc.select(":lang(en)")
		verifyEq(elems.size, 0)
	}
	
}
