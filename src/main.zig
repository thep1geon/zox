const std = @import("std");
const zox = @import("zox.zig");

pub fn main() !void {
    zox.init();
    defer zox.deinit();

    const args = try std.process.argsAlloc(zox.allocator);
    defer std.process.argsFree(zox.allocator, args);

    if (args.len == 1) {
        return zox.repl();
    } else if (args.len == 2) {
        return zox.file(args[1]);
    } else {
        std.debug.print("Usage: zox [path]\n", .{});
        std.process.exit(64);
    }
}
