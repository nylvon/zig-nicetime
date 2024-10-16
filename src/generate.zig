///////////////////////////////////////////////////////////////////////////////////
/// Compile-time data generation utilities
/// A generator is a function that outputs some fixed value(s).
/// This part offers you functions that create these generators automatically.
///////////////////////////////////////////////////////////////////////////////////

const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

// Returns an unary function that does nothing with its argument and just returns.
// If R (the returned type) is not void, R_Value will be returned.
pub fn EmptyFunctionUnary(comptime A: type, comptime R: type, comptime R_Value: ?R) *const fn (A) R {
    comptime if (R == void or R == anyerror!void) {
        return struct {
            pub fn EmptyFunctionVoid(a: A) R {
                _ = a;
                return;
            }
        }.EmptyFunctionVoid;
    } else if (R_Value) |Value| {
        return struct {
            pub fn EmptyFunctionFixed(a: A) R {
                _ = a;
                return Value;
            }
        }.EmptyFunctionFixed;
    } else @compileError("Since 'R' is not void, 'R_Value' should not be null!");
}

// Returns a binary function that does nothing with its arguments and just returns.
// If R (the returned type) is not void, R_Value will be returned.
pub fn EmptyFunctionBinary(comptime A: type, comptime B: type, comptime R: type, comptime R_Value: ?R) *const fn (A, B) R {
    comptime if (R == void or R == anyerror!void) {
        return struct {
            pub fn EmptyFunctionVoid(a: A, b: B) R {
                _ = a;
                _ = b;
                return;
            }
        }.EmptyFunctionVoid;
    } else if (R_Value) |Value| {
        return struct {
            pub fn EmptyFunctionFixed(a: A, b: B) R {
                _ = a;
                _ = b;
                return Value;
            }
        }.EmptyFunctionFixed;
    } else @compileError("Since 'R' is not void, 'R_Value' should not be null!");
}

// Testing zone

test "EmptyFunctionUnary" {
    const fnVoid = comptime EmptyFunctionUnary(i32, void, null);
    try expect(@TypeOf(fnVoid(0)) == void);

    const fnFixed = comptime EmptyFunctionUnary(i32, i32, 123);
    try expect(@TypeOf(fnFixed(0)) == i32);
    try expect(fnFixed(0) == 123);
    try expect(fnFixed(1) == 123);
    try expect(fnFixed(2) == 123);
}

test "EmptyFunctionBinary" {
    const fnVoid = comptime EmptyFunctionBinary(i32, i32, void, null);
    try expect(@TypeOf(fnVoid(0, 0)) == void);

    const fnFixed = comptime EmptyFunctionBinary(i32, i32, i32, 123);
    try expect(@TypeOf(fnFixed(0, 0)) == i32);
    try expect(fnFixed(0, 0) == 123);
    try expect(fnFixed(1, 1) == 123);
    try expect(fnFixed(2, 2) == 123);
}
