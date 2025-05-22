package core

import (
	"strconv"
	"strings"
)

#DefaultAPIVersion: string | *"v1alpha1"
#DefaultKind:       string

#CommonObject: {
	#apiVersion:      #DefaultAPIVersion
	#kind:            #DefaultKind
	#combinedVersion: string | "\(#apiVersion)/\(#kind)"
	#metadata: {
		name:       string
		namespace?: string
		labels: [string]:      string
		annotations: [string]: string
		...
	}
}

#NamedObjectRef: {
	#apiVersion: string | *#DefaultAPIVersion
	#kind:       string | *#DefaultKind
	name:        string
	namespace?:  string
}

// SemVer validates the input version string and extracts the major and minor version numbers.
// When Minimum is set, the major and minor parts must be greater or equal to the minimum
// or a validation error is returned.
// Usage:
// example: #SemVer & {
// 	   #Version: kubeVersion
// 	   #Minimum: "1.20.0"
// }
#SemVer: {
	// Input version string in strict semver format.
	#Version!: string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

	// Minimum is the minimum allowed MAJOR.MINOR version.
	#Minimum: *"0.0.0" | string & =~"^\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

	let minMajor = strconv.Atoi(strings.Split(#Minimum, ".")[0])
	let minMinor = strconv.Atoi(strings.Split(#Minimum, ".")[1])

	major: int & >=minMajor
	major: strconv.Atoi(strings.Split(#Version, ".")[0])

	minor: int & >=minMinor
	minor: strconv.Atoi(strings.Split(#Version, ".")[1])

	patch: int
	patch: strconv.Atoi(strings.Split(#Version, ".")[2])

	preRelease: string
	preRelease: strings.Split(#Version, "-")[1]

	buildMetadata: string
	buildMetadata: strings.Split(#Version, "+")[1]
}

// Image defines the schema for OCI image reference used in Kubernetes PodSpec container image.
#Image: {

	// Repository is the address of a container registry repository.
	// An image repository is made up of slash-separated name components, optionally
	// prefixed by a registry hostname and port in the format [HOST[:PORT_NUMBER]/]PATH.
	repository!: string

	// Tag identifies an image in the repository.
	// A tag name may contain lowercase and uppercase characters, digits, underscores, periods and dashes.
	// A tag name may not start with a period or a dash and may contain a maximum of 128 characters.
	tag!: string & strings.MaxRunes(128)

	// Digest uniquely and immutably identifies an image in the repository.
	// Spec: https://github.com/opencontainers/image-spec/blob/main/descriptor.md#digests.
	digest!: string

	// PullPolicy defines the pull policy for the image.
	// By default, it is set to IfNotPresent.
	pullPolicy: *"IfNotPresent" | "Always" | "Never"

	// Reference is the image address computed from repository, tag and digest
	// in the format [REPOSITORY]:[TAG]@[DIGEST].
	reference: string

	if digest != "" && tag != "" {
		reference: "\(repository):\(tag)@\(digest)"
	}

	if digest != "" && tag == "" {
		reference: "\(repository)@\(digest)"
	}

	if digest == "" && tag != "" {
		reference: "\(repository):\(tag)"
	}

	if digest == "" && tag == "" {
		reference: "\(repository):latest"
	}
}

// CPUQuantity is a string that is validated as a quantity of CPU, such as 100m or 2000m.
#CPUQuantity: string & =~"^[1-9]\\d*m$"

// MemoryQuantity is a string that is validated as a quantity of memory, such as 128Mi or 2Gi.
#MemoryQuantity: string & =~"^[1-9]\\d*(Mi|Gi)$"

// ResourceRequirement defines the schema for the CPU and Memory resource requirements.
#ResourceRequirement: {
	cpu?:    #CPUQuantity
	memory?: #MemoryQuantity
}

// ResourceRequirements defines the schema for the compute resource requirements of a container.
// More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/.
#ResourceRequirements: {
	// Limits describes the maximum amount of compute resources allowed.
	limits?: #ResourceRequirement

	// Requests describes the minimum amount of compute resources required.
	// Requests cannot exceed Limits.
	requests?: #ResourceRequirement & {
		if limits != _|_ {
			if limits.cpu != _|_ {
				_lc:  strconv.Atoi(strings.Split(limits.cpu, "m")[0])
				_rc:  strconv.Atoi(strings.Split(requests.cpu, "m")[0])
				#cpu: int & >=_rc & _lc
			}
		}
	}
}
