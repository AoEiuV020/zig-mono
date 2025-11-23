const std = @import("std");
const mathlib = @import("mathlib");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// Calculator实例映射
var calculator_map = std.AutoHashMap(u32, mathlib.Calculator).init(allocator);
var next_calculator_id: u32 = 1;

// 导出的C函数
export fn mathlib_calculator_new() u32 {
    const calculator = mathlib.Calculator.init(allocator);
    const id = next_calculator_id;
    next_calculator_id += 1;
    
    calculator_map.put(id, calculator) catch return 0;
    return id;
}

export fn mathlib_calculator_add(calculator_id: u32, a: i32, b: i32) i32 {
    const calculator = calculator_map.get(calculator_id) orelse return 0;
    return calculator.add(a, b);
}

export fn mathlib_calculator_multiply(calculator_id: u32, a: i32, b: i32) i32 {
    const calculator = calculator_map.get(calculator_id) orelse return 0;
    return calculator.multiply(a, b);
}

export fn mathlib_calculator_factorial(calculator_id: u32, n: i32) i32 {
    const calculator = calculator_map.get(calculator_id) orelse return 0;
    return calculator.factorial(n);
}

export fn mathlib_calculator_max_of_three(calculator_id: u32, a: i32, b: i32, c: i32) i32 {
    const calculator = calculator_map.get(calculator_id) orelse return 0;
    return calculator.maxOfThree(a, b, c);
}

export fn mathlib_calculator_free(calculator_id: u32) void {
    if (calculator_map.fetchRemove(calculator_id)) |entry| {
        _ = entry;
        // Calculator不需要特别的清理
    }
}
