using xml

internal class TestPathTo : SizzleTest {
	
	Void testUniversal() {
		doc := XParser("<html><h1>names</h1><p><span>tom</span><span>dick</span><span>harry</span></p></html>".in).parseDoc
		
		h1	:= doc.root.elem("h1")
		p	:= doc.root.elem("p")

		verifyEq(SizzleDoc.pathTo(doc.root), 	"/html")
		verifyEq(SizzleDoc.pathTo(h1), 			"/html/h1")
		verifyEq(SizzleDoc.pathTo(p), 			"/html/p")
		verifyEq(SizzleDoc.pathTo(p.elems[0]),	"/html/p/span[0]")
		verifyEq(SizzleDoc.pathTo(p.elems[1]),	"/html/p/span[1]")
		verifyEq(SizzleDoc.pathTo(p.elems[2]),	"/html/p/span[2]")
	}
}
