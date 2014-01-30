
internal class TestNthLastChild : SizzleTest {
	
	Void testNthLastChild() {
		doc := SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span><span>harry</span></p></html>""")
		
		elems := doc.select("html > :nth-last-child(1)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "p", null)

		elems = doc.select("html > :nth-last-child(2)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")
		
		// TODO: should have more tests here really!
	}
	
}
