
class TestQuickStart :Test {
	
	Void testQuickStart() {		
		xhtml := "<html><p class='welcome'>Hello from Sizzle!</p></html>"
		elems := SizzleDoc(xhtml).select("p.welcome")
		echo(elems.first.text)  // --> Hello from Sizzle!
	}
}
