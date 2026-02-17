// @analogAlex
const std = @import("std");
const vec4 = @import("../vectors/vec4.zig");

pub const Vec4 = vec4.Vec4;

/// Axis-Aligned Bounding Box with Vec4 min/max corners (w=1 points).
pub const AABB = struct {
    min: Vec4, // w=1
    max: Vec4, // w=1
};

pub fn from(min_point: Vec4, max_point: Vec4) AABB {
    return .{
        .min = Vec4{ min_point[0], min_point[1], min_point[2], 1 },
        .max = Vec4{ max_point[0], max_point[1], max_point[2], 1 },
    };
}

/// Create AABB from center and half-extents.
pub fn fromCenterExtents(c: Vec4, half_ext: Vec4) AABB {
    const he = Vec4{ half_ext[0], half_ext[1], half_ext[2], 0 };
    const center_pt = Vec4{ c[0], c[1], c[2], 1 };
    return .{
        .min = center_pt - he,
        .max = center_pt + he,
    };
}

pub inline fn center(box: AABB) Vec4 {
    const mid = (box.min + box.max) * @as(Vec4, @splat(0.5));
    return Vec4{ mid[0], mid[1], mid[2], 1 };
}

pub inline fn extents(box: AABB) Vec4 {
    const ext = box.max - box.min;
    return Vec4{ ext[0], ext[1], ext[2], 0 };
}

pub inline fn halfExtents(box: AABB) Vec4 {
    const ext = extents(box);
    return ext * @as(Vec4, @splat(0.5));
}

pub inline fn containsPoint(box: AABB, p: Vec4) bool {
    return p[0] >= box.min[0] and p[0] <= box.max[0] and
        p[1] >= box.min[1] and p[1] <= box.max[1] and
        p[2] >= box.min[2] and p[2] <= box.max[2];
}

pub inline fn overlaps(a: AABB, b: AABB) bool {
    return a.min[0] <= b.max[0] and a.max[0] >= b.min[0] and
        a.min[1] <= b.max[1] and a.max[1] >= b.min[1] and
        a.min[2] <= b.max[2] and a.max[2] >= b.min[2];
}

pub fn closestPointToPoint(box: AABB, p: Vec4) Vec4 {
    const clamped = @min(box.max, @max(box.min, p));
    return Vec4{ clamped[0], clamped[1], clamped[2], 1 };
}

pub fn distanceToPoint(box: AABB, p: Vec4) f32 {
    const closest = closestPointToPoint(box, p);
    const diff = closest - p;
    const xyz = Vec4{ diff[0], diff[1], diff[2], 0 };
    return @sqrt(@reduce(.Add, xyz * xyz));
}

/// Expand this AABB to also contain point p.
pub fn expandToContain(box: AABB, p: Vec4) AABB {
    return .{
        .min = Vec4{ @min(box.min[0], p[0]), @min(box.min[1], p[1]), @min(box.min[2], p[2]), 1 },
        .max = Vec4{ @max(box.max[0], p[0]), @max(box.max[1], p[1]), @max(box.max[2], p[2]), 1 },
    };
}

/// Merge two AABBs into the smallest enclosing AABB.
pub fn merge(a: AABB, b: AABB) AABB {
    return .{
        .min = Vec4{ @min(a.min[0], b.min[0]), @min(a.min[1], b.min[1]), @min(a.min[2], b.min[2]), 1 },
        .max = Vec4{ @max(a.max[0], b.max[0]), @max(a.max[1], b.max[1]), @max(a.max[2], b.max[2]), 1 },
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
    const box = from(vec4.from(-1, -1, -1, 1), vec4.from(1, 1, 1, 1));

    // then
    try std.testing.expect(box.min[0] == -1 and box.min[1] == -1 and box.min[2] == -1);
    try std.testing.expect(box.max[0] == 1 and box.max[1] == 1 and box.max[2] == 1);
    try std.testing.expect(box.min[3] == 1 and box.max[3] == 1);
}

test "fromCenterExtents - creates AABB from center and half-extents" {
    // given / when
    const box = fromCenterExtents(vec4.from(0, 0, 0, 1), vec4.from(2, 3, 4, 0));

    // then
    try std.testing.expect(vec4.approxEqual(box.min, vec4.from(-2, -3, -4, 1), 0.0001));
    try std.testing.expect(vec4.approxEqual(box.max, vec4.from(2, 3, 4, 1), 0.0001));
}

test "center - returns center point" {
    // given
    const box = from(vec4.from(0, 0, 0, 1), vec4.from(10, 10, 10, 1));

    // when
    const c = center(box);

    // then
    try std.testing.expect(vec4.approxEqual(c, vec4.from(5, 5, 5, 1), 0.0001));
}

test "containsPoint - true when inside" {
    // given
    const box = from(vec4.from(-1, -1, -1, 1), vec4.from(1, 1, 1, 1));

    // when / then
    try std.testing.expect(containsPoint(box, vec4.from(0, 0, 0, 1)));
    try std.testing.expect(containsPoint(box, vec4.from(1, 1, 1, 1))); // on boundary
}

test "containsPoint - false when outside" {
    // given
    const box = from(vec4.from(-1, -1, -1, 1), vec4.from(1, 1, 1, 1));

    // when / then
    try std.testing.expect(!containsPoint(box, vec4.from(2, 0, 0, 1)));
    try std.testing.expect(!containsPoint(box, vec4.from(0, -2, 0, 1)));
}

test "overlaps - true for overlapping AABBs" {
    // given
    const a = from(vec4.from(0, 0, 0, 1), vec4.from(2, 2, 2, 1));
    const b = from(vec4.from(1, 1, 1, 1), vec4.from(3, 3, 3, 1));

    // when / then
    try std.testing.expect(overlaps(a, b));
}

test "overlaps - false for separated AABBs" {
    // given
    const a = from(vec4.from(0, 0, 0, 1), vec4.from(1, 1, 1, 1));
    const b = from(vec4.from(2, 2, 2, 1), vec4.from(3, 3, 3, 1));

    // when / then
    try std.testing.expect(!overlaps(a, b));
}

test "overlaps - true for touching AABBs" {
    // given
    const a = from(vec4.from(0, 0, 0, 1), vec4.from(1, 1, 1, 1));
    const b = from(vec4.from(1, 0, 0, 1), vec4.from(2, 1, 1, 1));

    // when / then
    try std.testing.expect(overlaps(a, b));
}

test "closestPointToPoint - returns point when inside" {
    // given
    const box = from(vec4.from(0, 0, 0, 1), vec4.from(10, 10, 10, 1));
    const p = vec4.from(5, 5, 5, 1);

    // when
    const closest = closestPointToPoint(box, p);

    // then
    try std.testing.expect(vec4.approxEqual(closest, vec4.from(5, 5, 5, 1), 0.0001));
}

test "closestPointToPoint - clamps to surface when outside" {
    // given
    const box = from(vec4.from(0, 0, 0, 1), vec4.from(10, 10, 10, 1));
    const p = vec4.from(15, 5, -3, 1);

    // when
    const closest = closestPointToPoint(box, p);

    // then
    try std.testing.expect(vec4.approxEqual(closest, vec4.from(10, 5, 0, 1), 0.0001));
}

test "merge - creates enclosing AABB" {
    // given
    const a = from(vec4.from(0, 0, 0, 1), vec4.from(2, 2, 2, 1));
    const b = from(vec4.from(-1, 1, -1, 1), vec4.from(1, 3, 1, 1));

    // when
    const merged = merge(a, b);

    // then
    try std.testing.expect(merged.min[0] == -1 and merged.min[1] == 0 and merged.min[2] == -1);
    try std.testing.expect(merged.max[0] == 2 and merged.max[1] == 3 and merged.max[2] == 2);
}

test "volume - calculates correct volume" {
    // given
    const box = from(vec4.from(0, 0, 0, 1), vec4.from(2, 3, 4, 1));

    // when
    const vol = volume(box);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 24.0), vol, 0.0001);
}

test "surfaceArea - calculates correct surface area" {
    // given
    const box = from(vec4.from(0, 0, 0, 1), vec4.from(2, 3, 4, 1));

    // when
    const sa = surfaceArea(box);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 52.0), sa, 0.0001);
}
