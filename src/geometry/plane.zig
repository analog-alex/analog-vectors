// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

/// Plane represented as normal.x*x + normal.y*y + normal.z*z + d = 0
pub const Plane = struct {
    normal: Vec3, // should be normalized
    d: f32,
};

/// Create plane from normal and distance from origin.
pub fn from(normal: Vec3, d: f32) Plane {
    return .{ .normal = vec3.normalize(normal), .d = d };
}

/// Create plane from normal and a point on the plane.
pub fn fromPointNormal(point: Vec3, normal: Vec3) Plane {
    const n = vec3.normalize(normal);
    return .{ .normal = n, .d = -vec3.dot(n, point) };
}

/// Create plane from three non-collinear points (CCW winding).
pub fn fromPoints(a: Vec3, b: Vec3, c: Vec3) Plane {
    const ab = vec3.sub(b, a);
    const ac = vec3.sub(c, a);
    const n = vec3.normalize(vec3.cross(ab, ac));
    return .{ .normal = n, .d = -vec3.dot(n, a) };
}

/// Signed distance from point to plane. Positive = same side as normal.
pub inline fn signedDistanceToPoint(p: Plane, point: Vec3) f32 {
    return vec3.dot(p.normal, point) + p.d;
}

/// Absolute distance from point to plane.
pub inline fn distanceToPoint(p: Plane, point: Vec3) f32 {
    return @abs(signedDistanceToPoint(p, point));
}

/// Project a point onto the plane (closest point on plane).
pub fn closestPointToPoint(p: Plane, point: Vec3) Vec3 {
    const dist = signedDistanceToPoint(p, point);
    return vec3.sub(point, vec3.mul(p.normal, dist));
}

/// Returns true if the point is on the positive side of the plane (same side as normal).
pub inline fn isPointInFront(p: Plane, point: Vec3) bool {
    return signedDistanceToPoint(p, point) > 0;
}

// ===============
// Tests

test "fromPointNormal - creates plane through point with normal" {
    // given
    const point = vec3.from(0, 5, 0);
    const normal = vec3.from(0, 1, 0);

    // when
    const p = fromPointNormal(point, normal);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, point), 0.0001);
}

test "fromPoints - creates plane from three points" {
    // given
    const a = vec3.from(0, 0, 0);
    const b = vec3.from(1, 0, 0);
    const c = vec3.from(0, 0, 1);

    // when
    const p = fromPoints(a, b, c);

    // then - normal should point up (y-axis) for XZ plane with CCW winding
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, a), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, b), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, c), 0.0001);
}

test "signedDistanceToPoint - positive when in front" {
    // given
    const p = fromPointNormal(vec3.from(0, 0, 0), vec3.from(0, 1, 0));

    // when
    const dist = signedDistanceToPoint(p, vec3.from(0, 5, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), dist, 0.0001);
}

test "signedDistanceToPoint - negative when behind" {
    // given
    const p = fromPointNormal(vec3.from(0, 0, 0), vec3.from(0, 1, 0));

    // when
    const dist = signedDistanceToPoint(p, vec3.from(0, -3, 0));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, -3.0), dist, 0.0001);
}

test "closestPointToPoint - projects onto plane" {
    // given
    const p = fromPointNormal(vec3.from(0, 0, 0), vec3.from(0, 1, 0));
    const point = vec3.from(3, 7, 4);

    // when
    const closest = closestPointToPoint(p, point);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.from(3, 0, 4), 0.0001));
}

test "isPointInFront - returns true for points on normal side" {
    // given
    const p = fromPointNormal(vec3.from(0, 0, 0), vec3.from(0, 1, 0));

    // when / then
    try std.testing.expect(isPointInFront(p, vec3.from(0, 1, 0)));
    try std.testing.expect(!isPointInFront(p, vec3.from(0, -1, 0)));
}
