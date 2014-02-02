
internal const class ErrMsgs {

	static Str selectorNotValid(Str selector) {
		"CSS selector is not valid: ${selector}"
	}

	// TODO: just don't accept these
	static Str pseudoClassDoesNotTakeArgument(Str pClass, Str arg) {
		"${pClass} selectors do NOT have arguments: ${pClass}(${arg})"
	}

	// TODO: just don't accept these
	static Str pseudoClassMustHaveArgument(Str pClass) {
		"${pClass} selectors must have an argument: e.g. ${pClass}(xxx)"
	}
	
	// TODO: make it a proper CSS3 selector
	// http://www.w3.org/TR/css3-selectors/#nth-child-pseudo
	static Str pseudoClassArgMustBeNumeric(Str pClass, Str arg) {
		"For now, ${pClass} selectors only take simple numeric arguments: ${pClass}(${arg})"		
	}
	
}
