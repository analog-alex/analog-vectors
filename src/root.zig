//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

// Export vec2 module for library consumers
pub const vec2 = @import("vectors/vec2.zig");

// Export vec3 module for library consumers
pub const vec3 = @import("vectors/vec3.zig");

// Export vec4 module for library consumers
pub const vec4 = @import("vectors/vec4.zig");

// Export mat2 module for library consumers
pub const mat2 = @import("matrices/mat2.zig");

// Export mat3 module for library consumers
pub const mat3 = @import("matrices/mat3.zig");

// Export mat4 module for library consumers
pub const mat4 = @import("matrices/mat4.zig");

// Export quat module for library consumers
pub const quat = @import("complex/quat.zig");

// Export geometry modules for library consumers
pub const ray = @import("geometry/ray.zig");
pub const segment = @import("geometry/segment.zig");
pub const plane = @import("geometry/plane.zig");
pub const aabb = @import("geometry/aabb.zig");
pub const obb = @import("geometry/obb.zig");
pub const sphere = @import("geometry/sphere.zig");
pub const capsule = @import("geometry/capsule.zig");
pub const frustum = @import("geometry/frustum.zig");
pub const intersect = @import("geometry/intersect.zig");

// Export SIMD geometry modules (Vec4-based) for library consumers
pub const simd_ray = @import("geometry_simd/ray.zig");
pub const simd_plane = @import("geometry_simd/plane.zig");
pub const simd_aabb = @import("geometry_simd/aabb.zig");
pub const simd_sphere = @import("geometry_simd/sphere.zig");
pub const simd_intersect = @import("geometry_simd/intersect.zig");
pub const simd_conversions = @import("geometry_simd/conversions.zig");

// Export utility modules for library consumers
pub const angle = @import("utils/angle.zig");
pub const color = @import("utils/color.zig");
pub const random = @import("utils/random.zig");
pub const constants = @import("utils/constants.zig");
pub const math_utils = @import("utils/math.zig");
pub const easing = @import("utils/easing.zig");
pub const interpolation = @import("utils/interpolation.zig");

test {
    std.testing.refAllDecls(@This());
}

test "vec2 module is accessible" {
    const v: vec2.Vec2 = vec2.init(3, 4);
    try std.testing.expect(vec2.length(v) == 5);
}

test "vec3 module is accessible" {
    const v: vec3.Vec3 = vec3.init(2, 3, 6);
    try std.testing.expect(vec3.length(v) == 7);
}

test "vec4 module is accessible" {
    const v: vec4.Vec4 = vec4.init(2, 2, 1, 0);
    try std.testing.expect(vec4.length(v) == 3);
}

test "mat2 module is accessible" {
    const m: mat2.Mat2 = mat2.identity();
    try std.testing.expect(mat2.determinant(m) == 1);
}

test "mat3 module is accessible" {
    const m: mat3.Mat3 = mat3.identity();
    try std.testing.expect(mat3.determinant(m) == 1);
}

test "mat4 module is accessible" {
    const m: mat4.Mat4 = mat4.identity();
    const v = vec3.init(1, 2, 3);
    const result = mat4.transformVec3(m, v);
    try std.testing.expect(vec3.equal(result, v));
}

test "quat module is accessible" {
    const q: quat.Quat = quat.identity();
    const v = vec3.init(1, 2, 3);
    const result = quat.rotateVec(q, v);
    try std.testing.expect(vec3.approxEqual(result, v, 0.0001));
}

test "angle module is accessible" {
    const rad = angle.degToRad(180);
    try std.testing.expectApproxEqAbs(std.math.pi, rad, 0.0001);
}

test "color module is accessible" {
    const red = color.RGBA.fromRgb(1, 0, 0);
    const hsv = color.rgbaToHsv(red);
    try std.testing.expectApproxEqAbs(0.0, hsv.h, 0.01);
}

test "random module is accessible" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();
    const val = random.randomFloat(rng, 0, 10);
    try std.testing.expect(val >= 0 and val <= 10);
}

test "constants module is accessible" {
    const zero = constants.vec2_zero;
    try std.testing.expectEqual(@as(f32, 0), zero[0]);
    try std.testing.expectEqual(@as(f32, 0), zero[1]);
}

test "math_utils module is accessible" {
    const result = math_utils.remap(5, 0, 10, 0, 100);
    try std.testing.expectApproxEqAbs(50.0, result, 0.01);
}

test "easing module is accessible" {
    const val = easing.easeInQuad(0.5);
    try std.testing.expectApproxEqAbs(0.25, val, 0.01);
}

test "interpolation module is accessible" {
    const val = interpolation.smootherstep(0.0, 1.0, 0.5);
    try std.testing.expectApproxEqAbs(0.5, val, 0.01);
}

test "ray module is accessible" {
    const r = ray.from(vec3.init(0, 0, 0), vec3.init(1, 0, 0));
    const p = ray.pointAt(r, 5);
    try std.testing.expect(vec3.approxEqual(p, vec3.init(5, 0, 0), 0.0001));
}

test "segment module is accessible" {
    const s = segment.from(vec3.init(0, 0, 0), vec3.init(10, 0, 0));
    try std.testing.expectApproxEqAbs(@as(f32, 10.0), segment.length(s), 0.0001);
}

test "plane module is accessible" {
    const p = plane.fromPointNormal(vec3.init(0, 0, 0), vec3.init(0, 1, 0));
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), plane.distanceToPoint(p, vec3.init(0, 5, 0)), 0.0001);
}

test "aabb module is accessible" {
    const box = aabb.from(vec3.init(-1, -1, -1), vec3.init(1, 1, 1));
    try std.testing.expect(aabb.containsPoint(box, vec3.init(0, 0, 0)));
}

test "obb module is accessible" {
    const box = obb.fromAxisAligned(vec3.init(0, 0, 0), vec3.init(5, 5, 5));
    try std.testing.expect(obb.containsPoint(box, vec3.init(0, 0, 0)));
}

test "sphere module is accessible" {
    const s = sphere.from(vec3.init(0, 0, 0), 5);
    try std.testing.expect(sphere.containsPoint(s, vec3.init(3, 4, 0)));
}

test "capsule module is accessible" {
    const c = capsule.from(vec3.init(0, 0, 0), vec3.init(0, 10, 0), 2);
    try std.testing.expect(capsule.containsPoint(c, vec3.init(0, 5, 0)));
}

test "frustum module is accessible" {
    const f = frustum.from(.{
        plane.fromPointNormal(vec3.init(0, 0, -10), vec3.init(0, 0, 1)),
        plane.fromPointNormal(vec3.init(0, 0, 10), vec3.init(0, 0, -1)),
        plane.fromPointNormal(vec3.init(-10, 0, 0), vec3.init(1, 0, 0)),
        plane.fromPointNormal(vec3.init(10, 0, 0), vec3.init(-1, 0, 0)),
        plane.fromPointNormal(vec3.init(0, 10, 0), vec3.init(0, -1, 0)),
        plane.fromPointNormal(vec3.init(0, -10, 0), vec3.init(0, 1, 0)),
    });
    try std.testing.expect(frustum.containsPoint(f, vec3.init(0, 0, 0)));
}

test "intersect module is accessible" {
    const r = ray.from(vec3.init(-10, 0, 0), vec3.init(1, 0, 0));
    const s = sphere.from(vec3.init(0, 0, 0), 3);
    const hit = intersect.raySphere(r, s);
    try std.testing.expect(hit != null);
}

test "simd_conversions module is accessible" {
    const v3 = vec3.init(1, 2, 3);
    const point = simd_conversions.vec3ToPoint(v3);
    try std.testing.expect(point[3] == 1);
    const dir = simd_conversions.vec3ToDir(v3);
    try std.testing.expect(dir[3] == 0);
    const back = simd_conversions.vec4ToVec3(point);
    try std.testing.expect(vec3.equal(back, v3));
}

test "simd_ray module is accessible" {
    const r = simd_ray.from(vec4.init(0, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const p = simd_ray.pointAt(r, 5);
    try std.testing.expect(vec4.approxEqual(p, vec4.init(5, 0, 0, 1), 0.0001));
}

test "simd_plane module is accessible" {
    const p = simd_plane.fromPointNormal(vec4.init(0, 0, 0, 1), vec4.init(0, 1, 0, 0));
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), simd_plane.distanceToPoint(p, vec4.init(0, 5, 0, 1)), 0.0001);
}

test "simd_aabb module is accessible" {
    const box = simd_aabb.from(vec4.init(-1, -1, -1, 1), vec4.init(1, 1, 1, 1));
    try std.testing.expect(simd_aabb.containsPoint(box, vec4.init(0, 0, 0, 1)));
}

test "simd_sphere module is accessible" {
    const s = simd_sphere.from(vec4.init(0, 0, 0, 1), 5);
    try std.testing.expect(simd_sphere.containsPoint(s, vec4.init(3, 4, 0, 1)));
}

test "simd_intersect module is accessible" {
    const r = simd_ray.from(vec4.init(-10, 0, 0, 1), vec4.init(1, 0, 0, 0));
    const s = simd_sphere.from(vec4.init(0, 0, 0, 1), 3);
    const hit = simd_intersect.raySphere(r, s);
    try std.testing.expect(hit != null);
}
