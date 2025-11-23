const std = @import("std");
const stringlib = @import("stringlib");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// StringProcessor实例映射
var processor_map = std.AutoHashMap(u32, stringlib.StringProcessor).init(allocator);
var next_processor_id: u32 = 1;

// 导出的C函数
export fn stringlib_processor_new() u32 {
    const processor = stringlib.StringProcessor.init(allocator);
    const id = next_processor_id;
    next_processor_id += 1;
    
    processor_map.put(id, processor) catch return 0;
    return id;
}

export fn stringlib_processor_reverse(processor_id: u32, input: [*:0]const u8, output: [*]u8, output_len: usize) void {
    const processor = processor_map.get(processor_id) orelse return;
    const input_slice = std.mem.span(input);
    
    const result = processor.reverse(input_slice) catch return;
    defer allocator.free(result);
    
    const len = @min(result.len, output_len - 1);
    @memcpy(output[0..len], result[0..len]);
    output[len] = 0; // null terminator
}

export fn stringlib_processor_concat(
    processor_id: u32,
    separator: [*:0]const u8,
    parts: [*]const [*:0]const u8,
    parts_count: usize,
    output: [*]u8,
    output_len: usize
) void {
    const processor = processor_map.get(processor_id) orelse return;
    const separator_slice = std.mem.span(separator);
    
    // 转换parts到slice
    var parts_list = allocator.alloc([]const u8, parts_count) catch return;
    defer allocator.free(parts_list);
    
    for (0..parts_count) |i| {
        parts_list[i] = std.mem.span(parts[i]);
    }
    
    const result = processor.concat(separator_slice, parts_list) catch return;
    defer allocator.free(result);
    
    const len = @min(result.len, output_len - 1);
    @memcpy(output[0..len], result[0..len]);
    output[len] = 0; // null terminator
}

export fn stringlib_processor_to_upper_case(processor_id: u32, input: [*:0]const u8, output: [*]u8, output_len: usize) void {
    const processor = processor_map.get(processor_id) orelse return;
    const input_slice = std.mem.span(input);
    
    const result = processor.toUpperCaseWithLog(input_slice) catch return;
    defer allocator.free(result);
    
    const len = @min(result.len, output_len - 1);
    @memcpy(output[0..len], result[0..len]);
    output[len] = 0; // null terminator
}

export fn stringlib_processor_count_words(processor_id: u32, input: [*:0]const u8) i32 {
    const processor = processor_map.get(processor_id) orelse return 0;
    const input_slice = std.mem.span(input);
    return processor.countWords(input_slice);
}

export fn stringlib_processor_free(processor_id: u32) void {
    if (processor_map.fetchRemove(processor_id)) |entry| {
        _ = entry;
        // StringProcessor不需要特别的清理
    }
}
