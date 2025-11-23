const std = @import("std");
const common = @import("common");

pub const Calculator = struct {
    logger: common.Logger,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Calculator {
        return Calculator{
            .logger = common.Logger.init(allocator, "MathLib"),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Calculator) void {
        self.allocator.free(self.logger.prefix);
    }

    pub fn add(self: Calculator, a: i32, b: i32) i32 {
        const result = a + b;
        self.logger.logFormat("Add({d}, {d}) = {d}", .{ a, b, result });
        return result;
    }

    pub fn multiply(self: Calculator, a: i32, b: i32) i32 {
        const result = a * b;
        self.logger.logFormat("Multiply({d}, {d}) = {d}", .{ a, b, result });
        return result;
    }

    pub fn factorial(self: Calculator, n: i32) i32 {
        if (n <= 1) {
            return 1;
        }
        var result: i32 = 1;
        var i: i32 = 2;
        while (i <= n) : (i += 1) {
            result *= i;
        }
        self.logger.logFormat("Factorial({d}) = {d}", .{ n, result });
        return result;
    }

    pub fn maxOfThree(self: Calculator, a: i32, b: i32, c: i32) i32 {
        const result = common.max(common.max(a, b), c);
        self.logger.logFormat("MaxOfThree({d}, {d}, {d}) = {d}", .{ a, b, c, result });
        return result;
    }
};
