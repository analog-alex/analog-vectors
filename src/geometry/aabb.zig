// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

/// Axis-Aligned Bounding Box defined by min and max corners.
pub const AABB = struct {
    min: Vec3,
    max: Vec3,
};

pub fn from(min_point: Vec3, max_point: Vec3) AABB {
    return .{ .min = min_point, .max = max_point };
}

/// Create AABB from center and half-extents.
pub fn fromCenterExtents(c: Vec3, half_ext: Vec3) AABB {
    return .{
        .min = vec3.sub(c, half_ext),
        .max = vec3.sum(c, half_ext),
    };
}

pub inline fn center(box: AABB) Vec3 {
    return vec3.mul(vec3.sum(box.min, box.max), 0.5);
}

pub inline fn extents(box: AABB) Vec3 {
    return vec3.sub(box.max, box.min);
}

pub inline fn halfExtents(box: AABB) Vec3 {
    return vec3.mul(extents(box), 0.5);
}

pub inline fn containsPoint(box: AABB, p: Vec3) bool {
    return p[0] >= box.min[0] and p[0] <= box.max[0] and
        p[1] >= box.min[1] and p[1] <= box.max[1] and
        p[2] >= box.min[2] and p[2] <= box.max[2];
}

pub inline fn overlaps(a: AABB, b: AABB) bool {
    return a.min[0] <= b.max[0] and a.max[0] >= b.min[0] and
        a.min[1] <= b.max[1] and a.max[1] >= b.min[1] and
        a.min[2] <= b.max[2] and a.max[2] >= b.min[2];
}

pub fn closestPointToPoint(box: AABB, p: Vec3) Vec3 {
    return vec3.clamp(p, box.min, box.max);
}

pub fn distanceToPoint(box: AABB, p: Vec3) f32 {
    const closest = closestPointToPoint(box, p);
    return vec3.distance(closest, p);
}

/// Expand this AABB to also contain point p.
pub fn expandToContain(box: AABB, p: Vec3) AABB {
    return .{
        .min = vec3.min(box.min, p),
        .max = vec3.max(box.max, p),
    };
}

/// Merge two AABBs into the smallest enclosing AABB.
pub fn merge(a: AABB, b: AABB) AABB {
    return .{
        .min = vec3.min(a.min, b.min),
        .max = vec3.max(a.max, b.max),
    };
}

pub fn surfaceArea(box: AABB) f32 {
    const e = extents(box);
    return 2.0 * (e[0] * e[1] + e[1] * e[2] + e[2] * e[0]);
}

pub fn volume(box: AABB) f32 {
    const e = extents(box);
    return e[0] * e[1] * e[2];
}

// ===============
// Tests

test "from - creates AABB with min and max" {
    // given / when
    const box = from(vec3.from(-1, -1, -1), vec3.from(1, 1, 1));

    // then
    try std.testing.expect(vec3.equal(box.min, vec3.from(-1, -1, -1)));
    try std.testing.expect(vec3.equal(box.max, vec3.from(1, 1, 1)));
}

test "fromCenterExtents - creates AABB from center and half-extents" {
    // given / when
    const box = fromCenterExtents(vec3.from(0, 0, 0), vec3.from(2, 3, 4));

    // then
    try std.testing.expect(vec3.equal(box.min, vec3.from(-2, -3, -4)));
    try std.testing.expect(vec3.equal(box.max, vec3.from(2, 3, 4)));
}

test "center - returns center point" {
    // given
    const box = from(vec3.from(0, 0, 0), vec3.from(10, 10, 10));

    // when
    const c = center(box);

    // then
    try std.testing.expect(vec3.equal(c, vec3.from(5, 5, 5)));
}

test "containsPoint - true when inside" {
    // given
    const box = from(vec3.from(-1, -1, -1), vec3.from(1, 1, 1));

    // when / then
    try std.testing.expect(containsPoint(box, vec3.from(0, 0, 0)));
    try std.testing.expect(containsPoint(box, vec3.from(1, 1, 1))); // on boundary
}

test "containsPoint - false when outside" {
    // given
    const box = from(vec3.from(-1, -1, -1), vec3.from(1, 1, 1));

    // when / then
    try std.testing.expect(!containsPoint(box, vec3.from(2, 0, 0)));
    try std.testing.expect(!containsPoint(box, vec3.from(0, -2, 0)));
}

test "overlaps - true for overlapping AABBs" {
    // given
    const a = from(vec3.from(0, 0, 0), vec3.from(2, 2, 2));
    const b = from(vec3.from(1, 1, 1), vec3.from(3, 3, 3));

    // when / then
    try std.testing.expect(overlaps(a, b));
}

test "overlaps - false for separated AABBs" {
    // given
    const a = from(vec3.from(0, 0, 0), vec3.from(1, 1, 1));
    const b = from(vec3.from(2, 2, 2), vec3.from(3, 3, 3));

    // when / then
    try std.testing.expect(!overlaps(a, b));
}

test "overlaps - true for touching AABBs" {
    // given
    const a = from(vec3.from(0, 0, 0), vec3.from(1, 1, 1));
    const b = from(vec3.from(1, 0, 0), vec3.from(2, 1, 1));

    // when / then
    try std.testing.expect(overlaps(a, b));
}

test "closestPointToPoint - returns point when inside" {
    // given
    const box = from(vec3.from(0, 0, 0), vec3.from(10, 10, 10));
    const p = vec3.from(5, 5, 5);

    // when
    const closest = closestPointToPoint(box, p);

    // then
    try std.testing.expect(vec3.equal(closest, p));
}

test "closestPointToPoint - clamps to surface when outside" {
    // given
    const box = from(vec3.from(0, 0, 0), vec3.from(10, 10, 10));
    const p = vec3.from(15, 5, -3);

    // when
    const closest = closestPointToPoint(box, p);

    // then
    try std.testing.expect(vec3.equal(closest, vec3.from(10, 5, 0)));
}

test "merge - creates enclosing AABB" {
    // given
    const a = from(vec3.from(0, 0, 0), vec3.from(2, 2, 2));
    const b = from(vec3.from(-1, 1, -1), vec3.from(1, 3, 1));

    // when
    const merged = merge(a, b);

    // then
    try std.testing.expect(vec3.equal(merged.min, vec3.from(-1, 0, -1)));
    try std.testing.expect(vec3.equal(merged.max, vec3.from(2, 3, 2)));
}

test "volume - calculates correct volume" {
    // given
    const box = from(vec3.from(0, 0, 0), vec3.from(2, 3, 4));

    // when
    const vol = volume(box);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 24.0), vol, 0.0001);
}

test "surfaceArea - calculates correct surface area" {
    // given
    const box = from(vec3.from(0, 0, 0), vec3.from(2, 3, 4));

    // when
    const sa = surfaceArea(box);

    // then - 2*(2*3 + 3*4 + 4*2) = 2*(6+12+8) = 52
    try std.testing.expectApproxEqAbs(@as(f32, 52.0), sa, 0.0001);
}
