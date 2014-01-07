
internal class TestClass : SizzleTest {
	
	Void testClassSingle() {
		doc := SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select(".head1")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "h1", "names")

		elems = doc.select(".tom")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select(".name")
		verifyEq(elems.size, 2)
		verifyElem(elems[0], "span", "tom")
		verifyElem(elems[1], "span", "dick")

		elems = doc.select(".dude")
		verifyEq(elems.size, 0)
	}

	Void testClassMultiple() {
		doc := SizzleDoc("""<html><h1 class="head1">names</h1><p><span class="name tom">tom</span><span class="name dick">dick</span><span>harry</span></p></html>""")
		
		elems := doc.select(".name.tom")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")

		elems = doc.select(".tom.name")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "span", "tom")
	}
}
