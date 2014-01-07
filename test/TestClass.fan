
internal class TestAttributes : SizzleTest {
	
	Void testAttrAny() {
		doc := SizzleDoc("""<html><h1 head="wotever">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("[head]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[class]")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("[dude]")
		verifyEq(elems.size, 0)
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

		elems = doc.select("[class~=dick]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("[class~=name]")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("[class~=name tom]")
		verifyEq(elems.size, 0)

		elems = doc.select("[class~=]")
		verifyEq(elems.size, 0)
	}

	Void testAttrLang() {
		doc := SizzleDoc("""<html><h1 head="fr">names</h1><p><span lang="en-gb">tom</span><span lang="en-cockney">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("[head|=fr]")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("[lang|='fr']")
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
	}
}
