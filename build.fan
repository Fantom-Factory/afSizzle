using build

class Build : BuildPod {

	new make() {
		podName = "afSizzle"
		summary = "A library for querying XML documents by means of CSS 2.1 selectors"
		version = Version("1.0.4")

		meta = [	
			"pod.dis"		: "Sizzle",
			"repo.tags"		: "css, web",
			"repo.public"	: "true"
		]

		depends = [	
			"sys 1.0", 
			"xml 1.0"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/public/`, `test/`]
		resDirs = [`doc/`]
	}	
}
