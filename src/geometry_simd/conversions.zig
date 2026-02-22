// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");
const vec4 = @import("../vectors/vec4.zig");

pub const Vec3 = vec3.Vec3;
pub const Vec4 = vec4.Vec4;

/// Convert a Vec3 position to a Vec4 homogeneous point (w=1).
pub inline fn vec3ToPoint(v: Vec3) Vec4 {
    return Vec4{ v[0], v[1], v[2], 1 };
}

/// Convert a Vec3 direction to a Vec4 homogeneous direction (w=0).
pub inline fn vec3ToDir(v: Vec3) Vec4 {
    return Vec4{ v[0], v[1], v[2], 0 };
}

/// Convert a Vec4 back to Vec3 by dropping the w component.
pub inline fn vec4ToVec3(v: Vec4) Vec3 {
    return [3]f32{ v[0], v[1], v[2] };
}

// ===============
// Tests

test "vec3ToPoint - sets w=1" {
    // given
    const v = vec3.init(3, 4, 5);

    // when
    const result = vec3ToPoint(v);

    // then
    try std.testing.expect(vec4.equal(result, vec4.init(3, 4, 5, 1)));
}

test "vec3ToDir - sets w=0" {
    // given
    const v = vec3.init(1, 0, 0);

    // when
    const result = vec3ToDir(v);

    // then
    try std.testing.expect(vec4.equal(result, vec4.init(1, 0, 0, 0)));
}

test "vec4ToVec3 - drops w component" {
    // given
    const v = vec4.init(3, 4, 5, 1);

    // when
    const result = vec4ToVec3(v);

    // then
    try std.testing.expect(vec3.equal(result, vec3.init(3, 4, 5)));
}

test "vec3ToPoint roundtrip - point survives conversion" {
    // given
    const original = vec3.init(7, -2, 13);

    // when
    const v4 = vec3ToPoint(original);
    const back = vec4ToVec3(v4);

    // then
    try std.testing.expect(vec3.equal(back, original));
}

test "vec3ToDir roundtrip - direction survives conversion" {
    // given
    const original = vec3.init(0.577, 0.577, 0.577);

    // when
    const v4 = vec3ToDir(original);
    const back = vec4ToVec3(v4);

    // then
    try std.testing.expect(vec3.approxEqual(back, original, 0.0001));
}

test "vec3ToPoint - zero point" {
    // given
    const v = vec3.zero();

    // when
    const result = vec3ToPoint(v);

    // then
    try std.testing.expect(vec4.equal(result, vec4.init(0, 0, 0, 1)));
}

test "vec3ToDir - zero direction" {
    // given
    const v = vec3.zero();

    // when
    const result = vec3ToDir(v);

    // then
    try std.testing.expect(vec4.equal(result, vec4.zero()));
}
