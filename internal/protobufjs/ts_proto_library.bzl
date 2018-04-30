"""Wraps https://github.com/dcodeIO/ProtoBuf.js/ in Bazel.
"""

def _run_pbjs(actions, executable, output_name, proto_files, suffix = ".js", wrap = "amd", amd_name = ""):
  js_file = actions.declare_file(output_name + suffix)

  # Create an intermediate file so that we can do some manipulation of the
  # generated .js output that makes it compatible with our named AMD loading.
  js_tmpl_file = actions.declare_file(output_name + suffix + ".tmpl")

  # Reference of arguments:
  # https://github.com/dcodeIO/ProtoBuf.js/#pbjs-for-javascript
  args = actions.args()
  args.add(["--target", "static-module"])
  args.add(["--wrap", wrap])
  args.add(["--out", js_file.path + ".tmpl"])
  args.add([f.path for f in proto_files])

  actions.run(
      executable = executable._pbjs,
      inputs = proto_files,
      outputs = [js_tmpl_file],
      arguments = [args],
  )

  actions.expand_template(
      template = js_tmpl_file,
      output = js_file,
      substitutions = {
          # convert anonymous AMD module
          #  define(["protobufjs/minimal"], function($protobuf) {
          # to named
          #  define("wksp/path/to/module", ["protobufjs/minimal"], ...
          "define([": "define('%s/%s', [" % (amd_name, output_name),
      }
  )
  return js_file

def _run_pbts(actions, executable, js_file):
  ts_file = actions.declare_file(js_file.basename[:-len(".closure.js")] + ".d.ts")

  # Reference of arguments:
  # https://github.com/dcodeIO/ProtoBuf.js/#pbts-for-typescript
  args = actions.args()
  args.add(["--out", ts_file.path])
  args.add(js_file.path)

  actions.run(
      executable = executable._pbts,
      progress_message = "Generating typings from %s" % js_file.short_path,
      inputs = [js_file],
      outputs = [ts_file],
      arguments = [args],
  )
  return ts_file

def _ts_proto_library(ctx):
  sources = depset()
  for dep in ctx.attr.deps:
    if not hasattr(dep, "proto"):
      fail("ts_proto_library dep %s must be a proto_library rule" % dep.label)
    # TODO(alexeagle): go/new-proto-library suggests
    # > should not parse .proto files. Instead, they should use the descriptor
    # > set output from proto_library
    # but protobuf.js doesn't seem to accept that bin format
    sources = depset(transitive = [sources, dep.proto.transitive_sources])

  output_name = ctx.attr.output_name or ctx.label.name

  js_es5 = _run_pbjs(ctx.actions, ctx.executable, output_name, sources,
                     amd_name = "/".join([p for p in [
                         ctx.workspace_name,
                         ctx.label.package,
                     ] if p]))
  js_es6 = _run_pbjs(ctx.actions, ctx.executable, output_name, sources,
                     suffix = ".closure.js", wrap = "es6")
  dts = _run_pbts(ctx.actions, ctx.executable, js_es6)

  # Return a structure that is compatible with the deps[] of a ts_library.
  return struct(
    files = depset([dts]),
    typescript = struct(
      declarations = [dts],
      transitive_declarations = [dts],
      type_blacklisted_declarations = [],
      es5_sources = depset([js_es5]),
      es6_sources = depset([js_es6]),
      transitive_es5_sources = depset(),
      transitive_es6_sources = depset(),
    ),
  )

ts_proto_library = rule(
    implementation = _ts_proto_library,
    attrs = {
        "deps": attr.label_list(doc = """proto_library targets"""),
        "output_name": attr.string(),
        "_pbjs": attr.label(default = Label("//internal/protobufjs:pbjs"),
            executable = True, cfg = "host"),
        "_pbts": attr.label(default = Label("//internal/protobufjs:pbts"),
            executable = True, cfg = "host"),
    },
)
"""
`ts_proto_library` has identical outputs to `ts_library`, so it can be used anywhere
a `ts_library` can appear, such as in the `deps[]` of another `ts_library`.

Example:

```
load("@build_bazel_rules_typescript//:defs.bzl", "ts_library", "ts_proto_library")

ts_proto_library(
    name = "car_proto",
    srcs = ["car.proto"],
)

ts_library(
    name = "test_lib",
    testonly = True,
    srcs = ["car.spec.ts"],
    deps = [":car_proto"],
)
```

The JavaScript produced by protobuf.js has a runtime dependency on a support library.
Under devmode (e.g. `ts_devserver`, `ts_web_test`) you'll need to include these scripts
in the `bootstrap` phase (before Require.js loads). You can use the label
`@build_bazel_rules_typescript//:protobufjs_bootstrap_scripts` to reference these scripts.

After Require.js loads, we need to provide a name for the `protobufjs` global symbol
so that it can be require'd. Put this code somewhere in your app:
`define("protobufjs/minimal", () => protobuf);`

To complete the example above, you could write a `ts_web_test`:

```
load("@build_bazel_rules_typescript//:defs.bzl", "ts_web_test")

ts_web_test(
    name = "test",
    deps = ["test_lib"],
    bootstrap = ["@build_bazel_rules_typescript//:protobufjs_bootstrap_scripts"],
    srcs = ["require.config.js"],
)
```

where require.config.js contains the `define` statement above.
"""