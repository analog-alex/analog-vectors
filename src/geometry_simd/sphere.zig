// @analogAlex
const std = @import("std");
const vec4 = @import("../vectors/vec4.zig");

pub const Vec4 = vec4.Vec4;

/// Sphere with Vec4 center (w=1 point) and radius.
pub const Sphere = struct {
    center: Vec4, // w=1 (point)
    radius: f32,
};

pub fn from(c: Vec4, r: f32) Sphere {
    return .{ .center = Vec4{ c[0], c[1], c[2], 1 }, .radius = r };
}

pub inline fn containsPoint(s: Sphere, p: Vec4) bool {
    const diff = s.center - p;
    // Only use xyz for distance (mask out w)
    const xyz = Vec4{ diff[0], diff[1], diff[2], 0 };
    const dist_sq = @reduce(.Add, xyz * xyz);
    return dist_sq <= s.radius * s.radius;
}

pub inline fn overlapsSphere(a: Sphere, b: Sphere) bool {
    const diff = a.center - b.center;
    const xyz = Vec4{ diff[0], diff[1], diff[2], 0 };
    const dist_sq = @reduce(.Add, xyz * xyz);
    const r_sum = a.radius + b.radius;
    return dist_sq <= r_sum * r_sum;
}

pub fn distanceToPoint(s: Sphere, p: Vec4) f32 {
    const diff = s.center - p;
    const xyz = Vec4{ diff[0], diff[1], diff[2], 0 };
    const dist = @sqrt(@reduce(.Add, xyz * xyz));
    return @max(0.0, dist - s.radius);
}

pub fn volume(s: Sphere) f32 {
    return (4.0 / 3.0) * std.math.pi * s.radius * s.radius * s.radius;
}

pub fn surfaceArea(s: Sphere) f32 {
    return 4.0 * std.math.pi * s.radius * s.radius;
}

// ===============
// Tests

test "from - creates sphere with w=1 center" {
    // given / when
    const s = from(vec4.init(1, 2, 3, 0), 5);

    // then
    try std.testing.expect(s.center[3] == 1);
    try std.testing.expect(s.radius == 5);
}

test "containsPoint - true when inside" {
    // given
    const s = from(vec4.init(0, 0, 0, 1), 5);

    // when / then
    try std.testing.expect(containsPoint(s, vec4.init(0, 0, 0, 1)));
    try std.testing.expect(containsPoint(s, vec4.init(3, 4, 0, 1)));
    try std.testing.expect(containsPoint(s, vec4.init(5, 0, 0, 1))); // on boundary
}

test "containsPoint - false when outside" {
    // given
    const s = from(vec4.init(0, 0, 0, 1), 5);

    // when / then
    try std.testing.expect(!containsPoint(s, vec4.init(6, 0, 0, 1)));
}

test "overlapsSphere - true for overlapping spheres" {
    // given
    const a = from(vec4.init(0, 0, 0, 1), 3);
    const b = from(vec4.init(4, 0, 0, 1), 2);

    // when / then
    try std.testing.expect(overlapsSphere(a, b));
}

test "overlapsSphere - false for separated spheres" {
    // given
    const a = from(vec4.init(0, 0, 0, 1), 1);
    const b = from(vec4.init(5, 0, 0, 1), 1);

    // when / then
    try std.testing.expect(!overlapsSphere(a, b));
}

test "overlapsSphere - true for touching spheres" {
    // given
    const a = from(vec4.init(0, 0, 0, 1), 2);
    const b = from(vec4.init(5, 0, 0, 1), 3);

    // when / then
    try std.testing.expect(overlapsSphere(a, b));
}

test "distanceToPoint - zero when inside" {
    // given
    const s = from(vec4.init(0, 0, 0, 1), 5);

    // when
    const dist = distanceToPoint(s, vec4.init(2, 0, 0, 1));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), dist, 0.0001);
}

test "distanceToPoint - positive when outside" {
    // given
    const s = from(vec4.init(0, 0, 0, 1), 5);

    // when
    const dist = distanceToPoint(s, vec4.init(8, 0, 0, 1));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 3.0), dist, 0.0001);
}
