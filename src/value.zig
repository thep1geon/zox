const std = @import("std");
const Vm = @import("Vm.zig");
const InterpretError = Vm.InterpretError;

pub const Value = union(enum) {
    number: f64,

    pub fn add(value: *const Value, other: *const Value) !Value {
        return switch (value.*) {
            .number => |a| switch (other.*) {
                .number => |b| return .{ .number = a + b },
                // else => InterpretError.Runtime,
            },
            // else => InterpretError.Runtime,
        };
    }

    pub fn sub(value: *const Value, other: *const Value) !Value {
        return switch (value.*) {
            .number => |a| switch (other.*) {
                .number => |b| return .{ .number = a - b },
                // else => InterpretError.Runtime,
            },
            // else => InterpretError.Runtime,
        };
    }

    pub fn mult(value: *const Value, other: *const Value) !Value {
        return switch (value.*) {
            .number => |a| switch (other.*) {
                .number => |b| return .{ .number = a * b },
                // else => InterpretError.Runtime,
            },
            // else => InterpretError.Runtime,
        };
    }

    pub fn div(value: *const Value, other: *const Value) !Value {
        return switch (value.*) {
            .number => |a| switch (other.*) {
                .number => |b| return .{ .number = a / b },
                // else => InterpretError.Runtime,
            },
            // else => InterpretError.Runtime,
        };
    }

    pub fn print(value: *const Value) void {
        switch (value.*) {
            .number => |n| std.debug.print("{d}", .{n}),
        }
    }
};
