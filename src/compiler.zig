const std = @import("std");
const zox = @import("zox.zig");
const scanner = @import("scanner.zig");
const Token = scanner.Token;
const Chunk = @import("Chunk.zig");

var current_tok: ?Token = null;
var prev_tok: ?Token = null;

fn advance() void {}
fn expr() void {}
fn consume(kind: Token.Kind, msg: []const u8) void {
    _ = .{ kind, msg };
}

fn isAtEnd() bool {
    return current_tok == null;
}

pub fn compile(src: []const u8) zox.ZoxError!Chunk {
    scanner.init(src);
    defer scanner.deinit();
    advance();
    expr();
    if (!isAtEnd()) return zox.ZoxError.Compile;
    return Chunk.init(zox.allocator);
}
