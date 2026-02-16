// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3, // should be normalized
};

pub fn from(origin: Vec3, direction: Vec3) Ray {
    return .{ .origin = origin, .direction = vec3.normalize(direction) };
}

pub fn fromRaw(origin: Vec3, normalized_direction: Vec3) Ray {
    return .{ .origin = origin, .direction = normalized_direction };
}

pub inline fn pointAt(r: Ray, t: f32) Vec3 {
    return vec3.sum(r.origin, vec3.mul(r.direction, t));
}

// ===============
// Tests

test "from - normalizes direction" {
    // given
    const origin = vec3.from(0, 0, 0);
    const dir = vec3.from(2, 0, 0);

    // when
    const r = from(origin, dir);

    // then
    try std.testing.expect(vec3.approxEqual(r.direction, vec3.from(1, 0, 0), 0.0001));
}

test "pointAt - returns point along ray" {
    // given
    const r = from(vec3.from(1, 2, 3), vec3.from(1, 0, 0));

    // when
    const p = pointAt(r, 5);

    // then
    try std.testing.expect(vec3.approxEqual(p, vec3.from(6, 2, 3), 0.0001));
}

test "pointAt - t=0 returns origin" {
    // given
    const r = from(vec3.from(3, 4, 5), vec3.from(0, 1, 0));

    // when
    const p = pointAt(r, 0);

    // then
    try std.testing.expect(vec3.approxEqual(p, vec3.from(3, 4, 5), 0.0001));
}
