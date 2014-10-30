using build

class Build : BuildPod {

	new make() {
		podName = "afSizzle"
		summary = "A library for querying XML documents by means of CSS 2.1 selectors"
		version = Version("1.0.2")

		meta = [	
			"proj.name"		: "Sizzle",
			"repo.private"	: "false",			
			"tags"			: "css, web"
		]

		depends = [	
			"sys 1.0", 
			"xml 1.0"
		]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]
	}	
}
