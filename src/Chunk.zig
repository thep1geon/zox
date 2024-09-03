const std = @import("std");
const Value = @import("value.zig").Value;

const Chunk = @This();

pub const OpCode = enum(u8) {
    constant,
    add,
    sub, // Subtract
    mult, // Multiply
    div, // Divide
    negate,
    ret, // Return
    _,

    pub fn asNumber(opcode: OpCode) u8 {
        return @intFromEnum(opcode);
    }
};

constants: std.ArrayList(Value),
code: std.ArrayList(u8),
lines: std.ArrayList(u32),

pub fn init(allocator: std.mem.Allocator) Chunk {
    return .{
        .constants = std.ArrayList(Value).init(allocator),
        .code = std.ArrayList(u8).init(allocator),
        .lines = std.ArrayList(u32).init(allocator),
    };
}

pub fn deinit(self: *Chunk) void {
    self.code.deinit();
    self.constants.deinit();
    self.lines.deinit();
}

pub fn writeOpCode(self: *Chunk, opcode: OpCode, line: u32) void {
    self.code.append(opcode.asNumber()) catch @panic("FAILED TO WRITE OPCODE");
    self.lines.append(line) catch @panic("FAILED TO ADD LINE");
}

pub fn writeByte(self: *Chunk, byte: u8, line: u32) void {
    self.code.append(byte) catch @panic("FAILED TO WRITE BYTE");
    self.lines.append(line) catch @panic("FAILED TO ADD LINE");
}

pub fn addConstant(self: *Chunk, value: Value) u32 {
    self.constants.append(value) catch @panic("FAILED TO ADD CONST");
    return @as(u8, @intCast(self.constants.items.len)) - 1;
}

pub fn writeConstant(self: *Chunk, value: Value, line: u32) void {
    const index = self.addConstant(value);
    self.writeOpCode(.constant, line);
    self.writeByte(@as(u8, @intCast(index)), line);
    self.lines.append(line) catch @panic("FAILED TO ADD LINE");
}
