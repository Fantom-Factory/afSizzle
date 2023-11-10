
internal class TestLastChild : SizzleTest {
	
	Void testLastChild() {
		doc := SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span><span>harry</span></p></html>""")
		
		elems := doc.select("html p:last-child")
//		verifyEq(elems.size, 1)
		verifyElem(elems[0], "p", "")

		elems = doc.select(":last-child")
		verifyEq(elems.size, 4)
		verifyElem(elems[0], "p", "")
		verifyElem(elems[1], "div", "1-tom")
		verifyElem(elems[2], "div", "1-dick")
		verifyElem(elems[3], "span", "harry")

		elems = doc.select("p span:last-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "harry")

		doc = SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span></p></html>""")
		elems = doc.select("span:last-child div")	// test single node match
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "div", "1-dick")

		doc = SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span><span>harry</span></p></html>""")
		elems = doc.select("html .dick:last-child")
		verifyEq(elems.size, 0)
		
		// case insensitivity test
		elems = doc.select("html p:last-CHILD")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "p", "")
	}
	
}
