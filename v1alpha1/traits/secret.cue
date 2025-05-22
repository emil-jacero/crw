package traits

import (
	core "jacero.io/crw/v1alpha1/core"
)

#SecretRef: core.#NamedObjectRef & {
	#kind: "Secret"
}

#SecretSpec: {
	core.#CommonObject
	#kind: "Secret"
	#metadata: name: string

	// Type of secret.
	type!: *"opaque" | "docker-registry"

	// Data must be base64 encoded.
	// The data field is a map of string keys to base64 encoded string values.
	data?: {
		[string]: string
	}
	// StringData is a map of string keys to unencoded string values.
	// The stringData field allows you to provide secret data in string form.
	stringData?: {
		[string]: string
	}
	// FileData is a map of string keys to file paths on the host.
	// The fileData field allows you to provide secret data in file form.
	fileData?: {
		[string]: string
	}
}

// Secrets are used to store sensitive information, such as passwords, OAuth tokens, and ssh keys.
// Inspired by Kubernetes Secrets but simplified.
#Secret: core.#Trait & {
	let _Name = #metadata.name
	let _Namespace = #metadata.namespace
	#metadata: traits: Secret:                       null
	#metadata: annotations: "secret.jacero.io/name": _Name
	secret: #SecretSpec & {
		#metadata: name:      string | *_Name
		#metadata: namespace: string | *_Namespace
		#name: string | *#metadata.name
	}
}

// SecretList is a list of secrets.
#SecretList: core.#Trait & {
	#kind: "SecretList"
	items: [...#Secret]
}
