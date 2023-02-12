using xml

internal class NodeBucketMulti {
	
	ElemBucket 		typeBucket	:= ElemBucket() 
	ElemBucket 		classBucket	:= ElemBucket() 
	Str:ElemBucket 	attrBuckets	:= Str:ElemBucket[:] // { caseInsensitive = true } - done through .lower
	
	new make(XElem elem, Bool recurse) {
		walk(elem, recurse)
	}
	
	Void add(XElem elem) {
		walk(elem, false)
	}	

	Void update(XElem elem) {
		// remove all trace of Elem
		remove(elem)

		// ...and add it again!
		add(elem)
	}	

	Void remove(XElem elem) {
		// type should NOT have changed - but meh, who knows!
		typeBucket.remove(elem)
		classBucket.remove(elem)
		attrBuckets.each |bucket| {
			bucket.remove(elem)
		}
		// let's not trim buckets - there'll be 100s of them!
		// and Docs in testing are pretty short lived, so why waste precious processing cycles!?
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
			// CASE-INSENSITIVITY - the "id"
			ids 	:= attrBuckets["id"]?.get(selector.id) ?: XElem#.emptyList
			gotten	= gotten.intersection(ids)
		}

		selector.classes.each {
			css	:= classBucket[it]
			gotten = gotten.intersection(css)
		}

		selector.attrSelectors.each {
			attrs := it.matchMultiNode(attrBuckets)
			gotten = gotten.intersection(attrs)
		}

		gotten = gotten.findAll { selector.pseudoSelector.matches(it) }
		
		return gotten
	}
}

internal class ElemBucket {
	Str:XElem[]	elems	:= [:]
	XElem[]		all		:= XElem[,]

	@Operator
	XElem[] get(Str? name) {
		elems[name ?: Str.defVal] ?: XElem#.emptyList
	}

	@Operator
	Void set(Str name, XElem elem) {
		// CASE-INSENSITIVITY
		elems.getOrAdd(name.lower) { XElem[,] }.add(elem)
		if (all.contains(elem) == false)
			all.add(elem)
	}

	Void remove(XElem elem) {
		elems.each { it.remove(elem) }
		all.remove(elem)
	}

	Bool isEmpty() { all.isEmpty }	
}

internal class NodeBucketSingle {
	
	XElem	theElement
	Str 	elemType
	Str[]	elemClasses
	Str:Str	elemAttrs	:= [Str:Str][:]	// { caseInsensitive = true } - done through .lower
	
	new make(XElem elem) {
		theElement	= elem
		// CASE-INSENSITIVITY
		elemType	= elem.name.lower
		// CASE-INSENSITIVITY
		elemClasses	= elem.attr("class", false)?.val?.lower?.split ?: Str#.emptyList 

		elem.attrs.each {
			// CASE-INSENSITIVITY
			elemAttrs[it.name.lower] = it.val.trim.lower
		}
	}

	XElem? select(Selector selector) {
		match := (selector.type == "*") || (selector.type == elemType)
		
		if (!selector.id.isEmpty) {
			// CASE-INSENSITIVITY - the "id"
			match = match && selector.id == elemAttrs["id"]
		}

		selector.classes.each {
			match = match && elemClasses.contains(it)
		}

		selector.attrSelectors.each {
			match = match && it.matchSingleNode(elemAttrs)
		}

		if (selector.pseudoSelector.active) {
			match = match && selector.pseudoSelector.matches(theElement)
		}
		
		return match ? theElement : null
	}
}
