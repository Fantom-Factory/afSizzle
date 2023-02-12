
internal class TestNthChild : SizzleTest {
	
	Void testNthChild() {
		doc := SizzleDoc("""<html><h1>names</h1><p><span class="name tom">tom<div>1-tom</div></span><span class="name dick">dick<div>1-dick</div></span><span>harry</span></p></html>""")
		elems := doc.select("html > :nth-child(1)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(":nth-child(1)")
		verifyEq(elems.size, 4)
		verifyElem(elems[0], "h1", "names")
		verifyElem(elems[1], "span", "tom")
		verifyElem(elems[2], "div", "1-tom")
		verifyElem(elems[3], "div", "1-dick")

		elems = doc.select("span:nth-child(1)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select("span:nth-child(2)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "dick")

		elems = doc.select("span:nth-child(3)")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "harry")

		// test single node match
		elems = doc.select("span:nth-child(1) div")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "div", "1-tom")

		// test single node match
		elems = doc.select("span:nth-child(2) div")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "div", "1-dick")

		elems = doc.select("span:nth-child(3) div")
		verifyEq(elems.size, 0)
	}
	
}
