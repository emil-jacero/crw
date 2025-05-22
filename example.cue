package main

import (
	core "jacero.io/crw/v1alpha1/core"
	traits "jacero.io/crw/v1alpha1/traits"
)

stack: core.#Stack & {
	#metadata: name: "simple-webapp"

	// #metadata: namespace: "default"
	#metadata: annotations: description: "A simple web application"
	#metadata: annotations: version:     "0.1.0"

	components: {
		db: {
			traits.#Database
			database: {
				type:    "PostgreSQL"
				version: "16.0"
				credentials: {
					#kind:     "Secret"
					name:      stack.components.db.secret.#metadata.name
					namespace: stack.components.db.secret.#metadata.namespace
				}
			}

			traits.#Secret
			secret: {
				type: "opaque"
				stringData: {
					username: "admin"
					password: "password"
				}
			}
		}
		app: {
			traits.#Pod

			containers: {
				app: {
					#default: true
					image:    "nginx:latest"
					ports: {
						http: {
							containerPort: 80
						}
					}
				}
			}
		}
	}
}
