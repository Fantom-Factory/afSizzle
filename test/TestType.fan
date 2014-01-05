
internal class TestType : SizzleTest {
	
	Void testType() {
		doc := SizzleDoc("<html><h1>names</h1><p><span>tom</span><span>dick</span><span>harry</span></p></html>")
		
		elems := doc.select("h1")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select("span")
		verifyEq(elems.size, 3)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")
		verifyElem(elems[2], "span", "harry")
	}
}
