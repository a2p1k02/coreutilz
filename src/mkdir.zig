const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Flags = struct {
    recursive_flag: bool, 
    path: []const u8,
};

fn createDirectory(flags: Flags) !void {
    if (flags.recursive_flag) {
        var splits = std.mem.split(u8, flags.path, "/");
        while (splits.next()) |path| {
            std.fs.cwd().makeDir(path) catch |err| switch (err) {
                error.PathAlreadyExists => {},
                else => {}
            };
            var dir = try std.fs.cwd().openDir(path, .{});
            defer dir.close();
            try dir.setAsCwd();
        }
    } else {
        try std.fs.cwd().makeDir(flags.path);
    }
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();

    var flags = Flags{
        .path = "",
        .recursive_flag = false,
    };

    while (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "-")) {
            for (arg[1..]) |flag| {
                switch (flag) {
                    'p' => flags.recursive_flag = true,
                    else => {}
                }
            } 
        } else {
            flags.path = arg;
        }
    }    
    
    if (flags.path.len != 0) {
        try createDirectory(flags);
    } else {
        try stdout.print("usage: mkdir [-p] [dir(s)]\n", .{});
    }
}

