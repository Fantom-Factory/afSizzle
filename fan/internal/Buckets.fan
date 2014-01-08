using xml

internal class DomBucket {
	
	ElemBucket 		typeBucket	:= ElemBucket() 
	ElemBucket 		classBucket	:= ElemBucket() 
	Str:ElemBucket 	attrBuckets	:= Str:ElemBucket[:] // { caseInsensitive = true } - done through .lower
	
	new make(XElem elem, Bool recurse) {
		walk(elem, recurse)
	}
	
	private Void walk(XElem elem, Bool recurse) {
		typeBucket[elem.name] = elem

		elem.attr("class", false)?.val?.split?.each {
			classBucket[it] = elem
		}

		elem.attrs.each {
			// CASE-INSENSITIVITY
			bucket := attrBuckets.getOrAdd(it.name.lower) { ElemBucket() }
			bucket[it.val.trim] = elem
		}
		
		if (recurse)
			elem.elems.each { walk(it, recurse) }
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
			gotten = gotten.intersection(css)
		}

		selector.attrSelectors.each {
			attrs := it.match(attrBuckets)
			gotten = gotten.intersection(attrs)
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
		// CASE-INSENSITIVITY
		elems.getOrAdd(name.lower) { XElem[,] }.add(elem)
	}
	
	once XElem[] all() {
		elems.vals.flatten.unique
	}
}