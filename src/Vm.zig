const std = @import("std");
const Chunk = @import("Chunk.zig");
const OpCode = Chunk.OpCode;
const Value = @import("value.zig").Value;
const debug = @import("debug.zig");

const Vm = @This();

pub const InterpretError = error{
    Compile,

    Runtime,
    StackOverflow,
    StackUnderflow,
};

const STACK_CAP = 256;

debug_trace_execution: bool = false,
chunk: *const Chunk = undefined,
ip: u32 = 0,
stack: [STACK_CAP]Value = undefined,
sp: u8 = 0,

pub fn init() Vm {
    return Vm{};
}

pub fn deinit(vm: *Vm) void {
    vm.sp = 0;
}

pub fn push(vm: *Vm, value: Value) !void {
    if (vm.sp + 1 == STACK_CAP) return InterpretError.StackOverflow;

    vm.stack[vm.sp] = value;
    vm.sp += 1;
    return;
}

pub fn pop(vm: *Vm) !Value {
    if (vm.sp == 0) return InterpretError.StackUnderflow;

    const value = vm.stack[vm.sp - 1];
    vm.sp -= 1;
    return value;
}

fn readByte(vm: *Vm) u8 {
    const byte = vm.chunk.code.items[vm.ip];
    vm.ip += 1;
    return byte;
}

fn readConstant(vm: *Vm) Value {
    const byte = vm.readByte();
    return vm.chunk.constants.items[byte];
}

fn run(vm: *Vm) InterpretError!void {
    while (vm.ip < vm.chunk.code.items.len) {
        if (vm.debug_trace_execution) {
            if (vm.sp != 0) {
                std.debug.print("            ", .{});
                var sp: u8 = 0;
                while (sp < vm.sp) : (sp += 1) {
                    std.debug.print("[ ", .{});
                    vm.stack[sp].print();
                    std.debug.print(" ]", .{});
                }
                std.debug.print("\n", .{});
            }

            _ = debug.disassembleInstruction(vm.chunk, vm.ip);
        }

        const inst: OpCode = @enumFromInt(vm.readByte());

        blk: {
            switch (inst) {
                .ret => {
                    (try vm.pop()).print();
                    std.debug.print("\n", .{});
                    return;
                },
                .constant => {
                    try vm.push(vm.readConstant());
                    break :blk;
                },
                .negate => {
                    const v = try vm.pop();
                    switch (v) {
                        .number => |n| try vm.push(.{ .number = -n }),
                        // else => try vm.push(v),
                    }
                },
                .add => {
                    const a = try vm.pop();
                    const b = try vm.pop();
                    try vm.push(try b.add(&a));
                },

                .sub => {
                    const a = try vm.pop();
                    const b = try vm.pop();
                    try vm.push(try b.sub(&a));
                },

                .div => {
                    const a = try vm.pop();
                    const b = try vm.pop();
                    try vm.push(try b.div(&a));
                },

                .mult => {
                    const a = try vm.pop();
                    const b = try vm.pop();
                    try vm.push(try b.mult(&a));
                },

                else => {
                    std.debug.print("{any}", .{inst});
                    return InterpretError.Compile;
                },
            }
        }
    }
}

pub fn interpret(vm: *Vm, chunk: *const Chunk) InterpretError!void {
    vm.chunk = chunk;
    vm.ip = 0;
    return vm.run();
}
