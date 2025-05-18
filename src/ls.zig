const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Flags = struct {
    hidden_files: bool,
    path: []const u8,
};

fn compareStringsDesc(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, b, a) == .gt;
}

fn getFileList(flags: Flags, allocator: std.mem.Allocator) !void {
    var current_dir = try std.fs.cwd().openDir(flags.path, .{ .iterate = true });
    defer current_dir.close();

    var current_dir_iter = current_dir.iterate();

    var files = std.ArrayList([]const u8).init(allocator);
    defer files.deinit();
    
    while (try current_dir_iter.next()) |dir| {
        if (!flags.hidden_files and std.mem.startsWith(u8, dir.name, ".")) {
            continue;
        }
        switch (dir.kind) {
            .file => {
                try files.append(dir.name);
            }, 
            .directory => {
                const dir_name = try std.mem.concat(allocator, u8, &[_][]const u8{ dir.name, "/" });
                try files.append(dir_name);
            },
            else => {}
        }
    }

    std.mem.sort([]const u8, files.items, {}, compareStringsDesc);
    for (files.items) |file| {
        try stdout.print("{s}\n", .{file});
        if (std.mem.endsWith(u8, file, "/")) {
            allocator.free(file);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var args = std.process.args();
    _ = args.skip();
    
    var flags = Flags {
        .hidden_files = false,
        .path = "./"
    };

    while (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "-")) {
            for (arg[1..]) |flag| {
                switch (flag) {
                    'l' => flags.hidden_files = true,
                    else => {}
                }
            }
        } else {
            flags.path = arg;
        }
    }

    try getFileList(flags, allocator);
}

