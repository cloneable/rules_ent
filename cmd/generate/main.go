package main

import (
	"log"
	"os"

	"entgo.io/ent/entc"
	"entgo.io/ent/entc/gen"
)

func main() {
	schemaPath := os.Args[1]
	schemaPackage := os.Args[2]
	targetPath := os.Args[3]
	targetPackage := os.Args[4]
	cfg := gen.Config{
		Schema:  schemaPackage,
		Target:  targetPath,
		Package: targetPackage,
	}
	if err := entc.Generate(schemaPath, &cfg); err != nil {
		log.Fatalf("entc failed: %v", err)
	}
}
