///////////////////////////////////////////////////////////////////////////////////
/// Compile-time printing utilities
///////////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

/// Merges multiple lines into one, adding a predefined space before each new line character.
pub fn SpacedPrint(comptime spaces: usize, comptime lines: []const [:0]const u8) [:0]const u8 {
    comptime {
        var collapsed: [:0]const u8 = "";
        for (lines) |line| {
            collapsed = std.fmt.comptimePrint("{s}", .{collapsed});
            for (0..spaces) |i| {
                _ = i;
                collapsed = std.fmt.comptimePrint("{s} ", .{collapsed});
            }
            collapsed = std.fmt.comptimePrint("{s}{s}\n", .{ collapsed, line });
        }

        const const_collapsed = collapsed;
        return const_collapsed;
    }
}

/// Testing zone

// Calls SpacedPrint, verifies that the results are correct
pub fn testSpacedPrint(comptime spaces: usize, comptime lines: []const [:0]const u8, comptime expected_string: [:0]const u8) !void {
    // The generated string for this case
    const generated_string = comptime SpacedPrint(spaces, lines);

    // They should be the same length
    try expect(generated_string.len == expected_string.len);

    // Check for each in particular.
    inline for (0..generated_string.len) |i| {
        try expect(generated_string[i] == expected_string[i]);
    }
}

test "SpacedPrint" {
    try testSpacedPrint(0, &[_][:0]const u8{ "ABC", "DEF", "XYZ" }, "ABC\nDEF\nXYZ\n");
    try testSpacedPrint(1, &[_][:0]const u8{ "ABC", "DEF", "XYZ" }, " ABC\n DEF\n XYZ\n");
    try testSpacedPrint(2, &[_][:0]const u8{ "ABC", "DEF", "XYZ" }, "  ABC\n  DEF\n  XYZ\n");
    try testSpacedPrint(3, &[_][:0]const u8{ "ABC", "DEF", "XYZ" }, "   ABC\n   DEF\n   XYZ\n");
    try testSpacedPrint(4, &[_][:0]const u8{ "ABC", "DEF", "XYZ" }, "    ABC\n    DEF\n    XYZ\n");
}
