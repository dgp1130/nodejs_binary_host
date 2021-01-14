load("@build_bazel_rules_nodejs//:providers.bzl", "run_node")

def _my_rule_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.name)
    run_node(
        ctx = ctx,
        executable = "_tool",
        inputs = [],
        outputs = [output],
        arguments = [],
    )

    return DefaultInfo(files = depset([output]))

my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        "_tool": attr.label(
            default = "//:tool",
            executable = True,
            cfg = "host",
        ),
    },
)
