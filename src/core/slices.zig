const std = @import("std");
const strings = @import("configuration/root.zig").strings;

pub fn filterNotBlank(
    allocator: std.mem.Allocator,
    self: []const []const u8,
) error{OutOfMemory}!std.ArrayList([]const u8) {
    if (self.len == 0)
        return .empty;
    var non_blank =
        try std.ArrayList([]const u8).initCapacity(allocator, self.len);
    for (self) |string| {
        if (strings.isBlank(string))
            continue;
        try non_blank.append(allocator, string);
    }
    return non_blank;
}

test filterNotBlank {
    var non_blank =
        try filterNotBlank(std.testing.allocator, &.{"", ":)", " ", "  "});
    defer non_blank.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices([]const u8, &.{":)"}, non_blank.items);
}
