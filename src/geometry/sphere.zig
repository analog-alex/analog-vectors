// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

pub const Sphere = struct {
    center: Vec3,
    radius: f32,
};

pub fn from(c: Vec3, r: f32) Sphere {
    return .{ .center = c, .radius = r };
}

pub inline fn containsPoint(s: Sphere, p: Vec3) bool {
    return vec3.distanceSquared(s.center, p) <= s.radius * s.radius;
}

pub inline fn overlapsSphere(a: Sphere, b: Sphere) bool {
    const r_sum = a.radius + b.radius;
    return vec3.distanceSquared(a.center, b.center) <= r_sum * r_sum;
}

pub fn closestPointToPoint(s: Sphere, p: Vec3) Vec3 {
    const dir = vec3.sub(p, s.center);
    const dist = vec3.length(dir);
    if (dist == 0) return vec3.sum(s.center, vec3.mul(vec3.init(1, 0, 0), s.radius));
    return vec3.sum(s.center, vec3.mul(vec3.normalize(dir), s.radius));
}

pub fn distanceToPoint(s: Sphere, p: Vec3) f32 {
    const dist = vec3.distance(s.center, p);
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

test "from - creates sphere" {
    // given / when
    const s = from(vec3.init(1, 2, 3), 5);

    // then
    try std.testing.expect(vec3.equal(s.center, vec3.init(1, 2, 3)));
    try std.testing.expect(s.radius == 5);
}

test "containsPoint - true when inside" {
    // given
    const s = from(vec3.init(0, 0, 0), 5);

    // when / then
    try std.testing.expect(containsPoint(s, vec3.init(0, 0, 0)));
    try std.testing.expect(containsPoint(s, vec3.init(3, 4, 0)));
    try std.testing.expect(containsPoint(s, vec3.init(5, 0, 0))); // on boundary
}

test "containsPoint - false when outside" {
    // given
    const s = from(vec3.init(0, 0, 0), 5);

    // when / then
    try std.testing.expect(!containsPoint(s, vec3.init(6, 0, 0)));
}

test "overlapsSphere - true for overlapping spheres" {
    // given
    const a = from(vec3.init(0, 0, 0), 3);
    const b = from(vec3.init(4, 0, 0), 2);

    // when / then
    try std.testing.expect(overlapsSphere(a, b));
}

test "overlapsSphere - false for separated spheres" {
    // given
    const a = from(vec3.init(0, 0, 0), 1);
    const b = from(vec3.init(5, 0, 0), 1);

    // when / then
    try std.testing.expect(!overlapsSphere(a, b));
}

test "overlapsSphere - true for touching spheres" {
    // given
    const a = from(vec3.init(0, 0, 0), 2);
    const b = from(vec3.init(5, 0, 0), 3);

    // when / then
    try std.testing.expect(overlapsSphere(a, b));
}

test "closestPointToPoint - returns surface point" {
    // given
    const s = from(vec3.init(0, 0, 0), 5);
    const p = vec3.init(10, 0, 0);

    // when
    const closest = closestPointToPoint(s, p);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.init(5, 0, 0), 0.0001));
}

test "distanceToPoint - zero when inside" {
    // given
    const s = from(vec3.init(0, 0, 0), 5);

    // when
    const dist = distanceToPoint(s, vec3.init(2, 0, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), dist, 0.0001);
}

test "distanceToPoint - positive when outside" {
    // given
    const s = from(vec3.init(0, 0, 0), 5);

    // when
    const dist = distanceToPoint(s, vec3.init(8, 0, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 3.0), dist, 0.0001);
}
