const std = @import("std");

// Common库C接口声明
extern fn common_logger_new(prefix: [*:0]const u8) u32;
extern fn common_logger_log(logger_id: u32, message: [*:0]const u8) void;
extern fn common_logger_free(logger_id: u32) void;

// MathLib库C接口声明
extern fn mathlib_calculator_new() u32;
extern fn mathlib_calculator_add(calculator_id: u32, a: i32, b: i32) i32;
extern fn mathlib_calculator_multiply(calculator_id: u32, a: i32, b: i32) i32;
extern fn mathlib_calculator_factorial(calculator_id: u32, n: i32) i32;
extern fn mathlib_calculator_max_of_three(calculator_id: u32, a: i32, b: i32, c: i32) i32;
extern fn mathlib_calculator_free(calculator_id: u32) void;

// StringLib库C接口声明
extern fn stringlib_processor_new() u32;
extern fn stringlib_processor_reverse(processor_id: u32, input: [*:0]const u8, output: [*]u8, output_len: usize) void;
extern fn stringlib_processor_concat(processor_id: u32, separator: [*:0]const u8, parts: [*]const [*:0]const u8, parts_count: usize, output: [*]u8, output_len: usize) void;
extern fn stringlib_processor_to_upper_case(processor_id: u32, input: [*:0]const u8, output: [*]u8, output_len: usize) void;
extern fn stringlib_processor_count_words(processor_id: u32, input: [*:0]const u8) i32;
extern fn stringlib_processor_free(processor_id: u32) void;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    _ = gpa.allocator();

    // 创建 logger
    const logger_id = common_logger_new("DynamicApp");
    defer common_logger_free(logger_id);
    common_logger_log(logger_id, "应用启动 (动态链接)");

    // 使用 mathlib
    const calc_id = mathlib_calculator_new();
    defer mathlib_calculator_free(calc_id);

    const sum = mathlib_calculator_add(calc_id, 10, 20);
    const product = mathlib_calculator_multiply(calc_id, 5, 7);
    const factorial_result = mathlib_calculator_factorial(calc_id, 5);
    const max_num = mathlib_calculator_max_of_three(calc_id, 15, 8, 23);

    // 使用 stringlib
    const proc_id = stringlib_processor_new();
    defer stringlib_processor_free(proc_id);

    var reversed_buf: [256]u8 = undefined;
    stringlib_processor_reverse(proc_id, "Hello World", &reversed_buf, reversed_buf.len);
    const reversed = std.mem.sliceTo(&reversed_buf, 0);

    var concat_buf: [256]u8 = undefined;
    const parts = [_][*:0]const u8{ "Zig", "Mono", "Project" };
    stringlib_processor_concat(proc_id, " - ", &parts, parts.len, &concat_buf, concat_buf.len);
    const concatenated = std.mem.sliceTo(&concat_buf, 0);

    var upper_buf: [256]u8 = undefined;
    stringlib_processor_to_upper_case(proc_id, "zigLang", &upper_buf, upper_buf.len);
    const upper_case = std.mem.sliceTo(&upper_buf, 0);

    const word_count = stringlib_processor_count_words(proc_id, "This is a test string");

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

    common_logger_log(logger_id, "应用结束");
}
