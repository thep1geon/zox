const std = @import("std");
const Chunk = @import("Chunk.zig");
const OpCode = Chunk.OpCode;
const debug = @import("debug.zig");
const Value = @import("value.zig").Value;
const Vm = @import("Vm.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        if (gpa.deinit() != .ok) {
            _ = gpa.detectLeaks();
        }
    }

    var vm = Vm.init();
    vm.debug_trace_execution = true;
    defer vm.deinit();

    var chunk = Chunk.init(allocator);
    defer chunk.deinit();

    chunk.writeConstant(
        Value{ .number = 1.2 },
        123,
    );

    chunk.writeConstant(
        .{ .number = 3.4 },
        123,
    );

    chunk.writeOpCode(.add, 123);

    chunk.writeConstant(
        .{ .number = 5.6 },
        123,
    );

    chunk.writeOpCode(OpCode.div, 123);
    chunk.writeOpCode(OpCode.negate, 123);
    chunk.writeOpCode(OpCode.ret, 123);

    try vm.interpret(&chunk);
}
