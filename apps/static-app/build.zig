const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 获取依赖模块
    const common_dep = b.dependency("common", .{
        .target = target,
        .optimize = optimize,
    });
    const common_module = common_dep.module("common");

    const mathlib_dep = b.dependency("mathlib", .{
        .target = target,
        .optimize = optimize,
    });
    const mathlib_module = mathlib_dep.module("mathlib");

    const stringlib_dep = b.dependency("stringlib", .{
        .target = target,
        .optimize = optimize,
    });
    const stringlib_module = stringlib_dep.module("stringlib");

    // 创建可执行文件
    const exe = b.addExecutable(.{
        .name = "static-app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "common", .module = common_module },
                .{ .name = "mathlib", .module = mathlib_module },
                .{ .name = "stringlib", .module = stringlib_module },
            },
        }),
    });

    b.installArtifact(exe);

    // 添加运行命令
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
