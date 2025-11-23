const std = @import("std");
const common = @import("common");

pub const StringProcessor = struct {
    logger: common.Logger,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) StringProcessor {
        return StringProcessor{
            .logger = common.Logger.init(allocator, "StringLib"),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *StringProcessor) void {
        self.allocator.free(self.logger.prefix);
    }

    pub fn reverse(self: StringProcessor, s: []const u8) ![]u8 {
        var result = try self.allocator.alloc(u8, s.len);
        var i: usize = 0;
        while (i < s.len) : (i += 1) {
            result[s.len - 1 - i] = s[i];
        }
        self.logger.logFormat("Reverse(\"{s}\") = \"{s}\"", .{ s, result });
        return result;
    }

    pub fn concat(self: StringProcessor, separator: []const u8, parts: []const []const u8) ![]u8 {
        var total_len: usize = 0;
        for (parts) |part| {
            total_len += part.len;
        }
        if (parts.len > 1) {
            total_len += separator.len * (parts.len - 1);
        }

        var result = try self.allocator.alloc(u8, total_len);
        var pos: usize = 0;

        for (parts, 0..) |part, i| {
            @memcpy(result[pos..][0..part.len], part);
            pos += part.len;
            if (i < parts.len - 1) {
                @memcpy(result[pos..][0..separator.len], separator);
                pos += separator.len;
            }
        }

        self.logger.logFormat("Concat with separator \"{s}\": {d} parts", .{ separator, parts.len });
        return result;
    }

    pub fn toUpperCaseWithLog(self: StringProcessor, s: []const u8) ![]u8 {
        const result = try common.toUpperCase(self.allocator, s);
        self.logger.logFormat("ToUpperCase(\"{s}\") = \"{s}\"", .{ s, result });
        return result;
    }

    pub fn countWords(self: StringProcessor, s: []const u8) i32 {
        var count: i32 = 0;
        var in_word = false;

        for (s) |c| {
            const is_space = c == ' ' or c == '\t' or c == '\n' or c == '\r';
            if (!is_space) {
                if (!in_word) {
                    count += 1;
                    in_word = true;
                }
            } else {
                in_word = false;
            }
        }

        self.logger.logFormat("CountWords(\"{s}\") = {d}", .{ s, count });
        return count;
    }
};
