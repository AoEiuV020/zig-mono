const std = @import("std");
const common = @import("common");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// Logger实例映射
var logger_map = std.AutoHashMap(u32, common.Logger).init(allocator);
var next_logger_id: u32 = 1;

// 导出的C函数
export fn common_logger_new(prefix: [*:0]const u8) u32 {
    const prefix_slice = std.mem.span(prefix);
    const prefix_copy = allocator.dupe(u8, prefix_slice) catch return 0;
    
    const logger = common.Logger.init(allocator, prefix_copy);
    const id = next_logger_id;
    next_logger_id += 1;
    
    logger_map.put(id, logger) catch return 0;
    return id;
}

export fn common_logger_log(logger_id: u32, message: [*:0]const u8) void {
    const logger = logger_map.get(logger_id) orelse return;
    const message_slice = std.mem.span(message);
    logger.log(message_slice);
}

export fn common_logger_free(logger_id: u32) void {
    if (logger_map.fetchRemove(logger_id)) |entry| {
        allocator.free(entry.value.prefix);
    }
}

export fn common_to_upper_case(input: [*:0]const u8, output: [*]u8, output_len: usize) void {
    const input_slice = std.mem.span(input);
    const len = @min(input_slice.len, output_len - 1);
    
    for (input_slice[0..len], 0..) |c, i| {
        output[i] = std.ascii.toUpper(c);
    }
    output[len] = 0; // null terminator
}

export fn common_max(a: i32, b: i32) i32 {
    return common.max(a, b);
}

export fn common_min(a: i32, b: i32) i32 {
    return common.min(a, b);
}
