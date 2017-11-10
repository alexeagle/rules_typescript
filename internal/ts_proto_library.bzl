# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""The ts_proto_library rule generates both JavaScript and .d.ts files for
interacting with protocol buffers.

Based on https://www.npmjs.com/package/protobufjs:
https://github.com/dcodeIO/ProtoBuf.js/#pbts-for-typescript
"""

def _ts_proto_library(ctx):
  jsargs = ctx.actions.args()
  jsargs.add(ctx.files.srcs)
  jsargs.add("-o")
  jsargs.add(ctx.outputs.js.path)
  ctx.actions.run(
      inputs = ctx.files.srcs,
      outputs = [ctx.outputs.js],
      executable = ctx.executable._pbjs,
  )

  tsargs = ctx.actions.args()
  tsargs.add(ctx.outputs.js.path)
  tsargs.add("-o")
  tsargs.add(ctx.outputs.dts.path)
  ctx.actions.run(
      inputs = [ctx.outputs.js],
      outputs = [ctx.outputs.dts],
      executable = ctx.executable._pbts,
  )
  return struct(
      typescript = struct(
          declarations = [ctx.outputs.dts],
          transitive_declarations = [ctx.outputs.dts],
          type_blacklisted_declarations = [],
      ),
      default = [DefaultInfo(files = depset([ctx.outputs.js, ctx.outputs.dts]))],
  )

ts_proto_library = rule(
    implementation = _ts_proto_library,
    attrs = {
        "_pbjs": attr.label(default = Label("//internal:pbjs"), executable = True, cfg = "host"),
        "_pbts": attr.label(default = Label("//internal:pbts"), executable = True, cfg = "host"),
        "srcs": attr.label_list(allow_files = True),
    },
    outputs = {
        "js": "%{name}.js",
        "dts": "%{name}.d.ts",
    }
)
