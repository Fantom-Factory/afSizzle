using xml

internal class SizzleTest : Test {
	
	Void verifyElem(XElem elem, Str name, Str? value) {
		verifyEq(elem.name, name)
		verifyEq(elem.text?.val, value)
	}
	
}
