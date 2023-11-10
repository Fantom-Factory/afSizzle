//using xml
//
//internal class TestUpdates : SizzleTest {
//	
//	Void testManualUpdates() {
//		doc := SizzleDoc("<html><h1>names</h1><p><span>tom</span><span>dick</span><span>harry</span></p></html>")
//		
//		dick := doc.select("span")[1]
//		verifyElem(dick, "span", "dick")
//		
//		// test class updates
//		dick.toNative->addAttr("class", "foo")
//		doc.update(dick)
//		verifySame(dick, doc.select(".foo").first)
//		verifyNull(		 doc.select(".bar").first)
//		
//		dick.toNative->removeAttr(dick.attr("class"))
//		dick.toNative->addAttr("class", "foo bar")
//		doc.update(dick)
//		verifySame(dick, doc.select(".foo").first)
//		verifySame(dick, doc.select(".bar").first)
//		
//		dick.toNative->removeAttr(dick.attr("class"))
//		dick.toNative->addAttr("class", "bar")
//		doc.update(dick)
//		verifyNull(		 doc.select(".foo").first)
//		verifySame(dick, doc.select(".bar").first)
//
//
//		// test attr updates
//		dick.toNative->addAttr("data-foo", "bar")
//		doc.update(dick)
//		verifySame(dick, doc.select("[data-foo=bar]").first)
//		verifyNull(		 doc.select("[data-wot=ever]").first)
//		
//		dick.toNative->addAttr("data-wot", "ever")
//		doc.update(dick)
//		verifySame(dick, doc.select("[data-foo=bar]").first)
//		verifySame(dick, doc.select("[data-wot=ever]").first)
//		
//		dick.toNative->removeAttr(dick.attr("data-foo"))
//		doc.update(dick)
//		verifyNull(		 doc.select("[data-foo=bar]").first)
//		verifySame(dick, doc.select("[data-wot=ever]").first)
//		
//	
//		dad := dick.parent as XElem
//		dad.remove(dick.toNative)
//		doc.remove(dick.toNative)
//		verifyNull(		 doc.select("[data-wot=ever]").first)
//		
//		dad.add(dick)
//		doc.add(dick)
//		verifySame(dick, doc.select("[data-wot=ever]").first)
//	}
//}
