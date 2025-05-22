package traits

import (
	core "jacero.io/crw/v1alpha1/core"
)

#DatabaseSpec: {
	core.#CommonObject
	#kind: "Database"
	#metadata: name: string

	// The type of the database
	type: string | *"PostgreSQL" | "MySQL" | "MariaDB" | "MongoDB"

	// The version of the database
	// Example: "13.3", "5.7", "4.4"
	version: string

	// The port of the database
	port: int & >=0 & <=65535

	if type == "PostgreSQL" {
		port: uint | *5432
	}
	if type == "MySQL" {
		port: uint | *3306
	}
	if type == "MongoDB" {
		port: uint | *3306
	}

	// The connection string to the database
	connectionString: string

	if type == "PostgreSQL" {
		connectionString: string | *"postgresql://\(credentials.username):\(credentials.password)@localhost/\(#metadata.name)"
	}
	if type == "MySQL" || type == "MariaDB" {
		// MariaDB is a fork of MySQL
		connectionString: string | *"mysql://\(credentials.username):\(credentials.password)@localhost/\(#metadata.name)"
	}
	if type == "MongoDB" {
		connectionString: string | *"mongodb://\(credentials.username):\(credentials.password)@localhost/\(#metadata.name)"
	}

	// The credentials to access the database
	credentials: {
		username: string
		password: string
	} | *#SecretRef
}

#Database: core.#Trait & {
	let _Name = #metadata.name
	let _Namespace = #metadata.namespace
	#metadata: traits: Database:                    null
	#metadata: annotations: "db.jacero.io/runtime": database.type
	#metadata: annotations: "db.jacero.io/version": database.version

	database: #DatabaseSpec & {
		#metadata: name:      string | *_Name
		#metadata: namespace: string | *_Namespace
		#name: string | *#metadata.name
	}
}

#DatabaseList: {
	core.#CommonObject
	#kind: "DatabaseList"
	databases: [...#Database]
}
