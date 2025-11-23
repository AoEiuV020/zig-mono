const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 获取common模块依赖
    const common_dep = b.dependency("common", .{
        .target = target,
        .optimize = optimize,
    });
    const common_module = common_dep.module("common");

    // 创建stringlib模块
    const stringlib_module = b.addModule("stringlib", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    stringlib_module.addImport("common", common_module);

    // 创建动态库
    const lib = b.addSharedLibrary(.{
        .name = "stringlib",
        .root_source_file = b.path("src/cshared.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("stringlib", stringlib_module);
    lib.root_module.addImport("common", common_module);
    b.installArtifact(lib);

    // 创建静态库
    const static_lib = b.addStaticLibrary(.{
        .name = "stringlib",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    static_lib.root_module.addImport("common", common_module);
    b.installArtifact(static_lib);
}
