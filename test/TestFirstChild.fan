
internal class TestFirstChild : SizzleTest {
	
	Void testFirstChild() {
		doc := SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span><span>harry</span></p></html>""")
		
		elems := doc.select("html h1:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(":first-child")
		verifyEq(elems.size, 4)
		verifyElem(elems[0], "h1", "names")
		verifyElem(elems[1], "span", "tom")
		verifyElem(elems[2], "div", "1-tom")
		verifyElem(elems[3], "div", "1-dick")

		elems = doc.select("p .tom:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("html span:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("span:first-child div")	// test single node match
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "div", "1-tom")

		elems = doc.select("html .dick:first-child")
		verifyEq(elems.size, 0)
		
		// case insensitivity test
		elems = doc.select("html span:first-CHILD")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")
	}
	
}
