const std = @import("std");

fn set_executable(b: *std.Build, name: []const u8, path: []const u8) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(path),
        .target = b.graph.host,
    });

    return exe;
}

pub fn build(b: *std.Build) void {
    const exe_ls = set_executable(b, "ls", "src/ls.zig");
    b.installArtifact(exe_ls);

    const exe_touch = set_executable(b, "touch", "src/touch.zig");
    b.installArtifact(exe_touch);
}

