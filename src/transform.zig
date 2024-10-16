///////////////////////////////////////////////////////////////////////////////////
/// Type transformation utilities
///////////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const array = @import("array.zig");
const ComptimeArrayAppend = array.ComptimeArrayAppend;
const ComptimeArrayMerge = array.ComptimeArrayMerge;

// A mapping between one set of types to another set of types.
pub const TypeTransformFunction = fn (comptime type) type;

/// Example type transformation functions

// Converts T into ?T
pub fn ToOptional(comptime T: type) type {
    return ?T;
}

// Converts T into *T
pub fn ToPointer(comptime T: type) type {
    return *T;
}

// Converts T into *const T
pub fn ToConstantPointer(comptime T: type) type {
    return *const T;
}

// Transforms an array of types using a transformation function
// The transformation function is applied to every type, in order.
// The size of the returned array is the same as the parameter array.
pub fn FlatTransform(comptime types: []const type, comptime transform: TypeTransformFunction) []const type {
    comptime {
        var newTypes: [types.len]type = undefined;

        for (types, 0..) |T, i| {
            newTypes[i] = transform(T);
        }

        const constNewTypes = newTypes;
        return &constNewTypes;
    }
}

test "FlatTransform" {
    const exampleTypes = &[_]type{ i32, *i64, ?[]const u8 };
    const expectedTypes = &[_]type{ *i32, **i64, *?[]const u8 };
    const generatedTypes = FlatTransform(exampleTypes, ToPointer);

    try expect(generatedTypes.len == expectedTypes.len);

    inline for (0..generatedTypes.len) |i| {
        try expect(generatedTypes[i] == expectedTypes[i]);
    }
}

/// Example flat transforms.

// Converts an array of types to an array of optionals.
pub fn ToOptionals(comptime types: []const type) []const type {
    return FlatTransform(types, ToOptional);
}

// Converts an array of types to an array of pointers.
pub fn ToPointers(comptime types: []const type) []const type {
    return FlatTransform(types, ToPointer);
}

// Converts an array of types to an array of constant pointers.
pub fn ToConstantPointers(comptime types: []const type) []const type {
    return FlatTransform(types, ToConstantPointers);
}

/// Returns a duplicate-less version of the parameter type array.
pub fn Reduce(comptime types: []const type) []const type {
    comptime {
        if (types.len == 0) return types;

        // Guaranteed to have at least one element.
        var reducedTypes: []const type = &[1]type{types[0]};

        for (types) |maybeNewType| {
            // Initially assume it's not a duplicate.
            var found = false;
            // Check if it's a duplicate
            for (reducedTypes) |oldType| {
                if (maybeNewType == oldType) {
                    found = true;
                    break;
                }
            }

            // If it was not a duplicate, add it to the 'reduced_types' array.
            if (!found) {
                reducedTypes = ComptimeArrayAppend(type, reducedTypes, maybeNewType);
            }
        }

        const constReducedTypes = reducedTypes;
        return constReducedTypes;
    }
}

test "ReduceTypeArray" {
    // An example array with multiple entries that are the same
    const redundant_array = [_]type{ i32, i32, i32, f32, f32 };
    // The same array, but without the redundant entries
    const expected_array = [_]type{ i32, f32 };
    // The one with its redundancy hopefully removed
    const generated_array = Reduce(&redundant_array);

    // They should be the same length
    try expect(generated_array.len == expected_array.len);

    // Check for each in particular.
    inline for (expected_array, 0..) |expected_type, i| {
        try expect(expected_type == generated_array[i]);
    }
}
