const std = @import("std");
const stdout = std.io.getStdOut().writer();

fn createFile(path: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{ .read = true });
    defer file.close();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1 and args[1].len != 0) {
        try stdout.print("{s}\n", .{args[1]});
        try createFile(args[1]);
    } else {
        try stdout.print("usage: touch [path-to-file]\n", .{});
    }
}

