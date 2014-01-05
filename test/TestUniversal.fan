
internal class TestUniversal : SizzleTest {
	
	Void testUniversal() {
		doc 	:= SizzleDoc("<html><h1>names</h1><p><span>tom</span><span>dick</span><span>harry</span></p></html>")
		
		elems 	:= doc.select("*")
		verifyEq(elems.size, 6)
	}
}
