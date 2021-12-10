load("@io_bazel_rules_go//go:def.bzl", "GoSource", "go_context")

def _go_ent_library_impl(ctx):
    go = go_context(ctx)

    # TODO: Discuss single-file output with Ent maintainers.

    outputs = []
    for f in [
        "client",
        "config",
        "context",
        "mutation",
        "runtime",
        "tx",
        # TODO: declare subdirs.
        # "enttest/enttest",
        # "hook/hook",
        # "migrate/migrate",
        # "migrate/schema",
        # "predicate/predicate",
        # "runtime/runtime",
    ]:
        outputs.append(ctx.actions.declare_file(f + ".go"))

    # TODO: get entity names from schema.
    for entity in ctx.attr.entities:
        for suffix in ["", "_create", "_delete", "_query", "_update"]:
            outputs.append(ctx.actions.declare_file(entity + suffix + ".go"))

        # TODO: declare subdirs.
        # outputs.append(ctx.actions.declare_file(entity + "/" + entity + ".go"))
        # outputs.append(ctx.actions.declare_file(entity + "/where.go"))

    schema_path = "./" + ctx.attr.schema.label.package
    schema_package = ctx.attr.schema.label.name
    target_path = outputs[0].dirname  # TODO: better/cleaner way?
    target_package = ctx.label.name

    ctx.actions.run_shell(
        mnemonic = "EntGenerate",
        progress_message = "Generating Ent files in {dir}".format(dir = target_path),
        command = """
        set -eu

        export PATH="$(pwd)/{gobin}:$PATH"
        export GOROOT="$(pwd)/$GOROOT"
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
        inputs = depset(ctx.files.deps + ctx.attr.schema[GoSource].srcs),
        outputs = outputs,
        env = go.env,
    )

    # TODO: Generate go_library() for each package. Can gazelle do that?

    # TODO: Turn off GO111MODULE and try to work with GOPATH?

    return [DefaultInfo(files = depset(outputs + ctx.files.schema))]

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
        "deps": attr.label_list(),
        # TODO: remove this.
        "entities": attr.string_list(mandatory = True),
    },
    toolchains = ["@io_bazel_rules_go//go:toolchain"],
)
