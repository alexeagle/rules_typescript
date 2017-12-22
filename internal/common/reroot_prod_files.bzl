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

"""Used by production rules to expose a file tree of only prod files.
"""

def reroot_prod_files(ctx):
  """Returns a file tree containing only production files.

  Args:
    ctx: ctx.

  Returns:
    A file tree containing only production files.
  """
  rerooted_prod_files = depset()
  for dep in ctx.attr.deps:
    if hasattr(dep, "typescript"):
      for es6_source in dep.typescript.transitive_es6_sources:
        workspace = ""
        if not es6_source.owner.workspace_root:
          workspace = ctx.workspace_name
        rerooted_prod_file = ctx.actions.declare_file("/".join([f for f in [
          ctx.label.name + ".prod",
          "node_modules",
          workspace,
          es6_source.short_path.replace("../", "").replace(".closure.js", ".js")
        ] if f]))
        ctx.actions.expand_template(
          output = rerooted_prod_file,
          template = es6_source,
          substitutions = {}
        )
        rerooted_prod_files += [rerooted_prod_file]
    elif hasattr(dep, "closure_js_library"):
      rerooted_prod_files += dep.closure_js_library.srcs
    elif hasattr(dep, "files"):
      rerooted_prod_files += dep.files
    else:
      fail(
          ("%s is neither a TypeScript nor a Closure JS library producing rule." % dep.label) +
          "\nDependencies must be ts_library, ts_declaration, or closure_js_library.")    
    
  return rerooted_prod_files
