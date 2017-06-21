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

"""Run `yarn check` to ensure the node_modules is still hermetic with respect to
the yarn.lock file and the version of node and yarn that we installed in the
WORKSPACE.
TODO(alexeagle): make this an input of every nodejs_binary execution
"""

load(":executables.bzl", "get_node")

def _yarn_check_impl(ctx):
  stamp_file = ctx.new_file("/".join([ctx.bin_dir.path, ctx.label.package, ctx.label.name + "_stamp"]))
  ctx.action(
      executable = ctx.file._node,
      arguments = [ctx.file._yarn.path, "check", "--integrity"],
      inputs = ctx.files._node_modules + ctx.files._yarn_modules + [ctx.file._yarn],
      outputs = [stamp_file],
      env = {
          "NODE_PATH": "external/yarn/node_modules"
      },
  )

  return struct(
      files = set([stamp_file])
  )

yarn_check = rule(
    _yarn_check_impl,
    attrs = {
        "yarn_lock": attr.label(allow_files=True, single_file=True),
        "_node_modules": attr.label(
            default = Label("@npm//installed:node_modules")),
        "_node": attr.label(default = get_node(), allow_files=True, single_file=True),
        "_yarn": attr.label(allow_files=True, single_file=True, default = Label("@yarn//:bin/yarn.js")),
        "_yarn_modules": attr.label(default = Label("@yarn//:node_modules")),
    },
)
