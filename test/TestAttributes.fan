
internal class TestAttributes : SizzleTest {
	
	Void testAttrAny() {
		doc := SizzleDoc("""<html><h1 head="wotever">names</h1><p><span class="name tom" body="">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("[head]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[class]")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("[class][body]")	// test double
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("[dude]")
		verifyEq(elems.size, 0)
		
		elems = doc.select("html [head]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")
	}

	Void testAttrExact() {
		doc := SizzleDoc("""<html><h1 head="wotever">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("[head=wotever]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head=\"wotever\"]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head='wotever']")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head=wot]")
		verifyEq(elems.size, 0)
		
		elems = doc.select("html [head=wotever]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")
	}

	Void testAttrWhitespace() {
		doc := SizzleDoc("""<html><h1 head="wotever">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("[head~=wotever]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head~=\"wotever\"]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head~='wotever']")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head~=wot]")
		verifyEq(elems.size, 0)

		elems = doc.select("[class~=tom]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("[class~=tom][class~=name]")	// test double!
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("[class~=tom][class~=dick]")	// test double!
		verifyEq(elems.size, 0)

		elems = doc.select("[class~=dick]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("[class~=name]")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("[class~=name tom]")		// spec test
		verifyEq(elems.size, 0)

		elems = doc.select("[class~=]")				// spec test
		verifyEq(elems.size, 0)
		
		elems = doc.select("html [head~=wotever]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")
	}

	Void testAttrLang() {
		doc := SizzleDoc("""<html><h1 head="fr">names</h1><p><span lang="en-gb">tom</span><span lang="en-cockney">dick</span><span lang="encore">harry</span></p></html>""")
		
		elems := doc.select("[head|=fr]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[head|='fr']")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[lang|=\"en\"]")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("[lang|=en-]")
		verifyEq(elems.size, 0)

		elems = doc.select("[lang|=wot]")
		verifyEq(elems.size, 0)
		
		elems = doc.select("html [head|=fr]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")		
	}
}

