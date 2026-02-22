// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

/// Capsule defined by a line segment (start to end) and a radius.
/// Also known as a "swept sphere" — the Minkowski sum of a segment and a sphere.
pub const Capsule = struct {
    start: Vec3,
    end: Vec3,
    radius: f32,
};

pub fn from(start: Vec3, end: Vec3, radius: f32) Capsule {
    return .{ .start = start, .end = end, .radius = radius };
}

pub inline fn height(c: Capsule) f32 {
    return vec3.distance(c.start, c.end);
}

pub fn center(c: Capsule) Vec3 {
    return vec3.lerp(c.start, c.end, 0.5);
}

pub fn containsPoint(c: Capsule, p: Vec3) bool {
    const closest = closestPointOnAxis(c, p);
    return vec3.distanceSquared(closest, p) <= c.radius * c.radius;
}

/// Returns the closest point on the capsule's central axis to a given point.
fn closestPointOnAxis(c: Capsule, p: Vec3) Vec3 {
    const ab = vec3.sub(c.end, c.start);
    const ap = vec3.sub(p, c.start);
    const len_sq = vec3.lengthSquared(ab);
    if (len_sq == 0) return c.start;
    const t = @max(0.0, @min(1.0, vec3.dot(ap, ab) / len_sq));
    return vec3.sum(c.start, vec3.mul(ab, t));
}

pub fn closestPointToPoint(c: Capsule, p: Vec3) Vec3 {
    const axis_point = closestPointOnAxis(c, p);
    const dir = vec3.sub(p, axis_point);
    const dist = vec3.length(dir);
    if (dist == 0) return vec3.sum(axis_point, vec3.mul(vec3.init(1, 0, 0), c.radius));
    return vec3.sum(axis_point, vec3.mul(vec3.normalize(dir), c.radius));
}

pub fn distanceToPoint(c: Capsule, p: Vec3) f32 {
    const axis_point = closestPointOnAxis(c, p);
    const dist = vec3.distance(axis_point, p);
    return @max(0.0, dist - c.radius);
}

// ===============
// Tests

test "from - creates capsule" {
    // given / when
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);

    // then
    try std.testing.expect(vec3.equal(c.start, vec3.init(0, 0, 0)));
    try std.testing.expect(vec3.equal(c.end, vec3.init(0, 10, 0)));
    try std.testing.expect(c.radius == 2);
}

test "height - returns distance between endpoints" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);

    // when
    const h = height(c);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 10.0), h, 0.0001);
}

test "center - returns midpoint of axis" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);

    // when
    const mid = center(c);

    // then
    try std.testing.expect(vec3.approxEqual(mid, vec3.init(0, 5, 0), 0.0001));
}

test "containsPoint - true when inside" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 3);

    // when / then
    try std.testing.expect(containsPoint(c, vec3.init(0, 5, 0))); // on axis
    try std.testing.expect(containsPoint(c, vec3.init(2, 5, 0))); // inside radius
}

test "containsPoint - false when outside" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);

    // when / then
    try std.testing.expect(!containsPoint(c, vec3.init(5, 5, 0)));
}

test "distanceToPoint - zero when inside" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 3);

    // when
    const dist = distanceToPoint(c, vec3.init(1, 5, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), dist, 0.0001);
}

test "distanceToPoint - positive when outside" {
    // given
    const c = from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);

    // when
    const dist = distanceToPoint(c, vec3.init(5, 5, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 3.0), dist, 0.0001);
}
