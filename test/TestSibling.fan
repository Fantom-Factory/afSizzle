
internal class TestSibling : SizzleTest {
	
	Void testSibling() {
		doc := SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")

		elems := doc.select(".dick + span")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "harry")

		elems = doc.select("html p > span + .dick")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("html p > span + .tom")
		verifyEq(elems.size, 0)

		// case insensitivity test
		doc = SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><Span class="name Dick">dick</Span><span>harry</span></p></html>""")
		elems = doc.select(".DICK + SPAN")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "harry")
	}
}
