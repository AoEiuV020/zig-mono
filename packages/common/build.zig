const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 创建common模块
    _ = b.addModule("common", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // 创建动态库
    const lib = b.addSharedLibrary(.{
        .name = "common",
        .root_source_file = b.path("src/cshared.zig"),
        .target = target,
        .optimize = optimize,
    });
    const common_module_for_lib = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
    });
    lib.root_module.addImport("common", common_module_for_lib);
    b.installArtifact(lib);

    // 创建静态库用于测试
    const static_lib = b.addStaticLibrary(.{
        .name = "common",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(static_lib);
}
