load("@io_bazel_rules_go//go:def.bzl", "GoSource", "go_context")

def _go_ent_library_impl(ctx):
    go = go_context(ctx)

    # TODO: Discuss single-file output with Ent maintainers.

    files = []
    for f in [
        "client",
        "config",
        "context",
        "mutation",
        "runtime",
        "tx",
        "enttest/enttest",
        "hook/hook",
        "migrate/migrate",
        "migrate/schema",
        "predicate/predicate",
        "runtime/runtime",
    ]:
        files.append(f + ".go")

    # TODO: get entity names from schema.
    for entity in ctx.attr.entities:
        for suffix in ["", "_create", "_delete", "_query", "_update"]:
            files.append(entity + suffix + ".go")
        files.append(entity + "/" + entity + ".go")
        files.append(entity + "/where.go")

    libraries = {}
    outputs = []
    for f in files:
        outfile = ctx.actions.declare_file(f)
        outputs.append(outfile)
        (dir, _, _) = f.rpartition("/")
        libraries.setdefault(dir, []).append(outfile)

    schema_path = "./" + ctx.attr.schema.label.package
    schema_package = ctx.attr.schema.label.name
    target_path = outputs[0].dirname  # TODO: better/cleaner way?
    target_package = ctx.attr.importpath

    ctx.actions.run_shell(
        mnemonic = "EntGenerate",
        progress_message = "Generating Ent files in {dir}".format(dir = target_path),
        command = """
        set -eu

        export PATH="$(pwd)/{gobin}:$PATH"
        export GOCACHE="$(pwd)/.gocache"
        export GOPATH="$(pwd)/.gopath"

        exec {generate} "$@"
        """.format(
            gobin = go.go.dirname,
            generate = ctx.executable._generate.path,
        ),
        arguments = [schema_path, schema_package, target_path, target_package],
        # TODO: check rules_go again what tools are really needed here.
        tools = [ctx.executable._generate] + go.sdk_tools + go.sdk_files,
        inputs = depset(ctx.files.gomod + ctx.attr.schema[GoSource].srcs),
        outputs = outputs,
        env = {"GOROOT_FINAL": "GOROOT"},
    )

    for dirname, files in libraries.items():
        if dirname:
            # TODO: Generate sublibraries
            pass

    library = go.new_library(go, srcs = libraries[""], deps = ctx.attr.deps + [ctx.attr.schema])
    source = go.library_to_source(go, ctx.attr, library, ctx.coverage_instrumented())
    archive = go.archive(go, source = source)

    # TODO: Generate go_library() for each package. Can gazelle do that?

    # TODO: Turn off GO111MODULE and try to work with GOPATH?

    return [library, source, archive, DefaultInfo(files = depset(outputs)), OutputGroupInfo(
        cgo_exports = archive.cgo_exports,
        compilation_outputs = [archive.data.file],
    )]

go_ent_library = rule(
    implementation = _go_ent_library_impl,
    attrs = {
        "schema": attr.label(
            mandatory = True,
        ),
        "_generate": attr.label(
            executable = True,
            default = Label("@com_github_cloneable_rules_ent//cmd/generate"),
            cfg = "exec",
        ),
        "_go_context_data": attr.label(
            default = Label("@io_bazel_rules_go//:go_context_data"),
        ),
        "importpath": attr.string(mandatory = True),
        "deps": attr.label_list(
            default = [
                "@io_entgo_ent//:go_default_library",
                "@io_entgo_ent//dialect:go_default_library",
                "@io_entgo_ent//dialect/sql:go_default_library",
                "@io_entgo_ent//dialect/sql/schema:go_default_library",
                "@io_entgo_ent//dialect/sql/sqlgraph:go_default_library",
                "@io_entgo_ent//schema/field:go_default_library",
            ],
        ),
        "gomod": attr.label(),
        # TODO: remove this.
        "entities": attr.string_list(mandatory = True),
    },
    toolchains = ["@io_bazel_rules_go//go:toolchain"],
)
