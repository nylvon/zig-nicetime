///////////////////////////////////////////////////////////////////////////////////
/// Compile-time array utilities
///////////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

/// Appends one element to an array at compile-time.
/// This actually creates a new array with the old results, plus the new one.
pub fn ComptimeArrayAppend(comptime T: type, comptime target: []const T, comptime add: T) []const T {
    comptime var result = [1]T{undefined} ** (target.len + 1);
    comptime for (target, 0..) |part, i| {
        result[i] = part;
    };
    result[target.len] = add;

    const const_result = result;
    return &const_result;
}

test "ComptimeArrayAppend" {
    // Some example array to be appended to an example integer
    const array_1 = [_]i32{ 10, 20 };
    const example_value: i32 = 30;
    // The expected appended-to array
    const expected_append = [_]i32{ 10, 20, 30 };
    // The generated appended-to array
    const generated_append = comptime ComptimeArrayAppend(i32, &array_1, example_value);

    // They should be the same length
    try expect(generated_append.len == expected_append.len);

    // Check for each in particular.
    inline for (expected_append, 0..) |ExpectedInteger, i| {
        try expect(ExpectedInteger == generated_append[i]);
    }
}

/// Merges two arrays of type T by creating a new array that is equal in size
/// to the sum of their lengths and with the items of the 'target' array, followed by
/// the items of the 'add' array, in the same order they were in their original arrays.
pub fn ComptimeArrayMerge(comptime T: type, comptime target: []const T, comptime add: []const T) []const T {
    comptime var result = [1]T{undefined} ** (target.len + add.len);
    comptime for (target, 0..) |part, i| {
        result[i] = part;
    };
    comptime for (add, 0..) |part, i| {
        result[i + target.len] = part;
    };

    const const_result = result;
    return &const_result;
}

test "ComptimeArrayMerge" {
    // Some example arrays to be merged
    const array_1 = [_]i32{ 10, 20 };
    const array_2 = [_]i32{ 30, 40 };
    // The expected merged array
    const expected_merge = [_]i32{ 10, 20, 30, 40 };
    // The generated merged array
    const generated_merge = comptime ComptimeArrayMerge(i32, &array_1, &array_2);

    // They should be the same length
    try expect(generated_merge.len == expected_merge.len);

    // Check for each in particular.
    inline for (expected_merge, 0..) |ExpectedInteger, i| {
        try expect(ExpectedInteger == generated_merge[i]);
    }
}

/// Returns a string with the type names of every type in the array, separated by a comma and a space.
pub fn ComptimeTypeArrayToString(comptime Types: []const type) []const u8 {
    comptime {
        var text: []const u8 = std.fmt.comptimePrint("{s}", .{@typeName(Types[0])});

        for (1..Types.len) |i| {
            text = std.fmt.comptimePrint("{s}, {s}", .{ text, @typeName(Types[i]) });
        }

        const const_text = text;
        return const_text;
    }
}

test "ComptimeTypeArrayToString" {
    // An example array
    const example_array = [_]type{ i32, f32, []const u8 };
    // The expected output
    const expected_string = "i32, f32, []const u8";
    // The generated one
    const generated_string = comptime ComptimeTypeArrayToString(&example_array);

    // They should be the same length
    try expect(generated_string.len == expected_string.len);

    // Check for each in particular.
    inline for (generated_string, 0..) |ExpectedChar, i| {
        try expect(ExpectedChar == generated_string[i]);
    }
}
