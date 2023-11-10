
internal class TestParseErr : SizzleTest {
	
	Void testParseErrChecked() {
		verifyErrTypeMsg(ParseErr#, "CSS selector is not valid: dude[]") {
			SizzleDoc("<xml/>").select("dude[]")
		}
	}

	Void testParseErrSafe() {
		elems := SizzleDoc("<xml/>").select("dude[]", false)
		verify(elems.isEmpty)
	}
}
