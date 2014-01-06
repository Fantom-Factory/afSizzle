
internal class TestChild : SizzleTest {
	
	Void testChildSingle() {
		doc := SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("html > h1")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("p > .tom")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("html > p > .dick")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("h1 > .dick")
		verifyEq(elems.size, 0)

		elems = doc.select("html > .dick")
		verifyEq(elems.size, 0)
	}

	Void testChildMultiple() {
		doc := SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")

		elems := doc.select("p > span")
		verifyEq(elems.size, 3)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")
		verifyElem(elems[2], "span", "harry")

		elems = doc.select("p > .name")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("h1 > .name")
		verifyEq(elems.size, 0)
	}
}
