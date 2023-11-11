
internal class NodeBucketMulti {
	
	private SElemBucket 		typeBucket	:= SElemBucket() 
	private SElemBucket 		classBucket	:= SElemBucket() 
	private Str:SElemBucket 	attrBuckets	:= Str:SElemBucket[:] // { caseInsensitive = true } - done through .lower
	
	new make(SElem elem, Bool recurse) {
		walk(elem, recurse)
	}
	
	Void add(SElem elem) {
		walk(elem, true)
	}	

	Void update(SElem elem, Bool recurse := false) {
		// remove all trace of SElem
		remove(elem, recurse)

		// ...and add it again!
		walk(elem, recurse)
	}	

	Void remove(SElem elem, Bool recurse) {
		if (recurse)
			elem.children.each { this.remove(it, recurse) }

		// type should NOT have changed - but meh, who knows!
		typeBucket.remove(elem)
		classBucket.remove(elem)
		attrBuckets.each |bucket| {
			bucket.remove(elem)
		}
		// let's not trim buckets - there'll be 100s of them!
		// and Docs in testing are pretty short lived, so why waste precious processing cycles!?
	}
	
	private Void walk(SElem elem, Bool recurse) {
		typeBucket[elem.name] = elem

		elem.attr("class")?.split?.each {
			classBucket[it] = elem
		}

		elem.attrs.each |val, key| {
			// CASE-INSENSITIVITY
			bucket := attrBuckets.getOrAdd(key.lower) { SElemBucket() }
			bucket[val.trim] = elem
		}
		
		if (recurse)
			elem.children.each { walk(it, recurse) }
	}

	SElem[] select(Selector selector) {
		types 	:= (selector.type == "*") ? typeBucket.all : typeBucket[selector.type]
		gotten	:= types
		
		if (!selector.id.isEmpty) {
			// CASE-INSENSITIVITY - the "id"
			ids 	:= attrBuckets["id"]?.get(selector.id) ?: SElem#.emptyList
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

internal class SElemBucket {
	Str:SElem[]	elems	:= Str:SElem[][:]
	SElem[]		all		:= SElem[,]

	@Operator
	SElem[] get(Str? name) {
		elems[name ?: Str.defVal] ?: SElem#.emptyList
	}

	** set() is really add()
	@Operator
	Void set(Str name, SElem elem) {
		// CASE-INSENSITIVITY
		name = name.lower
		elems := this.elems.get(name)
		if (elems == null) {
			elems = SElem[,]
			this.elems[name] = elems
		}
		if (elems.contains(elem) == false)
			elems.add(elem)

		if (all.contains(elem) == false)
			all.add(elem)
	}
	
	Void remove(SElem elem) {
		elems.each { it.remove(elem) }
		all.remove(elem)
	}

	Bool isEmpty() { all.isEmpty }
}

internal class NodeBucketSingle {
	
	SElem	theElement
	Str 	elemType
	Str[]	elemClasses
	Str:Str	elemAttrs	:= [Str:Str][:]	// { caseInsensitive = true } - done through .lower
	
	new make(SElem elem) {
		theElement	= elem
		// CASE-INSENSITIVITY
		elemType	= elem.name.lower
		// CASE-INSENSITIVITY
		elemClasses	= elem.attr("class")?.lower?.split ?: Str#.emptyList 

		elem.attrs.each |val, key| {
			// CASE-INSENSITIVITY
			elemAttrs[key.lower] = val.trim.lower
		}
	}

	SElem? select(Selector selector) {
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
