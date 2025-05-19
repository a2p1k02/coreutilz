const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Flags = struct {
    recursive: bool,
    path: []const u8,
};

fn removeFile(path: []const u8) !void {
    try std.fs.cwd().deleteFile(path);
}

fn removeDir(path: []const u8) !void {
    try std.fs.cwd().deleteTree(path);
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();

    var flags = Flags {
        .recursive = false,
        .path = "",
    };
 
    while (args.next()) |arg| {
        for (arg[1..]) |flag| {
            if (std.mem.startsWith(u8, arg, "-")) {
                switch (flag) {
                    'r' => flags.recursive = true,
                    else => {}
                } 
            }
        }
        flags.path = arg;
    }
    
    if (flags.path.len != 0) {
        if (flags.recursive) {
            try removeDir(flags.path);
        } else {
            try removeFile(flags.path);
        }
    } else {
        try stdout.print("usage: rm [-r] [file/dir]\n", .{});
    }
}

