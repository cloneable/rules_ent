load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def ent_go_repositories():
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "2b1641428dff9018f9e85c0384f03ec6c10660d935b750e3fa1492a281a53b0f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
        ],
    )

    # http_archive(
    #     name = "com_github_ent_ent",
    #     sha256 = "45214bb6f9b31015f4d021c577d8e51380e877fcac3c4ec06e53bb80d4d25f92",
    #     strip_prefix = "ent-0.9.1",
    #     urls = [
    #         "https://github.com/ent/ent/archive/refs/tags/v0.9.1.zip",
    #     ],
    # )

    http_archive(
        name = "bazel_gazelle",
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        ],
    )
