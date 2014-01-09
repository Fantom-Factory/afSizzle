
internal class TestFirstChild : SizzleTest {
	
	Void testFirstChild() {
		doc := SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div/></span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select("html h1:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(":first-child")
		Env.cur.err.printLine(elems)
		verifyEq(elems.size, 3)
		verifyElem(elems[0], "div", null)
		verifyElem(elems[1], "h1", "names")
		verifyElem(elems[2], "span", "tom")

		elems = doc.select("p .tom:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("html span:first-child")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("span:first-child div")	// test single node match
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "div", null)

		elems = doc.select("html .dick:first-child")
		verifyEq(elems.size, 0)
		
		// case insensitivity test
		elems = doc.select("html span:first-CHILD")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")
	}
	
}
