// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

/// Oriented Bounding Box defined by center, three orthonormal axes, and half-extents.
pub const OBB = struct {
    center: Vec3,
    axes: [3]Vec3, // orthonormal local axes (right, up, forward)
    half_extents: Vec3, // half-size along each axis
};

pub fn from(c: Vec3, axes: [3]Vec3, half_ext: Vec3) OBB {
    return .{ .center = c, .axes = axes, .half_extents = half_ext };
}

/// Create an axis-aligned OBB (equivalent to AABB semantics).
pub fn fromAxisAligned(c: Vec3, half_ext: Vec3) OBB {
    return .{
        .center = c,
        .axes = .{
            vec3.from(1, 0, 0),
            vec3.from(0, 1, 0),
            vec3.from(0, 0, 1),
        },
        .half_extents = half_ext,
    };
}

pub fn closestPointToPoint(box: OBB, p: Vec3) Vec3 {
    const d = vec3.sub(p, box.center);
    var result = box.center;

    inline for (0..3) |i| {
        var dist = vec3.dot(d, box.axes[i]);
        dist = @max(-box.half_extents[i], @min(dist, box.half_extents[i]));
        result = vec3.sum(result, vec3.mul(box.axes[i], dist));
    }

    return result;
}

pub fn containsPoint(box: OBB, p: Vec3) bool {
    const d = vec3.sub(p, box.center);

    inline for (0..3) |i| {
        const dist = @abs(vec3.dot(d, box.axes[i]));
        if (dist > box.half_extents[i]) return false;
    }

    return true;
}

/// Separating Axis Theorem (SAT) test for OBB-OBB overlap.
pub fn overlaps(a: OBB, b: OBB) bool {
    const t = vec3.sub(b.center, a.center);

    // Precompute rotation matrix and absolute rotation matrix
    var r_mat: [3][3]f32 = undefined;
    var abs_r: [3][3]f32 = undefined;
    const epsilon: f32 = 1e-6;

    inline for (0..3) |i| {
        inline for (0..3) |j| {
            r_mat[i][j] = vec3.dot(a.axes[i], b.axes[j]);
            abs_r[i][j] = @abs(r_mat[i][j]) + epsilon;
        }
    }

    // Test axes L = a.axes[i]
    inline for (0..3) |i| {
        const ra = a.half_extents[i];
        const rb = b.half_extents[0] * abs_r[i][0] + b.half_extents[1] * abs_r[i][1] + b.half_extents[2] * abs_r[i][2];
        if (@abs(vec3.dot(t, a.axes[i])) > ra + rb) return false;
    }

    // Test axes L = b.axes[i]
    inline for (0..3) |j| {
        const ra = a.half_extents[0] * abs_r[0][j] + a.half_extents[1] * abs_r[1][j] + a.half_extents[2] * abs_r[2][j];
        const rb = b.half_extents[j];
        const proj = @abs(t[0] * r_mat[0][j] + t[1] * r_mat[1][j] + t[2] * r_mat[2][j]);
        if (proj > ra + rb) return false;
    }

    // Test 9 cross-product axes
    // L = a.axes[0] x b.axes[0..2]
    {
        const ra = a.half_extents[1] * abs_r[2][0] + a.half_extents[2] * abs_r[1][0];
        const rb = b.half_extents[1] * abs_r[0][2] + b.half_extents[2] * abs_r[0][1];
        if (@abs(t[2] * r_mat[1][0] - t[1] * r_mat[2][0]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[1] * abs_r[2][1] + a.half_extents[2] * abs_r[1][1];
        const rb = b.half_extents[0] * abs_r[0][2] + b.half_extents[2] * abs_r[0][0];
        if (@abs(t[2] * r_mat[1][1] - t[1] * r_mat[2][1]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[1] * abs_r[2][2] + a.half_extents[2] * abs_r[1][2];
        const rb = b.half_extents[0] * abs_r[0][1] + b.half_extents[1] * abs_r[0][0];
        if (@abs(t[2] * r_mat[1][2] - t[1] * r_mat[2][2]) > ra + rb) return false;
    }

    // L = a.axes[1] x b.axes[0..2]
    {
        const ra = a.half_extents[0] * abs_r[2][0] + a.half_extents[2] * abs_r[0][0];
        const rb = b.half_extents[1] * abs_r[1][2] + b.half_extents[2] * abs_r[1][1];
        if (@abs(t[0] * r_mat[2][0] - t[2] * r_mat[0][0]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[0] * abs_r[2][1] + a.half_extents[2] * abs_r[0][1];
        const rb = b.half_extents[0] * abs_r[1][2] + b.half_extents[2] * abs_r[1][0];
        if (@abs(t[0] * r_mat[2][1] - t[2] * r_mat[0][1]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[0] * abs_r[2][2] + a.half_extents[2] * abs_r[0][2];
        const rb = b.half_extents[0] * abs_r[1][1] + b.half_extents[1] * abs_r[1][0];
        if (@abs(t[0] * r_mat[2][2] - t[2] * r_mat[0][2]) > ra + rb) return false;
    }

    // L = a.axes[2] x b.axes[0..2]
    {
        const ra = a.half_extents[0] * abs_r[1][0] + a.half_extents[1] * abs_r[0][0];
        const rb = b.half_extents[1] * abs_r[2][2] + b.half_extents[2] * abs_r[2][1];
        if (@abs(t[1] * r_mat[0][0] - t[0] * r_mat[1][0]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[0] * abs_r[1][1] + a.half_extents[1] * abs_r[0][1];
        const rb = b.half_extents[0] * abs_r[2][2] + b.half_extents[2] * abs_r[2][0];
        if (@abs(t[1] * r_mat[0][1] - t[0] * r_mat[1][1]) > ra + rb) return false;
    }
    {
        const ra = a.half_extents[0] * abs_r[1][2] + a.half_extents[1] * abs_r[0][2];
        const rb = b.half_extents[0] * abs_r[2][1] + b.half_extents[1] * abs_r[2][0];
        if (@abs(t[1] * r_mat[0][2] - t[0] * r_mat[1][2]) > ra + rb) return false;
    }

    return true;
}

// ===============
// Tests

test "fromAxisAligned - creates axis-aligned OBB" {
    // given / when
    const box = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(2, 3, 4));

    // then
    try std.testing.expect(vec3.equal(box.center, vec3.from(0, 0, 0)));
    try std.testing.expect(vec3.equal(box.half_extents, vec3.from(2, 3, 4)));
}

test "containsPoint - true when inside" {
    // given
    const box = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(5, 5, 5));

    // when / then
    try std.testing.expect(containsPoint(box, vec3.from(0, 0, 0)));
    try std.testing.expect(containsPoint(box, vec3.from(4, 4, 4)));
}

test "containsPoint - false when outside" {
    // given
    const box = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(5, 5, 5));

    // when / then
    try std.testing.expect(!containsPoint(box, vec3.from(6, 0, 0)));
}

test "closestPointToPoint - clamps to surface" {
    // given
    const box = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(5, 5, 5));
    const p = vec3.from(10, 3, 0);

    // when
    const closest = closestPointToPoint(box, p);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.from(5, 3, 0), 0.0001));
}

test "overlaps - true for overlapping axis-aligned OBBs" {
    // given
    const a = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(2, 2, 2));
    const b = fromAxisAligned(vec3.from(3, 0, 0), vec3.from(2, 2, 2));

    // when / then
    try std.testing.expect(overlaps(a, b));
}

test "overlaps - false for separated OBBs" {
    // given
    const a = fromAxisAligned(vec3.from(0, 0, 0), vec3.from(1, 1, 1));
    const b = fromAxisAligned(vec3.from(5, 0, 0), vec3.from(1, 1, 1));

    // when / then
    try std.testing.expect(!overlaps(a, b));
}
