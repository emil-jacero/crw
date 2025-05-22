package traits

import (
	core "jacero.io/crw/v1alpha1/core"
)

#Env: {
	[string]: string
}

#ContainerSpec: {
	core.#CommonObject
	#kind: "Container"
	#metadata: name: string
	#default: bool | *false

	image: core.#Image.reference
	command: [...string]
	args: [...string]
	env: #Env
	mounts: [...{
		volume: core.#VolumeSpec & {}
	}]
	resources: core.#ResourceRequirements
	restart?:  string | *"Always" | "OnFailure" | "Never"
}

// Workload is a trait that represents multiple containers but they are not necessarily sharing the same namespace or storage.
#Workload: core.#Trait & {
	let _Name = #metadata.name
	let _Namespace = #metadata.namespace
	#metadata: traits: Workload:                       null
	#metadata: annotations: "workload.jacero.io/name": _Name

	// The containers that are part of the workload
	containers: #ContainerSpec & {
		#metadata: name:      string | *_Name
		#metadata: namespace: string | *_Namespace
		#name: string | *#metadata.name
	}

	// Restart policy for the workload
	restart: string | *"Always" | "OnFailure" | "Never"

	// Only relevant for Deployment and StatefulSet
	rollout?: {
		maxSurgePercentage?:     uint & <=100 & >=0
		minAvailablePercentage?: uint & <=100 & >=0
	}
}

// Pod is a trait that represents a single container or multiple containers that share the same namespace and/or storage.
#Pod: core.#Trait & {
	let _Name = #metadata.name
	let _Namespace = #metadata.namespace
	#metadata: traits: Pod:                       null
	#metadata: annotations: "pod.jacero.io/name": _Name

	// The containers that are part of the workload
	containers: #ContainerSpec & {
		#metadata: name:      string | *_Name
		#metadata: namespace: string | *_Namespace
		#name: string | *#metadata.name
	}

	// Restart policy for the workload
	restart: string | *"Always" | "OnFailure" | "Never"

	// Only relevant for Deployment and StatefulSet
	rollout?: {
		maxSurgePercentage?:     uint & <=100 & >=0
		minAvailablePercentage?: uint & <=100 & >=0
	}
}
