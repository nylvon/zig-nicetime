const std = @import("std");

// Ease of use function to add tests, steps and bits to the project.
pub fn addTest(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
) !*std.Build.Step {
    var file_name_buffer: [64]u8 = undefined;
    var description_buffer: [64]u8 = undefined;
    var test_command_buffer: [64]u8 = undefined;
    const file_name: []u8 = try std.fmt.bufPrint(&file_name_buffer, "src/{s}.zig", .{name});
    const description: []u8 = try std.fmt.bufPrint(&description_buffer, "Run {s} tests.", .{name});
    const test_command: []u8 = try std.fmt.bufPrint(&test_command_buffer, "test {s}", .{name});

    const new_test = b.addTest(.{
        .root_source_file = b.path(file_name),
        .target = target,
        .optimize = optimize,
    });

    const run_new_test = b.addRunArtifact(new_test);

    const new_test_step = b.step(test_command, description);
    new_test_step.dependOn(&run_new_test.step);

    return new_test_step;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zig-nicetime", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");

    const array_step = try addTest(b, target, optimize, "array");
    test_step.dependOn(array_step);

    const transform_step = try addTest(b, target, optimize, "transform");
    transform_step.dependOn(array_step);
    test_step.dependOn(transform_step);

    const name_step = try addTest(b, target, optimize, "name");
    test_step.dependOn(name_step);

    const print_step = try addTest(b, target, optimize, "print");
    test_step.dependOn(print_step);

    const generate_step = try addTest(b, target, optimize, "generate");
    test_step.dependOn(generate_step);
}
