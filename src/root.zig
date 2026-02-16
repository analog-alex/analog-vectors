//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

// Export vec2 module for library consumers
pub const vec2 = @import("vectors/vec2.zig");

// Export vec3 module for library consumers
pub const vec3 = @import("vectors/vec3.zig");

// Export vec4 module for library consumers
pub const vec4 = @import("vectors/vec4.zig");

// Export mat2 module for library consumers
pub const mat2 = @import("matrices/mat2.zig");

// Export mat3 module for library consumers
pub const mat3 = @import("matrices/mat3.zig");

// Export mat4 module for library consumers
pub const mat4 = @import("matrices/mat4.zig");

// Export quat module for library consumers
pub const quat = @import("complex/quat.zig");

// Export utility modules for library consumers
pub const angle = @import("utils/angle.zig");
pub const color = @import("utils/color.zig");
pub const random = @import("utils/random.zig");
pub const constants = @import("utils/constants.zig");
pub const math_utils = @import("utils/math.zig");
pub const easing = @import("utils/easing.zig");
pub const interpolation = @import("utils/interpolation.zig");

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

test "quat module is accessible" {
    const q: quat.Quat = quat.identity();
    const v = vec3.from(1, 2, 3);
    const result = quat.rotateVec(q, v);
    try std.testing.expect(vec3.approxEqual(result, v, 0.0001));
}

test "angle module is accessible" {
    const rad = angle.degToRad(180);
    try std.testing.expectApproxEqAbs(std.math.pi, rad, 0.0001);
}

test "color module is accessible" {
    const red = color.RGB.from(1, 0, 0);
    const hsv = color.rgbToHsv(red);
    try std.testing.expectApproxEqAbs(0.0, hsv.h, 0.01);
}

test "random module is accessible" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();
    const val = random.randomFloat(rng, 0, 10);
    try std.testing.expect(val >= 0 and val <= 10);
}

test "constants module is accessible" {
    const zero = constants.vec2_zero;
    try std.testing.expectEqual(@as(f32, 0), zero[0]);
    try std.testing.expectEqual(@as(f32, 0), zero[1]);
}

test "math_utils module is accessible" {
    const result = math_utils.remap(5, 0, 10, 0, 100);
    try std.testing.expectApproxEqAbs(50.0, result, 0.01);
}

test "easing module is accessible" {
    const val = easing.easeInQuad(0.5);
    try std.testing.expectApproxEqAbs(0.25, val, 0.01);
}

test "interpolation module is accessible" {
    const val = interpolation.smootherstep(0.0, 1.0, 0.5);
    try std.testing.expectApproxEqAbs(0.5, val, 0.01);
}
