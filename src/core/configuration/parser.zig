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

const Formatter = @import("Formatter.zig");
const Result = struct {
    allocator: ?std.mem.Allocator,
    source: std.ArrayList(u8),
    json: std.json.Parsed([]Formatter),

    const empty = Result{
        .allocator = null,
        .source = .empty,
        .json = .{
            .allocator = undefined,
            .value = &.{},
        },
    };

    pub fn formatters(self: Result) []const Formatter {
        return self.json.value;
    }

    pub fn deinit(self: *Result) void {
        const allocator = self.allocator orelse return;
        self.source.deinit(allocator);
        self.json.deinit();
    }
};
const std = @import("std");

pub fn parseFile(allocator: std.mem.Allocator, io: std.Io, file: std.Io.File) !Result {
    var source = std.ArrayList(u8).empty;
    var file_reader = file.reader(io, &.{});
    const reader = &file_reader.interface;
    try reader.appendRemaining(allocator, &source, .unlimited);
    return try parseSource(allocator, source);
}

fn parseSource(
    allocator: std.mem.Allocator,
    source: std.ArrayList(u8),
) !Result {
    return .{
        .allocator = allocator,
        .source = source,
        .json = try std.json.parseFromSlice(
            []Formatter,
            allocator,
            source.items,
            .{},
        ),
    };
}

test parseSource {
    omitting_exclusions: {
        var result = try parseSource(std.testing.allocator,
            \\{
            \\  {
            \\    "identifier": "zig",
            \\    "arguments": ["zig", "fmt", "."],
            \\    "extensions": [".zig", ".zon"]
            \\ }
            \\}
        );
        defer result.deinit();
        std.testing.expectEquals(
            &.{
                .{
                    .identifier = "zig",
                    .arguments = &.{ "zig", "fmt", "." },
                    .extensions = &.{ ".zig", ".zon" },
                },
            },
            result.formatters(),
        );
        break :omitting_exclusions;
    }
    specifying_exclusions: {
        var result = try parseSource(std.testing.allocator,
            \\{
            \\  {
            \\    "identifier": "zig",
            \\    "arguments": ["zig", "fmt", "."],
            \\    "extensions": [".zig", ".zon"],
            \\    "exclusions": ["src/main.zig"]
            \\ }
            \\}
        );
        defer result.deinit();
        std.testing.expectEquals(
            &.{
                .{
                    .identifier = "zig",
                    .arguments = &.{ "zig", "fmt", "." },
                    .extensions = &.{ ".zig", ".zon" },
                    .exclusions = &.{"src/main.zig"},
                },
            },
            result.formatters(),
        );
        break :specifying_exclusions;
    }
}
