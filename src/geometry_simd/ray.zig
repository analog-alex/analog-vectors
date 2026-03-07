// @analogAlex
const std = @import("std");
const vec4 = @import("../vectors/vec4.zig");
const conversions = @import("conversions.zig");

pub const Vec4 = vec4.Vec4;

pub const Ray = struct {
    origin: Vec4, // w=1 (point)
    direction: Vec4, // w=0 (direction), normalized
};

/// Create a ray from origin point and direction, normalizing the direction.
/// The w components are set automatically (origin w=1, direction w=0).
pub fn from(origin: Vec4, direction: Vec4) Ray {
    // Zero out w before normalizing, then ensure w stays 0
    const dir_no_w = Vec4{ direction[0], direction[1], direction[2], 0 };
    const normalized = vec4.normalize(dir_no_w);
    return .{
        .origin = Vec4{ origin[0], origin[1], origin[2], 1 },
        .direction = Vec4{ normalized[0], normalized[1], normalized[2], 0 },
    };
}

/// Create a ray from an already-normalized direction. No normalization is performed.
pub fn fromRaw(origin: Vec4, normalized_direction: Vec4) Ray {
    return .{
        .origin = Vec4{ origin[0], origin[1], origin[2], 1 },
        .direction = Vec4{ normalized_direction[0], normalized_direction[1], normalized_direction[2], 0 },
    };
}

/// Returns the point along the ray at parameter t.
pub inline fn pointAt(r: Ray, t: f32) Vec4 {
    return r.origin + r.direction * @as(Vec4, @splat(t));
}

// ===============
// Tests

test "from - normalizes direction and sets w components" {
    // given
    const origin = vec4.init(1, 2, 3, 0);
    const dir = vec4.init(2, 0, 0, 0);

    // when
    const r = from(origin, dir);

    // then
    try std.testing.expect(vec4.approxEqual(r.direction, vec4.init(1, 0, 0, 0), 0.0001));
    try std.testing.expect(r.origin[3] == 1); // w=1 for point
    try std.testing.expect(r.direction[3] == 0); // w=0 for direction
}

test "pointAt - returns point along ray" {
    // given
    const r = from(vec4.init(1, 2, 3, 1), vec4.init(1, 0, 0, 0));

    // when
    const p = pointAt(r, 5);

    // then
    try std.testing.expect(vec4.approxEqual(p, vec4.init(6, 2, 3, 1), 0.0001));
}

test "pointAt - t=0 returns origin" {
    // given
    const r = from(vec4.init(3, 4, 5, 1), vec4.init(0, 1, 0, 0));

    // when
    const p = pointAt(r, 0);

    // then
    try std.testing.expect(vec4.approxEqual(p, vec4.init(3, 4, 5, 1), 0.0001));
}

test "from - diagonal direction is normalized" {
    // given
    const origin = vec4.init(0, 0, 0, 1);
    const dir = vec4.init(1, 1, 1, 0);

    // when
    const r = from(origin, dir);

    // then
    const len = @sqrt(r.direction[0] * r.direction[0] + r.direction[1] * r.direction[1] + r.direction[2] * r.direction[2]);
    try std.testing.expect(@abs(len - 1.0) < 0.0001);
}

test "from - zero direction remains zero direction with w=0" {
    // given
    const origin = vec4.init(1, 2, 3, 0);

    // when
    const r = from(origin, vec4.zero());

    // then
    try std.testing.expect(vec4.equal(r.origin, vec4.init(1, 2, 3, 1)));
    try std.testing.expect(vec4.equal(r.direction, vec4.zero()));
}
