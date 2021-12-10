# rules_ent

Bazel rules for Ent code generation

> **[WIP; still very hacky]**

## Usage

Unless done by `gazelle`, in the `BUILD` file of the schema package:

```python
load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "schema",
    srcs = ["entity.go"],
    importpath = "github.com/cloneable/repo/path/to/schema",
    visibility = ["//:__subpackages__"],
    deps = [
        "@io_entgo_ent//:go_default_library",
        "@io_entgo_ent//schema/field:go_default_library",
    ],
)
```

Define a `go_ent_library` in the `BUILD` file of the target package. `go_ent_library` can be depend upon like a `go_library`.

```python
load("@com_github_cloneable_rules_ent//:defs.bzl", "go_ent_library")

go_ent_library(
    name = "ent",
    entities = ["entity"],        # temporarily needed
    gomod = "//:go_mod",          # hopefully only temporarily needed
    importpath = "github.com/cloneable/repo/target/package/ent",
    schema = "//path/to/schema",  # go_library of schema package
    visibility = ["//:__subpackages__"],
)
```

Define a `filegroup` with `go.mod` and `go.sum` in the `BUILD` file of the root
of the Go module because `entc` calls the `go` tool, which expects to find a
proper module. This may change in the future.

```python
filegroup(
    name = "go_mod",
    srcs = [
        "go.mod",
        "go.sum",
    ],
    visibility = ["//:__subpackages__"],
)
```

In your `WORKSPACE` file:

```python
http_archive(
    name = "com_github_cloneable_rules_ent",
    sha256 = "...",
    strip_prefix = "rules_ent-...",
    urls = ["https://github.com/cloneable/rules_ent/..."],
)
```
