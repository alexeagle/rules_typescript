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

workspace(name = "build_bazel_rules_typescript")

git_repository(
    name = "build_bazel_rules_nodejs",
    remote = "https://github.com/bazelbuild/rules_nodejs",
    tag = "0.0.4",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories")

# Install a hermetic version of node.
# After this is run, these labels will be available:
# - The nodejs install:
#   @build_bazel_rules_typescript_node//:bin/node
#   @build_bazel_rules_typescript_node//:bin/npm
# - The yarn package manager:
#   @yarn//:yarn
node_repositories(package_json = ["//:package.json"])

#git_repository(
#    name = "io_bazel_rules_closure",
#    commit = "4af89ef1db659eb41f110df189b67d4cf14073e1",
#    remote = "https://github.com/bazelbuild/rules_closure",
#)

git_repository(
    name = "io_bazel_rules_closure",
    commit = "37c629090c7d36e9dfdb90e1f40ea09b7238f2ba",
    remote = "https://github.com/Yannic/rules_closure",
)

load("@io_bazel_rules_closure//closure:defs.bzl", "closure_repositories")

# TODO: Todon't do this.
#load("@io_bazel_rules_closure//closure/private:java_import_external.bzl", "java_import_external")
#
#java_import_external(
#    name = "com_google_javascript_closure_compiler",
#    extra_build_file_content = "\n".join([
#        "java_binary(",
#        "    name = \"main\",",
#        "    main_class = \"com.google.javascript.jscomp.CommandLineRunner\",",
#        "    output_licenses = [\"unencumbered\"],",
#        "    runtime_deps = [",
#        "        \":com_google_javascript_closure_compiler\",",
#        "        \"@args4j\",",
#        "    ],",
#        ")",
#    ]),
#    #jar_sha256 = "c404e56bc6676115fcbc7a7dedd4a933580b58cb908e9dd90b3d2802c84d52d7",
#    jar_sha256 = "f99f8520ecfb115b489e35768644fd236faf09488d3c2ee23a623562a026618b",
#    jar_urls = [
#        #"https://achew.users.x20web.corp.google.com/www/closure/closure-compiler-1.0-SNAPSHOT.jar",
#        "http://localhost:8000/closure-compiler-1.0-SNAPSHOT.jar",
#    ],
#    licenses = ["reciprocal"],  # MPL v1.1 (Rhino AST), Apache 2.0 (JSCompiler)
#    deps = [
#        "@com_google_code_findbugs_jsr305",
#        "@com_google_code_gson",
#        "@com_google_guava",
#        "@com_google_protobuf_java",
#    ],
#)
#
#closure_repositories(omit_com_google_javascript_closure_compiler = True)
closure_repositories()
