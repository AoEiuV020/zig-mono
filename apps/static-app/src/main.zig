const std = @import("std");
const common = @import("common");
const mathlib = @import("mathlib");
const stringlib = @import("stringlib");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 创建 logger
    const logger = common.Logger.init(allocator, "StaticApp");
    logger.log("应用启动 (静态链接)");

    // 使用 mathlib
    const calc = mathlib.Calculator.init(allocator);
    const sum = calc.add(10, 20);
    const product = calc.multiply(5, 7);
    const factorial_result = calc.factorial(5);
    const max_num = calc.maxOfThree(15, 8, 23);

    // 使用 stringlib
    const processor = stringlib.StringProcessor.init(allocator);
    const reversed = try processor.reverse("Hello World");
    defer allocator.free(reversed);

    const parts = [_][]const u8{ "Zig", "Mono", "Project" };
    const concatenated = try processor.concat(" - ", &parts);
    defer allocator.free(concatenated);

    const upper_case = try processor.toUpperCaseWithLog("zigLang");
    defer allocator.free(upper_case);

    const word_count = processor.countWords("This is a test string");

    // 输出结果摘要
    std.debug.print("\n========== 计算结果摘要 ==========\n", .{});
    std.debug.print("加法结果: {d}\n", .{sum});
    std.debug.print("乘法结果: {d}\n", .{product});
    std.debug.print("阶乘结果: {d}\n", .{factorial_result});
    std.debug.print("最大值: {d}\n", .{max_num});
    std.debug.print("反转字符串: {s}\n", .{reversed});
    std.debug.print("连接字符串: {s}\n", .{concatenated});
    std.debug.print("大写字符串: {s}\n", .{upper_case});
    std.debug.print("单词数: {d}\n", .{word_count});
    std.debug.print("==================================\n", .{});

    logger.log("应用结束");
}
