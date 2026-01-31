//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

// Export vec2 module for library consumers
pub const vec2 = @import("vectors/vec2.zig");

// Export vec3 module for library consumers
pub const vec3 = @import("vectors/vec3.zig");

// Export vec4 module for library consumers
pub const vec4 = @import("vectors/vec4.zig");

// Export mat2 module for library consumers
pub const mat2 = @import("vectors/mat2.zig");

// Export mat3 module for library consumers
pub const mat3 = @import("vectors/mat3.zig");

// Export mat4 module for library consumers
pub const mat4 = @import("vectors/mat4.zig");

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

test "vec4 module is accessible" {
    const v: vec4.Vec4 = vec4.from(2, 2, 1, 0);
    try std.testing.expect(vec4.length(v) == 3);
}

test "mat2 module is accessible" {
    const m: mat2.Mat2 = mat2.identity();
    try std.testing.expect(mat2.determinant(m) == 1);
}

test "mat3 module is accessible" {
    const m: mat3.Mat3 = mat3.identity();
    try std.testing.expect(mat3.determinant(m) == 1);
}

test "mat4 module is accessible" {
    const m: mat4.Mat4 = mat4.identity();
    const v = vec3.from(1, 2, 3);
    const result = mat4.transformVec3(m, v);
    try std.testing.expect(vec3.equal(result, v));
}
