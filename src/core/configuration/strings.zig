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

const Self = []const u8;
const std = @import("std");

pub fn isBlank(self: Self) bool {
    for (self) |character|
        if (!std.ascii.isWhitespace(character))
            return false;
    return true;
}

pub fn isDelimited(self: Self, prefix: Self, suffix: Self) bool {
    return if (self.len < prefix.len or self.len < suffix.len)
        false
    else
        std.mem.eql(u8, self[0..prefix.len], prefix) and
            std.mem.eql(u8, self[self.len - suffix.len ..], suffix);
}

test isBlank {
    try std.testing.expect(isBlank(""));
    try std.testing.expect(isBlank(" "));
    try std.testing.expect(isBlank("  "));
    try std.testing.expect(!isBlank(" 🫡"));
}

test isDelimited {
    try std.testing.expect(isDelimited("", "", ""));
    try std.testing.expect(isDelimited("-> <-", "", ""));
    try std.testing.expect(isDelimited("-> <-", "->", "<-"));
    try std.testing.expect(!isDelimited("-> ", "->", "<-"));
}
