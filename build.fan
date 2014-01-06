using build

class Build : BuildPod {

	new make() {
		podName = "afSizzle"
		summary = "A library for querying XML documents by means of CSS selectors"
		version = Version("0.0.2")

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"proj.name"		: "Sizzle",
					"proj.uri"		: "http://www.fantomfactory.org/pods/afSizzle",
					"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afsizzle",
					"license.name"	: "BSD 2-Clause License",	
					"repo.private"	: "true"
				]

		depends = [	"sys 1.0", 
					"xml 1.0"
				]
		
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
		
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
	}
}
