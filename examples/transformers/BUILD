package(default_visibility = ["//visibility:public"])

load("//:defs.bzl", "ts_library")

ts_library(
    name = "upper_case_xform",
    srcs = ["upper_case_xform.ts"],
    tsconfig = "//examples:tsconfig.json",
)

ts_library(
    name = "transformers",
    srcs = ["test.ts"],
    transformers = ":upper_case_xform",
    tsconfig = "//examples:tsconfig.json",
)