// Copyright © Jean Silva
//
// This file is part of the autofmt open-source project.
//
// autofmt is free software: you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// autofmt is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see https://www.gnu.org/licenses.

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
        try filterNotBlank(std.testing.allocator, &.{ "", ":)", " ", "  " });
    defer non_blank.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices([]const u8, &.{":)"}, non_blank.items);
}
