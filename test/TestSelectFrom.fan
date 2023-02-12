
internal class TestSelectFrom : SizzleTest {
	
	Void testManualUpdates() {
		doc := SizzleDoc(
			"<html>
			 <div class='a1'><p>Tom</p></div>
			 <div class='a2'><p>Dick</p></div>
			 <div class='a3'><p>Harry</p></div>
			 </html>")
		
		tom		:= doc.select(".a1").first
		dick	:= doc.select(".a2").first
		harry	:= doc.select(".a3").first

		verifyElem(doc.selectFrom(tom,   "p").first, "p", "Tom")
		verifyElem(doc.selectFrom(dick,  "p").first, "p", "Dick")
		verifyElem(doc.selectFrom(harry, "p").first, "p", "Harry")
	}
}
