const std = @import("std");
const Chunk = @import("Chunk.zig");
const OpCode = Chunk.OpCode;
const Value = @import("value.zig").Value;

pub fn disassembleChunk(chunk: *const Chunk, name: []const u8) void {
    std.debug.print("== {s} ==\n", .{name});

    var offset: u32 = 0;
    while (offset < chunk.code.items.len) {
        offset = disassembleInstruction(chunk, offset);
    }

    return;
}

pub fn disassembleInstruction(chunk: *const Chunk, offset: u32) u32 {
    std.debug.print("{d:0>4} ", .{offset});

    if (offset > 0 and chunk.lines.items[offset] == chunk.lines.items[offset - 1]) {
        std.debug.print("   | ", .{});
    } else {
        std.debug.print("{d: >4} ", .{chunk.lines.items[offset]});
    }

    const opcode: OpCode = @enumFromInt(chunk.code.items[offset]);
    switch (opcode) {
        .ret => return simpleInstruction("RET", offset),
        .negate => return simpleInstruction("NEGATE", offset),
        .add => return simpleInstruction("ADD", offset),
        .sub => return simpleInstruction("SUB", offset),
        .div => return simpleInstruction("DIV", offset),
        .mult => return simpleInstruction("MULT", offset),
        .constant => return constantInstruction(chunk, "CONSTANT", offset),
        else => {
            std.debug.print("UNKNOWN INSTRUCTION {d}\n", .{chunk.code.items[offset]});
            return offset + 1;
        },
    }
}

fn simpleInstruction(name: []const u8, offset: u32) u32 {
    std.debug.print("{s}\n", .{name});
    return offset + 1;
}

fn constantInstruction(chunk: *const Chunk, name: []const u8, offset: u32) u32 {
    const constant = chunk.code.items[offset + 1];
    const value = chunk.constants.items[constant];
    std.debug.print("{s: <16} {d: >4} '", .{ name, constant });
    value.print();
    std.debug.print("'\n", .{});
    return offset + 2;
}
