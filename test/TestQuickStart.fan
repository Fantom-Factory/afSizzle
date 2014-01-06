
class TestQuickStart :Test {
	
	Void testQuickStart() {		
		xml   := """<html><body><p class="welcome">Hello from Sizzle!</p></body></html>"""
		elems := Sizzle().selectFromStr(xml, "p.welcome")
		echo(elems.first.text)  // -> Hello from Sizzle! 
	}
}
