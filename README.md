# zig-nicetime
A collection of compile-time utilities that make Zig's compile-time semantics even nicer to work with.

# Installation
Whilst in your project's root folder, run this in the terminal:

```shell
zig fetch --save git+https://github.com/nylvon/zig-nicetime#main
```

This will fetch the latest version of this library, which may not be the best practice, as this branch is not going to be the most stable, but you can fine-tune your selection, limiting to a certain tag or whatnot.

Once done, go to your project's build.zig file, open it up, and add these lines, if your project is an executable (adjust accordingly):

```zig
const zig_nicetime = b.dependency("zig-nicetime", .{
    .target = target,
    .optimize = optimize,
}).module("zig-nicetime");

exe.root_module.addImport("zig-nicetime", zig_nicetime);
```

You should now be able to use zig-nicetime across your project. Have fun!