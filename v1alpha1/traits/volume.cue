package traits

import (
	core "jacero.io/crw/v1alpha1/core"
)

// Validates k8s-style resource quantities (e.g. "1Gi", "500Mi").
#QuantityRE: =~"^[0-9]+(\\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei)?$"

// Supported access modes, including the k8s ReadWriteOncePod added in 1.22.
#AccessModes: [string] | *["ReadWriteOnce"] | ["ReadOnlyMany"] | ["ReadWriteMany"] | ["ReadWriteOncePod"]

// Volume modes: block devices or filesystem mounts.
#VolumeMode: string | *"Filesystem" | "Block"

// Kubernetes-only lifecycle policies.
#ReclaimPolicy: *"Retain" | "Delete" | "Recycle"
#BindingMode:   *"Immediate" | "WaitForFirstConsumer"

// Placeholder for node affinity rules (topology constraints).
#NodeAffinity: {
	[string]: _
}

#VolumeSpec: {
	// Capacity (ignored by Compose)
	size?: string & #QuantityRE

	// Desired access semantics.  For Compose it is advisory only.
	accessModes?: #AccessModes

	// Filesystem vs. raw block
	volumeMode?: #VolumeMode

	// Compose: volume driver (e.g. "local", "nfs").
	// Kubernetes: fallback StorageClass / CSI driver if storageClassName is omitted.
	driver?: string | *"local"

	// Kubernetes‑specific.  If unset, defaults to driver.
	storageClassName?: string

	// Driver / StorageClass parameters
	options?: {[string]: string}

	// Per‑mount flags e.g. "noatime"
	mountOptions?: [...string]

	// Lifecycle hints (K8s‑only)
	reclaimPolicy?: #ReclaimPolicy
	bindingMode?:   #BindingMode
	nodeAffinity?:  #NodeAffinity

	// Use existing backend
	external?: bool | *false
	if external {
		persistentVolumeName: string
	}
}

// Inspired by Kubernetes Volume but simplified.
#Volume: core.#Trait & {
	#kind: "Volume"

	#VolumeSpec
}

#VolumeList: core.#Trait & {
	#kind: "VolumeList"
	items: [...#Volume]
}
