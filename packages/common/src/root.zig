const std = @import("std");

pub const Logger = struct {
    prefix: []const u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, prefix: []const u8) Logger {
        return Logger{
            .prefix = prefix,
            .allocator = allocator,
        };
    }

    pub fn log(self: Logger, message: []const u8) void {
        const timestamp = self.getCurrentTimestamp();
        defer self.allocator.free(timestamp);
        std.debug.print("[{s}] [{s}] {s}\n", .{ timestamp, self.prefix, message });
    }

    pub fn logFormat(self: Logger, comptime fmt: []const u8, args: anytype) void {
        const message = std.fmt.allocPrint(self.allocator, fmt, args) catch return;
        defer self.allocator.free(message);
        self.log(message);
    }

    fn getCurrentTimestamp(self: Logger) []u8 {
        const timestamp = std.time.timestamp();
        const epoch = @as(i64, @intCast(timestamp));
        
        // 简化的时间格式化（只显示时分秒）
        const seconds_today = @mod(epoch, 86400);
        
        const hours = @divFloor(seconds_today, 3600);
        const minutes = @divFloor(@mod(seconds_today, 3600), 60);
        const seconds = @mod(seconds_today, 60);
        
        const result = std.fmt.allocPrint(
            self.allocator,
            "2025-11-23 {d:0>2}:{d:0>2}:{d:0>2}",
            .{ hours, minutes, seconds }
        ) catch return self.allocator.dupe(u8, "2025-11-23 00:00:00") catch unreachable;
        
        return result;
    }
};

pub fn toUpperCase(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    var result = try allocator.alloc(u8, s.len);
    for (s, 0..) |c, i| {
        result[i] = std.ascii.toUpper(c);
    }
    return result;
}

pub fn max(a: i32, b: i32) i32 {
    return if (a > b) a else b;
}

pub fn min(a: i32, b: i32) i32 {
    return if (a < b) a else b;
}
