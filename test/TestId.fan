
internal class TestId : SizzleTest {
	
	Void testId() {
		doc := SizzleDoc("""<html><h1 id="head1">names</h1><p><span id="name">tom</span><span id="name">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("#head1")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("#name")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select("#dude")
		verifyEq(elems.size, 0)
	}
}
