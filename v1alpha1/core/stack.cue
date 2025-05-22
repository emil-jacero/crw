// A bundle is a collection of components. Define a bundle when multiple components are required to work together.
// For example, a bundle can be used to define a database and its associated storage.

package core

// A bundle is a collection of components. Define a bundle when multiple components are required to work together.
#Stack: {
	#CommonObject
	#kind: "Stack"
	#metadata: name: string

	let _Name = #metadata.name
	let _Namespace = #metadata.namespace

	// The components that are part of the bundle.
	components: [Id=string]: #Component & {
		if _Namespace != _|_ {
			#metadata: name: "\(_Namespace)-\(_Name)-\(Id)"
		}
		if _Namespace == _|_ {
			#metadata: name: "\(_Name)-\(Id)"
		}
	}
}

#StackList: {
	#CommonObject
	#kind: "StackList"
	stacks: [...#Stack]
}
