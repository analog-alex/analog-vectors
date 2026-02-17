// @analogAlex
const std = @import("std");
const vec4 = @import("../vectors/vec4.zig");

pub const Vec4 = vec4.Vec4;

/// Plane stored as a single Vec4: (nx, ny, nz, d)
/// where nx*x + ny*y + nz*z + d = 0.
/// The normal (xyz) should be normalized.
pub const Plane = struct {
    coefficients: Vec4, // (normal.x, normal.y, normal.z, d)
};

/// Create plane from normal and distance from origin.
pub fn from(normal: Vec4, d: f32) Plane {
    const n = normalizeNormal(normal);
    return .{ .coefficients = Vec4{ n[0], n[1], n[2], d } };
}

/// Create plane from a normal and a point on the plane.
pub fn fromPointNormal(point: Vec4, normal: Vec4) Plane {
    const n = normalizeNormal(normal);
    const d = -(n[0] * point[0] + n[1] * point[1] + n[2] * point[2]);
    return .{ .coefficients = Vec4{ n[0], n[1], n[2], d } };
}

/// Return the plane normal as a Vec4 direction (w=0).
pub inline fn getNormal(p: Plane) Vec4 {
    return Vec4{ p.coefficients[0], p.coefficients[1], p.coefficients[2], 0 };
}

/// Return the plane's d coefficient.
pub inline fn getD(p: Plane) f32 {
    return p.coefficients[3];
}

/// Signed distance from a point to the plane.
/// Positive = same side as normal.
/// Uses a single SIMD dot product with the homogeneous point (w=1).
pub inline fn signedDistanceToPoint(p: Plane, point: Vec4) f32 {
    // dot(coefficients, (px, py, pz, 1)) = nx*px + ny*py + nz*pz + d
    const pt = Vec4{ point[0], point[1], point[2], 1 };
    return @reduce(.Add, p.coefficients * pt);
}

/// Absolute distance from a point to the plane.
pub inline fn distanceToPoint(p: Plane, point: Vec4) f32 {
    return @abs(signedDistanceToPoint(p, point));
}

/// Project a point onto the plane (closest point on plane).
pub fn closestPointToPoint(p: Plane, point: Vec4) Vec4 {
    const dist = signedDistanceToPoint(p, point);
    const n = getNormal(p);
    return point - n * @as(Vec4, @splat(dist));
}

/// Returns true if the point is on the positive side of the plane (same side as normal).
pub inline fn isPointInFront(p: Plane, point: Vec4) bool {
    return signedDistanceToPoint(p, point) > 0;
}

fn normalizeNormal(normal: Vec4) Vec4 {
    const xyz = Vec4{ normal[0], normal[1], normal[2], 0 };
    return vec4.normalize(xyz);
}

// ===============
// Tests

test "fromPointNormal - creates plane through point with normal" {
    // given
    const point = vec4.from(0, 5, 0, 1);
    const normal = vec4.from(0, 1, 0, 0);

    // when
    const p = fromPointNormal(point, normal);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, point), 0.0001);
}

test "signedDistanceToPoint - positive when in front" {
    // given
    const p = fromPointNormal(vec4.from(0, 0, 0, 1), vec4.from(0, 1, 0, 0));

    // when
    const dist = signedDistanceToPoint(p, vec4.from(0, 5, 0, 1));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), dist, 0.0001);
}

test "signedDistanceToPoint - negative when behind" {
    // given
    const p = fromPointNormal(vec4.from(0, 0, 0, 1), vec4.from(0, 1, 0, 0));

    // when
    const dist = signedDistanceToPoint(p, vec4.from(0, -3, 0, 1));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, -3.0), dist, 0.0001);
}

test "distanceToPoint - returns absolute distance" {
    // given
    const p = fromPointNormal(vec4.from(0, 0, 0, 1), vec4.from(0, 1, 0, 0));

    // when
    const dist = distanceToPoint(p, vec4.from(0, -3, 0, 1));

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 3.0), dist, 0.0001);
}

test "closestPointToPoint - projects onto plane" {
    // given
    const p = fromPointNormal(vec4.from(0, 0, 0, 1), vec4.from(0, 1, 0, 0));
    const point = vec4.from(3, 7, 4, 1);

    // when
    const closest = closestPointToPoint(p, point);

    // then
    try std.testing.expect(vec4.approxEqual(closest, vec4.from(3, 0, 4, 1), 0.0001));
}

test "isPointInFront - returns true for points on normal side" {
    // given
    const p = fromPointNormal(vec4.from(0, 0, 0, 1), vec4.from(0, 1, 0, 0));

    // when / then
    try std.testing.expect(isPointInFront(p, vec4.from(0, 1, 0, 1)));
    try std.testing.expect(!isPointInFront(p, vec4.from(0, -1, 0, 1)));
}

test "from - creates plane with explicit d" {
    // given / when
    const p = from(vec4.from(0, 1, 0, 0), -5);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), signedDistanceToPoint(p, vec4.from(0, 5, 0, 1)), 0.0001);
}
