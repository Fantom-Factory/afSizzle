using xml

internal class TestUpdates : SizzleTest {
	
	Void testManualUpdates() {
		doc := SizzleXml("<html><h1>names</h1><p><span>tom</span><span>dick</span><span>harry</span></p></html>")
		
		dick := doc.select("span")[1]
		verifyElem(SElem(dick), "span", "dick")
		
		// test class updates
		dick.addAttr("class", "foo")
		doc.update(dick)
		verifySame(dick, doc.select(".foo").first)
		verifyNull(		 doc.select(".bar").first)
		
		dick.removeAttr(dick.attr("class"))
		dick.addAttr("class", "foo bar")
		doc.update(dick)
		verifySame(dick, doc.select(".foo").first)
		verifySame(dick, doc.select(".bar").first)
		
		dick.removeAttr(dick.attr("class"))
		dick.addAttr("class", "bar")
		doc.update(dick)
		verifyNull(		 doc.select(".foo").first)
		verifySame(dick, doc.select(".bar").first)


		// test attr updates
		dick.addAttr("data-foo", "bar")
		doc.update(dick)
		verifySame(dick, doc.select("[data-foo=bar]").first)
		verifyNull(		 doc.select("[data-wot=ever]").first)
		
		dick.addAttr("data-wot", "ever")
		doc.update(dick)
		verifySame(dick, doc.select("[data-foo=bar]").first)
		verifySame(dick, doc.select("[data-wot=ever]").first)
		
		dick.removeAttr(dick.attr("data-foo"))
		doc.update(dick)
		verifyNull(		 doc.select("[data-foo=bar]").first)
		verifySame(dick, doc.select("[data-wot=ever]").first)
		
	
		dad := dick.parent as XElem
		dad.remove(dick)
		doc.remove(dick)
		verifyNull(		 doc.select("[data-wot=ever]").first)
		
		dad.add(dick)
		doc.add(dick)
		verifySame(dick, doc.select("[data-wot=ever]").first)
	}
}
