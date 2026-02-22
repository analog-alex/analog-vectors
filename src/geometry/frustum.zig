// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");
const plane_mod = @import("plane.zig");

pub const Vec3 = vec3.Vec3;
pub const Plane = plane_mod.Plane;

/// View frustum defined by 6 planes (normals pointing inward).
/// Used for culling objects outside the camera's view volume.
pub const Frustum = struct {
    planes: [6]Plane, // near, far, left, right, top, bottom
};

pub const FrustumPlane = enum(u3) {
    near = 0,
    far = 1,
    left = 2,
    right = 3,
    top = 4,
    bottom = 5,
};

pub fn from(planes: [6]Plane) Frustum {
    return .{ .planes = planes };
}

/// Create frustum from a view-projection matrix (column-major 4x4).
/// Extracts the 6 clip planes using the Gribb-Hartmann method.
pub fn fromViewProjectionMatrix(m: [16]f32) Frustum {
    var planes: [6]Plane = undefined;

    // Left: row3 + row0
    planes[@intFromEnum(FrustumPlane.left)] = normalizePlane(
        m[3] + m[0],
        m[7] + m[4],
        m[11] + m[8],
        m[15] + m[12],
    );
    // Right: row3 - row0
    planes[@intFromEnum(FrustumPlane.right)] = normalizePlane(
        m[3] - m[0],
        m[7] - m[4],
        m[11] - m[8],
        m[15] - m[12],
    );
    // Bottom: row3 + row1
    planes[@intFromEnum(FrustumPlane.bottom)] = normalizePlane(
        m[3] + m[1],
        m[7] + m[5],
        m[11] + m[9],
        m[15] + m[13],
    );
    // Top: row3 - row1
    planes[@intFromEnum(FrustumPlane.top)] = normalizePlane(
        m[3] - m[1],
        m[7] - m[5],
        m[11] - m[9],
        m[15] - m[13],
    );
    // Near: row3 + row2
    planes[@intFromEnum(FrustumPlane.near)] = normalizePlane(
        m[3] + m[2],
        m[7] + m[6],
        m[11] + m[10],
        m[15] + m[14],
    );
    // Far: row3 - row2
    planes[@intFromEnum(FrustumPlane.far)] = normalizePlane(
        m[3] - m[2],
        m[7] - m[6],
        m[11] - m[10],
        m[15] - m[14],
    );

    return .{ .planes = planes };
}

fn normalizePlane(a: f32, b: f32, c: f32, d: f32) Plane {
    const len = @sqrt(a * a + b * b + c * c);
    if (len == 0) return .{ .normal = vec3.init(0, 1, 0), .d = 0 };
    const inv = 1.0 / len;
    return .{ .normal = vec3.init(a * inv, b * inv, c * inv), .d = d * inv };
}

/// Test if a point is inside the frustum (on the positive side of all planes).
pub fn containsPoint(f: Frustum, p: Vec3) bool {
    inline for (0..6) |i| {
        if (plane_mod.signedDistanceToPoint(f.planes[i], p) < 0) return false;
    }
    return true;
}

/// Test if a sphere is at least partially inside the frustum.
pub fn containsSphere(f: Frustum, c: Vec3, radius: f32) bool {
    inline for (0..6) |i| {
        if (plane_mod.signedDistanceToPoint(f.planes[i], c) < -radius) return false;
    }
    return true;
}

/// Get a specific frustum plane.
pub inline fn getPlane(f: Frustum, which: FrustumPlane) Plane {
    return f.planes[@intFromEnum(which)];
}

// ===============
// Tests

test "containsPoint - point inside frustum" {
    // given - create a simple box frustum centered at origin, half-extents of 10
    const f = from(.{
        plane_mod.fromPointNormal(vec3.init(0, 0, -10), vec3.init(0, 0, 1)), // near
        plane_mod.fromPointNormal(vec3.init(0, 0, 10), vec3.init(0, 0, -1)), // far
        plane_mod.fromPointNormal(vec3.init(-10, 0, 0), vec3.init(1, 0, 0)), // left
        plane_mod.fromPointNormal(vec3.init(10, 0, 0), vec3.init(-1, 0, 0)), // right
        plane_mod.fromPointNormal(vec3.init(0, 10, 0), vec3.init(0, -1, 0)), // top
        plane_mod.fromPointNormal(vec3.init(0, -10, 0), vec3.init(0, 1, 0)), // bottom
    });

    // when / then
    try std.testing.expect(containsPoint(f, vec3.init(0, 0, 0)));
    try std.testing.expect(containsPoint(f, vec3.init(5, 5, 5)));
}

test "containsPoint - point outside frustum" {
    // given
    const f = from(.{
        plane_mod.fromPointNormal(vec3.init(0, 0, -10), vec3.init(0, 0, 1)),
        plane_mod.fromPointNormal(vec3.init(0, 0, 10), vec3.init(0, 0, -1)),
        plane_mod.fromPointNormal(vec3.init(-10, 0, 0), vec3.init(1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(10, 0, 0), vec3.init(-1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(0, 10, 0), vec3.init(0, -1, 0)),
        plane_mod.fromPointNormal(vec3.init(0, -10, 0), vec3.init(0, 1, 0)),
    });

    // when / then
    try std.testing.expect(!containsPoint(f, vec3.init(15, 0, 0)));
    try std.testing.expect(!containsPoint(f, vec3.init(0, 0, 15)));
}

test "containsSphere - sphere partially inside" {
    // given
    const f = from(.{
        plane_mod.fromPointNormal(vec3.init(0, 0, -10), vec3.init(0, 0, 1)),
        plane_mod.fromPointNormal(vec3.init(0, 0, 10), vec3.init(0, 0, -1)),
        plane_mod.fromPointNormal(vec3.init(-10, 0, 0), vec3.init(1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(10, 0, 0), vec3.init(-1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(0, 10, 0), vec3.init(0, -1, 0)),
        plane_mod.fromPointNormal(vec3.init(0, -10, 0), vec3.init(0, 1, 0)),
    });

    // when / then - sphere straddles the right plane
    try std.testing.expect(containsSphere(f, vec3.init(11, 0, 0), 3));
}

test "containsSphere - sphere fully outside" {
    // given
    const f = from(.{
        plane_mod.fromPointNormal(vec3.init(0, 0, -10), vec3.init(0, 0, 1)),
        plane_mod.fromPointNormal(vec3.init(0, 0, 10), vec3.init(0, 0, -1)),
        plane_mod.fromPointNormal(vec3.init(-10, 0, 0), vec3.init(1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(10, 0, 0), vec3.init(-1, 0, 0)),
        plane_mod.fromPointNormal(vec3.init(0, 10, 0), vec3.init(0, -1, 0)),
        plane_mod.fromPointNormal(vec3.init(0, -10, 0), vec3.init(0, 1, 0)),
    });

    // when / then
    try std.testing.expect(!containsSphere(f, vec3.init(20, 0, 0), 2));
}
