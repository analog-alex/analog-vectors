// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");
const ray_mod = @import("ray.zig");
const sphere_mod = @import("sphere.zig");
const plane_mod = @import("plane.zig");
const aabb_mod = @import("aabb.zig");

pub const Vec3 = vec3.Vec3;
pub const Ray = ray_mod.Ray;
pub const Sphere = sphere_mod.Sphere;
pub const Plane = plane_mod.Plane;
pub const AABB = aabb_mod.AABB;

pub const HitRecord = struct {
    t: f32, // parameter along ray
    point: Vec3, // intersection point
    normal: Vec3, // surface normal at intersection
};

// ===============
// Ray-Sphere Intersection
// Uses the geometric/quadratic approach optimized to avoid computing the full quadratic
// when the ray origin is outside and pointing away.

pub fn raySphere(ray: Ray, s: Sphere) ?HitRecord {
    const oc = vec3.sub(ray.origin, s.center);
    const b = vec3.dot(oc, ray.direction);
    const c = vec3.dot(oc, oc) - s.radius * s.radius;

    // If origin is outside (c > 0) and ray points away (b > 0), no hit
    if (c > 0 and b > 0) return null;

    const discriminant = b * b - c;
    if (discriminant < 0) return null;

    const sqrt_disc = @sqrt(discriminant);
    var t = -b - sqrt_disc;

    // If t is negative, try the other root (ray starts inside sphere)
    if (t < 0) {
        t = -b + sqrt_disc;
        if (t < 0) return null;
    }

    const point = ray_mod.pointAt(ray, t);
    const normal = vec3.normalize(vec3.sub(point, s.center));
    return .{ .t = t, .point = point, .normal = normal };
}

// ===============
// Ray-Plane Intersection

pub fn rayPlane(ray: Ray, p: Plane) ?HitRecord {
    const denom = vec3.dot(p.normal, ray.direction);

    // Ray is parallel to plane
    if (@abs(denom) < 1e-6) return null;

    const t = -(vec3.dot(p.normal, ray.origin) + p.d) / denom;

    // Intersection behind ray origin
    if (t < 0) return null;

    const point = ray_mod.pointAt(ray, t);
    // Normal faces toward the ray
    const normal = if (denom < 0) p.normal else vec3.neg(p.normal);
    return .{ .t = t, .point = point, .normal = normal };
}

// ===============
// Ray-AABB Intersection (slab method)
// Uses Kay-Kajiya slab method — branch-free per-axis min/max.

pub fn rayAABB(ray: Ray, box: AABB) ?HitRecord {
    // Compute inverse direction to avoid divisions in the loop
    const inv_dir = vec3.init(
        if (ray.direction[0] != 0) 1.0 / ray.direction[0] else std.math.inf(f32),
        if (ray.direction[1] != 0) 1.0 / ray.direction[1] else std.math.inf(f32),
        if (ray.direction[2] != 0) 1.0 / ray.direction[2] else std.math.inf(f32),
    );

    const t1 = vec3.componentMul(vec3.sub(box.min, ray.origin), inv_dir);
    const t2 = vec3.componentMul(vec3.sub(box.max, ray.origin), inv_dir);

    const t_min_v = vec3.min(t1, t2);
    const t_max_v = vec3.max(t1, t2);

    const t_enter = @max(t_min_v[0], @max(t_min_v[1], t_min_v[2]));
    const t_exit = @min(t_max_v[0], @min(t_max_v[1], t_max_v[2]));

    if (t_enter > t_exit or t_exit < 0) return null;

    const t = if (t_enter >= 0) t_enter else t_exit;
    const point = ray_mod.pointAt(ray, t);

    // Compute normal from the face that was hit
    const normal = computeAABBNormal(box, point);

    return .{ .t = t, .point = point, .normal = normal };
}

fn computeAABBNormal(box: AABB, point: Vec3) Vec3 {
    const epsilon: f32 = 1e-4;
    const c = aabb_mod.center(box);
    const d = vec3.sub(point, c);
    const he = aabb_mod.halfExtents(box);

    // Determine which face was hit by finding the axis with the largest relative displacement
    const dx = @abs(@abs(d[0]) - he[0]);
    const dy = @abs(@abs(d[1]) - he[1]);
    const dz = @abs(@abs(d[2]) - he[2]);

    if (dx < epsilon and dx <= dy and dx <= dz) {
        return if (d[0] > 0) vec3.init(1, 0, 0) else vec3.init(-1, 0, 0);
    } else if (dy < epsilon and dy <= dz) {
        return if (d[1] > 0) vec3.init(0, 1, 0) else vec3.init(0, -1, 0);
    } else {
        return if (d[2] > 0) vec3.init(0, 0, 1) else vec3.init(0, 0, -1);
    }
}

// ===============
// Tests - Ray-Sphere

test "raySphere - hit from outside" {
    // given
    const ray = ray_mod.from(vec3.init(-10, 0, 0), vec3.init(1, 0, 0));
    const s = sphere_mod.from(vec3.init(0, 0, 0), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 7.0), hit.?.t, 0.0001);
    try std.testing.expect(vec3.approxEqual(hit.?.point, vec3.init(-3, 0, 0), 0.001));
    try std.testing.expect(vec3.approxEqual(hit.?.normal, vec3.init(-1, 0, 0), 0.001));
}

test "raySphere - miss" {
    // given
    const ray = ray_mod.from(vec3.init(-10, 0, 0), vec3.init(0, 1, 0));
    const s = sphere_mod.from(vec3.init(0, 0, 0), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit == null);
}

test "raySphere - ray origin inside sphere" {
    // given
    const ray = ray_mod.from(vec3.init(0, 0, 0), vec3.init(1, 0, 0));
    const s = sphere_mod.from(vec3.init(0, 0, 0), 5);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
}

test "raySphere - ray pointing away from sphere" {
    // given
    const ray = ray_mod.from(vec3.init(-10, 0, 0), vec3.init(-1, 0, 0));
    const s = sphere_mod.from(vec3.init(0, 0, 0), 3);

    // when
    const hit = raySphere(ray, s);

    // then
    try std.testing.expect(hit == null);
}

test "raySphere - tangent hit" {
    // given
    const ray = ray_mod.from(vec3.init(-10, 3, 0), vec3.init(1, 0, 0));
    const s = sphere_mod.from(vec3.init(0, 0, 0), 3);

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
    const ray = ray_mod.from(vec3.init(0, 5, 0), vec3.init(0, -1, 0));
    const p = plane_mod.fromPointNormal(vec3.init(0, 0, 0), vec3.init(0, 1, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
    try std.testing.expect(vec3.approxEqual(hit.?.point, vec3.init(0, 0, 0), 0.001));
}

test "rayPlane - hits plane from back" {
    // given
    const ray = ray_mod.from(vec3.init(0, -5, 0), vec3.init(0, 1, 0));
    const p = plane_mod.fromPointNormal(vec3.init(0, 0, 0), vec3.init(0, 1, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), hit.?.t, 0.0001);
}

test "rayPlane - parallel to plane" {
    // given
    const ray = ray_mod.from(vec3.init(0, 5, 0), vec3.init(1, 0, 0));
    const p = plane_mod.fromPointNormal(vec3.init(0, 0, 0), vec3.init(0, 1, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit == null);
}

test "rayPlane - plane behind ray" {
    // given
    const ray = ray_mod.from(vec3.init(0, 5, 0), vec3.init(0, 1, 0));
    const p = plane_mod.fromPointNormal(vec3.init(0, 0, 0), vec3.init(0, 1, 0));

    // when
    const hit = rayPlane(ray, p);

    // then
    try std.testing.expect(hit == null);
}

// ===============
// Tests - Ray-AABB

test "rayAABB - hit from outside" {
    // given
    const ray = ray_mod.from(vec3.init(-5, 0, 0), vec3.init(1, 0, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit != null);
    try std.testing.expectApproxEqAbs(@as(f32, 4.0), hit.?.t, 0.0001);
    try std.testing.expect(vec3.approxEqual(hit.?.point, vec3.init(-1, 0, 0), 0.01));
}

test "rayAABB - miss" {
    // given
    const ray = ray_mod.from(vec3.init(-5, 5, 0), vec3.init(1, 0, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}

test "rayAABB - ray origin inside box" {
    // given
    const ray = ray_mod.from(vec3.init(0, 0, 0), vec3.init(1, 0, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit != null);
}

test "rayAABB - diagonal hit" {
    // given
    const dir = vec3.normalize(vec3.init(1, 1, 1));
    const ray = ray_mod.fromRaw(vec3.init(-5, -5, -5), dir);
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit != null);
}

test "rayAABB - ray pointing away" {
    // given
    const ray = ray_mod.from(vec3.init(-5, 0, 0), vec3.init(-1, 0, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}

test "rayAABB - parallel direction on slab boundary currently misses (characterization)" {
    // given - ray is parallel to x slabs and starts on x-min face
    const ray = ray_mod.fromRaw(vec3.init(-1, 0, 0), vec3.init(0, 1, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}

test "rayAABB - parallel direction outside slab misses" {
    // given - ray is parallel to x slabs and starts outside x range
    const ray = ray_mod.fromRaw(vec3.init(-2, 0, 0), vec3.init(0, 1, 0));
    const box = aabb_mod.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));

    // when
    const hit = rayAABB(ray, box);

    // then
    try std.testing.expect(hit == null);
}
