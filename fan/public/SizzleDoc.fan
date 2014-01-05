using xml

class SizzleDoc {
	
	private Str:DomBuckets buckets	:= [:]
	private XElem	root
	private Str		rootPath
	
	
	private new make(XElem elem) {
		this.root = elem
		this.rootPath = pathTo(elem)
		this.buckets[rootPath] = DomBuckets(elem)
	}
	
	static new fromStr(Str xml) {
		fromXDoc(XParser(xml.in).parseDoc)
	}

	static new fromXDoc(XDoc doc) {
		fromXElem(doc.root)
	}

	static new fromXElem(XElem elem) {
		SizzleDoc.make(elem)
	}
	
	
	
	@Operator
	XElem[] get(Str selector) {
				
		s := Str<| \s+(\w1+)?(#\w1+)?(\.[\w2\.]+)?((?:\[[^\]]+\])+)? |>.trim.replace("\\w1", Str<| [^#\.\s\[\]] |>.trim).replace("\\w2", Str<| [^#\s\[\]] |>.trim)
		regex	:= Regex.fromStr(s)
		
		matcher := regex.matcher(" " + selector)
		
		selectors := Selector[,]
		
		while (matcher.find) {
			selectors.add(Selector(matcher))
		}		

		// TODO: better err msg
		if (selectors.isEmpty)
			throw Err("Shitty css selector: $selector")
		
		Env.cur.err.printLine(selectors.first)
		
		return buckets[rootPath].select(selectors.first)
	}
	
	** An alias for 'get()'
	XElem[] select(Str selector) {
		get(selector)
	}
	
	internal static Str pathTo(XElem elem, StrBuf path := StrBuf()) {
		name := "/${elem.name}"
		if (elem.parent != null && elem.parent is XElem) {
			sibs := ((XElem) elem.parent).elems.findAll { it.name == elem.name }
			if (sibs.size > 1)
				name += "[" + sibs.indexSame(elem).toStr + "]"
			pathTo(elem.parent, path)
		}
		path.add(name)
		return path.toStr
	}
}


internal class DomBuckets {
	
	ElemBucket 		typeBucket	:= ElemBucket() 
	ElemBucket 		classBucket	:= ElemBucket() 
	Str:ElemBucket 	attrBuckets	:= Str:ElemBucket[:] { caseInsensitive = true }
	
	new make(XElem elem) {
		walk(elem)
	}
	
	private Void walk(XElem elem) {
		typeBucket[elem.name] = elem
		
		elem.attr("class", false)?.val?.split?.each {
			classBucket[it] = elem
		}

		elem.attrs.each {
			bucket := attrBuckets.getOrAdd(it.name) { ElemBucket() }
			bucket[it.val.trim] = elem
		}
		
		elem.elems.each { walk(it) }
	}
	
	XElem[] select(Selector selector) {
		types 	:= (selector.type == "*") ? typeBucket.all : typeBucket[selector.type]
		gotten	:= types
		
		if (!selector.id.isEmpty) {
			ids 	:= attrBuckets["id"]?.get(selector.id)
			gotten	= gotten.intersection(ids)
		}

		selector.classes.each {
			css	:= classBucket[it]
			gotten	= gotten.intersection(css)
		}
		
		return gotten
	}
}

internal class ElemBucket {
	Str:XElem[]	elems	:= [:]

	@Operator
	XElem[] get(Str? name) {
		elems[name ?: Str.defVal] ?: XElem#.emptyList
	}

	@Operator
	Void set(Str name, XElem elem) {
		elems.getOrAdd(name) { XElem[,] }.add(elem)
	}
	
	once XElem[] all() {
		elems.vals.flatten.unique
	}
}

internal const class Selector {
	
	const Str 	type
	const Str 	id
	const Str[]	classes
	const Str 	attrs
	
	new make(RegexMatcher matcher) {
		this.type 		= matcher.group(1) ?: "*"
		this.id 		= matcher.group(2)?.getRange(1..-1) ?: ""
		this.classes	= matcher.group(3)?.split('.')?.exclude { it.isEmpty } ?: Str#.emptyList
		this.attrs 		= matcher.group(4) ?: ""
	}
	
	override Str toStr() {
		sId := id.isEmpty ? "" : "#${id}"
		sClasses := classes.isEmpty ? "" : "." + classes.join(".") 
		return "${type}${sId}${sClasses}"
	}
}
