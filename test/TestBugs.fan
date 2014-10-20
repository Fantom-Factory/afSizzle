
internal class TestBugs : SizzleTest {
	
	// found in BushmastersWeb
	Void testCaseInsensitiveId() {
		doc := SizzleDoc("""<tr id="cmsPage-belize"><td>Belize</td><td><a href="/admin/cms/edit/belize" class="edit">edit</a></td><td><a href="/belize" class="view">view</a></td></tr>""")
		elems := doc.select("#cmsPage-belize a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")
		elems = doc.select("#cmspage-belize a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")

		doc = SizzleDoc("""<tr class="cmsPage-belize"><td>Belize</td><td><a href="/admin/cms/edit/belize" class="edit">edit</a></td><td><a href="/belize" class="view">view</a></td></tr>""")
		elems = doc.select(".cmsPage-belize a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")
		elems = doc.select(".cmspage-belize a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")

		doc = SizzleDoc("""<tr klaSS="cmsPage-belize"><td>Belize</td><td><a href="/admin/cms/edit/belize" class="edit">edit</a></td><td><a href="/belize" class="view">view</a></td></tr>""")
		elems = doc.select("[klaSS=cmsPage-belize] a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")
		elems = doc.select("[klass=cmspage-belize] a.edit")
		verifyEq(elems.size, 1)
		verifyElem(elems[0], "a", "edit")
	}
}

