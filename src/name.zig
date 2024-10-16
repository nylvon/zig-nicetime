///////////////////////////////////////////////////////////////////////////////////
/// Compile-time naming utilities
///////////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

// The functions used to name fields must share this signature.
pub const ComptimeFieldNameFunction = *const fn (comptime type, comptime usize) [:0]const u8;

/// Example naming functions

// Returned string format:
//  :   "field_" + index + "_" + @typeName(T)
// Eg: For index = 3, T = i32, the string will be "field_3_i32"
// NOTE: The snake case refers only to the inermediary string portions.
//       "field_XYZ_ABC" is "snake case" in this case, regardless of what "XYZ" or "ABC" is.
pub fn ExplicitSnakeCaseNamer(comptime T: type, comptime index: usize) [:0]const u8 {
    return std.fmt.comptimePrint("field_{d}_{s}", .{ index, @typeName(T) });
}

// Returned string format:
//  :   @typeName(T)
// Eg: For index = 3, T = i32, the string will be "i32"
// NOTE: The index is discarded, but kept for compatibility.
pub fn DirectTypeNamer(comptime T: type, comptime index: usize) [:0]const u8 {
    _ = index;
    return std.fmt.comptimePrint("{s}", .{@typeName(T)});
}

// Returned string format:
//  :   index
// Eg: For index = 3, T = i32, the string will be "3"
// NOTE: The type is discarded, but kept for compatibility.
pub fn DirectIndexNamer(comptime T: type, comptime index: usize) [:0]const u8 {
    _ = T;
    return std.fmt.comptimePrint("{d}", .{index});
}

/// Testing zone

// Used for testing naming functions
pub fn testNamer(comptime namer: ComptimeFieldNameFunction, comptime T: type, comptime index: usize, comptime expected_string: [:0]const u8) !void {
    // The generated string for this case
    const generated_string = comptime namer(T, index);

    // They should be the same length
    try expect(generated_string.len == expected_string.len);

    // Check each character in particular.
    inline for (0..generated_string.len) |i| {
        try expect(generated_string[i] == expected_string[i]);
    }
}

test "ExplicitSnakeCaseNamer" {
    try testNamer(ExplicitSnakeCaseNamer, i32, 0, "field_0_i32");
    try testNamer(ExplicitSnakeCaseNamer, i64, 1, "field_1_i64");
    try testNamer(ExplicitSnakeCaseNamer, []const u8, 2, "field_2_[]const u8");
}

test "DirectTypeNamer" {
    try testNamer(DirectTypeNamer, i32, 0, "i32");
    try testNamer(DirectTypeNamer, i64, 1, "i64");
    try testNamer(DirectTypeNamer, []const u8, 2, "[]const u8");
}

test "DirectIndexNamer" {
    try testNamer(DirectIndexNamer, i32, 0, "0");
    try testNamer(DirectIndexNamer, i64, 1, "1");
    try testNamer(DirectIndexNamer, []const u8, 2, "2");
}
