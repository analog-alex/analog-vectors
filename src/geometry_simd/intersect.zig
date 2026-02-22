// @analogAlex
const std = @import("std");
const vec4 = @import("../vectors/vec4.zig");
const ray_mod = @import("ray.zig");
const sphere_mod = @import("sphere.zig");
const plane_mod = @import("plane.zig");
const aabb_mod = @import("aabb.zig");

pub const Vec4 = vec4.Vec4;
pub const Ray = ray_mod.Ray;
pub const Sphere = sphere_mod.Sphere;
pub const Plane = plane_mod.Plane;
pub const AABB = aabb_mod.AABB;

pub const HitRecord = struct {
    t: f32, // parameter along ray
    point: Vec4, // intersection point (w=1)
    normal: Vec4, // surface normal at intersection (w=0)
};

// ===============
// Ray-Sphere Intersection

pub fn raySphere(ray: Ray, s: Sphere) ?HitRecord {
    const oc = ray.origin - s.center;
    // Use xyz only for dot products (w components cancel for origin-center since both w=1)
    const oc_xyz = Vec4{ oc[0], oc[1], oc[2], 0 };
    const dir_xyz = Vec4{ ray.direction[0], ray.direction[1], ray.direction[2], 0 };

    const b = @reduce(.Add, oc_xyz * dir_xyz);
    const c = @reduce(.Add, oc_xyz * oc_xyz) - s.radius * s.radius;

    if (c > 0 and b > 0) return null;

    const discriminant = b * b - c;
    if (discriminant < 0) return null;

    const sqrt_disc = @sqrt(discriminant);
    var t = -b - sqrt_disc;

    if (t < 0) {
        t = -b + sqrt_disc;
        if (t < 0) return null;
    }

    const point = ray_mod.pointAt(ray, t);
    const diff = point - s.center;
    const diff_xyz = Vec4{ diff[0], diff[1], diff[2], 0 };
    const normal = vec4.normalize(diff_xyz);
    return .{ .t = t, .point = point, .normal = normal };
}

// ===============
// Ray-Plane Intersection

pub fn rayPlane(ray: Ray, p: Plane) ?HitRecord {
    const normal = plane_mod.getNormal(p);
    const dir_xyz = Vec4{ ray.direction[0], ray.direction[1], ray.direction[2], 0 };
    const denom = @reduce(.Add, normal * dir_xyz);

    if (@abs(denom) < 1e-6) return null;

    const t = -plane_mod.signedDistanceToPoint(p, ray.origin) / denom;

    if (t < 0) return null;

    const point = ray_mod.pointAt(ray, t);
    const hit_normal = if (denom < 0) normal else vec4.neg(normal);
    return .{ .t = t, .point = point, .normal = hit_normal };
}

// ===============
// Ray-AABB Intersection (slab method)

pub fn rayAABB(ray: Ray, box: AABB) ?HitRecord {
    const inv_dir = Vec4{
        if (ray.direction[0] != 0) 1.0 / ray.direction[0] else std.math.inf(f32),
        if (ray.direction[1] != 0) 1.0 / ray.direction[1] else std.math.inf(f32),
        if (ray.direction[2] != 0) 1.0 / ray.direction[2] else std.math.inf(f32),
        0,
    };

    const t1 = (box.min - ray.origin) * inv_dir;
    const t2 = (box.max - ray.origin) * inv_dir;

    const t_min_v = @min(t1, t2);
    const t_max_v = @max(t1, t2);

    const t_enter = @max(t_min_v[0], @max(t_min_v[1], t_min_v[2]));
    const t_exit = @min(t_max_v[0], @min(t_max_v[1], t_max_v[2]));

    if (t_enter > t_exit or t_exit < 0) return null;

    const t = if (t_enter >= 0) t_enter else t_exit;
    const point = ray_mod.pointAt(ray, t);
    const normal = computeAABBNormal(box, point);

    return .{ .t = t, .point = point, .normal = normal };
}

fn computeAABBNormal(box: AABB, point: Vec4) Vec4 {
    const epsilon: f32 = 1e-4;
    const c = aabb_mod.center(box);
    const d_vec = point - c;
    const he = aabb_mod.halfExtents(box);

    const dx = @abs(@abs(d_vec[0]) - he[0]);
    const dy = @abs(@abs(d_vec[1]) - he[1]);
    const dz = @abs(@abs(d_vec[2]) - he[2]);

    if (dx < epsilon and dx <= dy and dx <= dz) {
        return if (d_vec[0] > 0) vec4.init(1, 0, 0, 0) else vec4.init(-1, 0, 0, 0);
    } else if (dy < epsilon and dy <= dz) {
        return if (d_vec[1] > 0) vec4.init(0, 1, 0, 0) else vec4.init(0, -1, 0, 0);
    } else {
        return if (d_vec[2] > 0) vec4.init(0, 0, 1, 0) else vec4.init(0, 0, -1, 0);
    }
}

// ===============
// AABB-AABB Overlap (re-export from aabb module for convenience)

pub fn aabbAABB(a: AABB, b: AABB) bool {
    return aabb_mod.overlaps(a, b);
}

// ===============
// Sphere-Sphere Overlap (re-export from sphere module for convenience)

pub fn sphereSphere(a: Sphere, b: Sphere) bool {
    return sphere_mod.overlapsSphere(a, b);
}

// ===============
// Tests - Ray-Sphere

test "raySphere - hit from outside" {
    // given
    const ray = ray_mod.from(vec4.init(-10, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const s = sphere_mod.from(vec4.init(0, 0, 0, 1), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 7.0), hit.?.t, 0.0001);
    try std.testing.expect(vec4.approxEqual(hit.?.point, vec4.init(-3, 0, 0, 1), 0.01));
    try std.testing.expect(vec4.approxEqual(hit.?.normal, vec4.init(-1, 0, 0, 0), 0.01));
}

test "raySphere - miss" {
    // given
    const ray = ray_mod.from(vec4.init(-10, 0, 0, 1), vec4.init(0, 1, 0, 0));
    const s = sphere_mod.from(vec4.init(0, 0, 0, 1), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit == null);
}

test "raySphere - ray origin inside sphere" {
    // given
    const ray = ray_mod.from(vec4.init(0, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const s = sphere_mod.from(vec4.init(0, 0, 0, 1), 5);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
}

test "raySphere - ray pointing away" {
    // given
    const ray = ray_mod.from(vec4.init(-10, 0, 0, 1), vec4.init(-1, 0, 0, 0));
    const s = sphere_mod.from(vec4.init(0, 0, 0, 1), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit == null);
}

test "raySphere - tangent hit" {
    // given
    const ray = ray_mod.from(vec4.init(-10, 3, 0, 1), vec4.init(1, 0, 0, 0));
    const s = sphere_mod.from(vec4.init(0, 0, 0, 1), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 10.0), hit.?.t, 0.001);
}

// ===============
// Tests - Ray-Plane

test "rayPlane - hits plane from front" {
    // given
    const ray = ray_mod.from(vec4.init(0, 5, 0, 1), vec4.init(0, -1, 0, 0));
    const p = plane_mod.fromPointNormal(vec4.init(0, 0, 0, 1), vec4.init(0, 1, 0, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
    try std.testing.expect(vec4.approxEqual(hit.?.point, vec4.init(0, 0, 0, 1), 0.01));
}

test "rayPlane - hits plane from back" {
    // given
    const ray = ray_mod.from(vec4.init(0, -5, 0, 1), vec4.init(0, 1, 0, 0));
    const p = plane_mod.fromPointNormal(vec4.init(0, 0, 0, 1), vec4.init(0, 1, 0, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
}

test "rayPlane - parallel to plane" {
    // given
    const ray = ray_mod.from(vec4.init(0, 5, 0, 1), vec4.init(1, 0, 0, 0));
    const p = plane_mod.fromPointNormal(vec4.init(0, 0, 0, 1), vec4.init(0, 1, 0, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit == null);
}

test "rayPlane - plane behind ray" {
    // given
    const ray = ray_mod.from(vec4.init(0, 5, 0, 1), vec4.init(0, 1, 0, 0));
    const p = plane_mod.fromPointNormal(vec4.init(0, 0, 0, 1), vec4.init(0, 1, 0, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit == null);
}

// ===============
// Tests - Ray-AABB

test "rayAABB - hit from outside" {
    // given
    const ray = ray_mod.from(vec4.init(-5, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const box = aabb_mod.from(vec4.init(-1, -1, -1, 1), vec4.init(1, 1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 4.0), hit.?.t, 0.0001);
    try std.testing.expect(vec4.approxEqual(hit.?.point, vec4.init(-1, 0, 0, 1), 0.01));
}

test "rayAABB - miss" {
    // given
    const ray = ray_mod.from(vec4.init(-5, 5, 0, 1), vec4.init(1, 0, 0, 0));
    const box = aabb_mod.from(vec4.init(-1, -1, -1, 1), vec4.init(1, 1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}

test "rayAABB - ray origin inside box" {
    // given
    const ray = ray_mod.from(vec4.init(0, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const box = aabb_mod.from(vec4.init(-1, -1, -1, 1), vec4.init(1, 1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit != null);
}

test "rayAABB - ray pointing away" {
    // given
    const ray = ray_mod.from(vec4.init(-5, 0, 0, 1), vec4.init(-1, 0, 0, 0));
    const box = aabb_mod.from(vec4.init(-1, -1, -1, 1), vec4.init(1, 1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}

// ===============
// Tests - AABB-AABB

test "aabbAABB - true for overlapping" {
    // given
    const a = aabb_mod.from(vec4.init(0, 0, 0, 1), vec4.init(2, 2, 2, 1));
    const b = aabb_mod.from(vec4.init(1, 1, 1, 1), vec4.init(3, 3, 3, 1));

    // when / then
    try std.testing.expect(aabbAABB(a, b));
}

test "aabbAABB - false for separated" {
    // given
    const a = aabb_mod.from(vec4.init(0, 0, 0, 1), vec4.init(1, 1, 1, 1));
    const b = aabb_mod.from(vec4.init(2, 2, 2, 1), vec4.init(3, 3, 3, 1));

    // when / then
    try std.testing.expect(!aabbAABB(a, b));
}

// ===============
// Tests - Sphere-Sphere

test "sphereSphere - true for overlapping" {
    // given
    const a = sphere_mod.from(vec4.init(0, 0, 0, 1), 3);
    const b = sphere_mod.from(vec4.init(4, 0, 0, 1), 2);

    // when / then
    try std.testing.expect(sphereSphere(a, b));
}

test "sphereSphere - false for separated" {
    // given
    const a = sphere_mod.from(vec4.init(0, 0, 0, 1), 1);
    const b = sphere_mod.from(vec4.init(5, 0, 0, 1), 1);

    // when / then
    try std.testing.expect(!sphereSphere(a, b));
}
