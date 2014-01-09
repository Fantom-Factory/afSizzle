
internal class TestParseErr : SizzleTest {
	
	Void testParseErrChecked() {
		verifyErrTypeMsg(ParseErr#, ErrMsgs.selectorNotValid("dude[]")) {
			SizzleDoc("<xml/>").select("dude[]")
		}
	}

	Void testParseErrSafe() {
		elems := SizzleDoc("<xml/>").select("dude[]", false)
		verify(elems.isEmpty)
	}
}
