const std = @import("std");
const Chunk = @import("Chunk.zig");
const OpCode = Chunk.OpCode;
const debug = @import("debug.zig");
const Value = @import("value.zig").Value;
const Vm = @import("Vm.zig");

pub const ZoxError = error{
    Compile,

    Runtime,
    StackOverflow,
    StackUnderflow,
};

const stdin = std.io.getStdIn();

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub var vm = Vm.init();

pub fn init() void {
    vm.debug_trace_execution = true;
}

pub fn deinit() void {
    vm.deinit();

    if (gpa.deinit() != .ok) {
        _ = gpa.detectLeaks();
    }
}

pub fn repl() !void {
    const BUFFER_SIZE = 1024;
    var line: [BUFFER_SIZE]u8 = undefined;

    while (true) {
        std.debug.print("zox> ", .{});

        const len = try stdin.read(&line);
        if (len == 0) {
            std.debug.print("\n", .{});
            break;
        }

        if (len == BUFFER_SIZE) {
            std.debug.print("input too long", .{});
            std.debug.print("\n", .{});
            break;
        }

        try vm.interpret(line[0..len]);
    }

    return;
}

pub fn file(filename: []const u8) !void {
    const src = try std.fs.cwd().readFileAlloc(allocator, filename, 1024 * 1024);
    defer allocator.free(src);
    return vm.interpret(src);
}
