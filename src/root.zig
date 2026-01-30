//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

// Export vec2 module for library consumers
pub const vec2 = @import("vectors/vec2.zig");

// Export vec3 module for library consumers
pub const vec3 = @import("vectors/vec3.zig");

test {
    std.testing.refAllDecls(@This());
}

test "vec2 module is accessible" {
    const v: vec2.Vec2 = vec2.from(3, 4);
    try std.testing.expect(vec2.length(v) == 5);
}

test "vec3 module is accessible" {
    const v: vec3.Vec3 = vec3.from(2, 3, 6);
    try std.testing.expect(vec3.length(v) == 7);
}
