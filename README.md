# `rules_nodejs` bug reproduction

When executing a `nodejs_binary()` target with the `host` configuration as a
build tool (via `npm_package_bin()` or `run_node()`), absolute imports cannot be
resolved at runtime, even with `link_workspace_root = True`.

To reproduce:

```
$ npm install

$ bazel run //:tool # Works
INFO: Invocation ID: e363ba04-7aa2-47ef-9c70-3122a4696f03
INFO: Analyzed target //:tool (0 packages loaded, 8 targets configured).
INFO: Found 1 target...
Target //:tool up-to-date:
  dist/bin/tool.sh
  dist/bin/tool_loader.js
  dist/bin/tool_require_patch.js
INFO: Elapsed time: 0.305s, Critical Path: 0.01s
INFO: 1 process: 1 internal.
INFO: Build completed successfully, 1 total action
INFO: Build completed successfully, 1 total action
bar
baz

$ bazel build //:npm_package_bin # Fails
INFO: Invocation ID: b585aea3-7b71-406d-a17b-e8af22cfc495
INFO: Analyzed target //:npm_package_bin (0 packages loaded, 1 target configured).
INFO: Found 1 target...
ERROR: /home/dparker/Source/nodejs_binary_host/BUILD.bazel:5:16: Action output.txt failed (Exit 1) tool.sh failed: error executing command bazel-out/host/bin/tool.sh '--bazel_node_modules_manifest=bazel-out/k8-fastbuild/bin/_npm_package_bin.module_mappings.json'

Use --sandbox_debug to see verbose messages from the sandbox
internal/modules/cjs/loader.js:797
    throw err;
    ^

Error: Cannot find module 'nodejs_binary_host/baz'
Require stack:
- /home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/10/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js
    at Function.Module._resolveFilename (internal/modules/cjs/loader.js:794:15)
    at Function.Module._load (internal/modules/cjs/loader.js:687:27)
    at Module.require (internal/modules/cjs/loader.js:849:19)
    at require (internal/modules/cjs/helpers.js:74:18)
    at Object.<anonymous> (/home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/10/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js:4:13)
    at Module._compile (internal/modules/cjs/loader.js:956:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:973:10)
    at Module.load (internal/modules/cjs/loader.js:812:32)
    at Function.Module._load (internal/modules/cjs/loader.js:724:14)
    at Function.Module.runMain (internal/modules/cjs/loader.js:1025:10) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [
    '/home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/10/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js'
  ]
}
Target //:npm_package_bin failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 0.309s, Critical Path: 0.09s
INFO: 3 processes: 3 internal.
FAILED: Build did NOT complete successfully

$ bazel build //:run_node # Fails
INFO: Invocation ID: 48e1e6c2-ff6f-4480-b0a2-a69e1380469a
INFO: Analyzed target //:run_node (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
ERROR: /home/dparker/Source/nodejs_binary_host/BUILD.bazel:11:8: Action run_node failed (Exit 1) tool.sh failed: error executing command bazel-out/host/bin/tool.sh '--bazel_node_modules_manifest=bazel-out/k8-fastbuild/bin/_run_node.module_mappings.json'

Use --sandbox_debug to see verbose messages from the sandbox
internal/modules/cjs/loader.js:797
    throw err;
    ^

Error: Cannot find module 'nodejs_binary_host/baz'
Require stack:
- /home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/11/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js
    at Function.Module._resolveFilename (internal/modules/cjs/loader.js:794:15)
    at Function.Module._load (internal/modules/cjs/loader.js:687:27)
    at Module.require (internal/modules/cjs/loader.js:849:19)
    at require (internal/modules/cjs/helpers.js:74:18)
    at Object.<anonymous> (/home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/11/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js:4:13)
    at Module._compile (internal/modules/cjs/loader.js:956:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:973:10)
    at Module.load (internal/modules/cjs/loader.js:812:32)
    at Function.Module._load (internal/modules/cjs/loader.js:724:14)
    at Function.Module.runMain (internal/modules/cjs/loader.js:1025:10) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [
    '/home/dparker/.cache/bazel/_bazel_dparker/495c75b6438049fb6deb585ddc366361/sandbox/linux-sandbox/11/execroot/nodejs_binary_host/bazel-out/host/bin/tool.sh.runfiles/nodejs_binary_host/foo.js'
  ]
}
Target //:run_node failed to build
Use --verbose_failures to see the command lines of failed build steps.
INFO: Elapsed time: 0.291s, Critical Path: 0.10s
INFO: 2 processes: 2 internal.
FAILED: Build did NOT complete successfully
```
