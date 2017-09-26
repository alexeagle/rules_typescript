#!/bin/bash
set -e

readonly BUNDLE=$(cat $TEST_SRCDIR/build_bazel_rules_typescript/examples/es6_output/closure.js)
if [[ "$BUNDLE" != 'for(var a=0;100>a;a++)console.log("hello, $i, world"+a);' ]]; then
  echo "Expected closure.js to match golden but was"
  echo "$BUNDLE"
  exit 1
fi
