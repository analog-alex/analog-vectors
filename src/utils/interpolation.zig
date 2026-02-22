const std = @import("std");
const math = std.math;

const math_utils = @import("math.zig");
const vec2 = @import("../vectors/vec2.zig");
const vec3 = @import("../vectors/vec3.zig");
const vec4 = @import("../vectors/vec4.zig");

/// Clamp a value between 0 and 1
inline fn clamp01(t: f32) f32 {
    return @max(0.0, @min(1.0, t));
}

// ===============
// Scalar Interpolation

/// Smootherstep interpolation (Ken Perlin's improved version)
/// 6t^5 - 15t^4 + 10t^3 — smoother than smoothstep with zero 1st and 2nd derivatives at edges
pub fn smootherstep(edge0: f32, edge1: f32, x: f32) f32 {
    const t = clamp01((x - edge0) / (edge1 - edge0));
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

/// Cubic Hermite interpolation between two values with tangents
/// p0: start value, p1: end value, m0: start tangent, m1: end tangent
pub fn hermite(p0: f32, p1: f32, m0: f32, m1: f32, t: f32) f32 {
    const t2 = t * t;
    const t3 = t2 * t;
    const h00 = 2.0 * t3 - 3.0 * t2 + 1.0;
    const h10 = t3 - 2.0 * t2 + t;
    const h01 = -2.0 * t3 + 3.0 * t2;
    const h11 = t3 - t2;
    return h00 * p0 + h10 * m0 + h01 * p1 + h11 * m1;
}

/// Quadratic Bezier interpolation
/// p0: start, p1: control point, p2: end
pub fn bezierQuadratic(p0: f32, p1: f32, p2: f32, t: f32) f32 {
    const inv_t = 1.0 - t;
    return inv_t * inv_t * p0 + 2.0 * inv_t * t * p1 + t * t * p2;
}

/// Cubic Bezier interpolation
/// p0: start, p1: control point 1, p2: control point 2, p3: end
pub fn bezierCubic(p0: f32, p1: f32, p2: f32, p3: f32, t: f32) f32 {
    const inv_t = 1.0 - t;
    const inv_t2 = inv_t * inv_t;
    const inv_t3 = inv_t2 * inv_t;
    const t2 = t * t;
    const t3 = t2 * t;
    return inv_t3 * p0 + 3.0 * inv_t2 * t * p1 + 3.0 * inv_t * t2 * p2 + t3 * p3;
}

/// Catmull-Rom spline interpolation
/// Passes smoothly through all four points; interpolates between p1 and p2
pub fn catmullRom(p0: f32, p1: f32, p2: f32, p3: f32, t: f32) f32 {
    const t2 = t * t;
    const t3 = t2 * t;
    return 0.5 * ((2.0 * p1) +
        (-p0 + p2) * t +
        (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
        (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3);
}

// ===============
// Vec2 Interpolation

/// Cubic Hermite interpolation for Vec2
pub fn hermiteVec2(p0: vec2.Vec2, p1: vec2.Vec2, m0: vec2.Vec2, m1: vec2.Vec2, t: f32) vec2.Vec2 {
    return vec2.init(
        hermite(vec2.X(p0), vec2.X(p1), vec2.X(m0), vec2.X(m1), t),
        hermite(vec2.Y(p0), vec2.Y(p1), vec2.Y(m0), vec2.Y(m1), t),
    );
}

/// Quadratic Bezier interpolation for Vec2
pub fn bezierQuadraticVec2(p0: vec2.Vec2, p1: vec2.Vec2, p2: vec2.Vec2, t: f32) vec2.Vec2 {
    return vec2.init(
        bezierQuadratic(vec2.X(p0), vec2.X(p1), vec2.X(p2), t),
        bezierQuadratic(vec2.Y(p0), vec2.Y(p1), vec2.Y(p2), t),
    );
}

/// Cubic Bezier interpolation for Vec2
pub fn bezierCubicVec2(p0: vec2.Vec2, p1: vec2.Vec2, p2: vec2.Vec2, p3: vec2.Vec2, t: f32) vec2.Vec2 {
    return vec2.init(
        bezierCubic(vec2.X(p0), vec2.X(p1), vec2.X(p2), vec2.X(p3), t),
        bezierCubic(vec2.Y(p0), vec2.Y(p1), vec2.Y(p2), vec2.Y(p3), t),
    );
}

/// Catmull-Rom spline interpolation for Vec2
pub fn catmullRomVec2(p0: vec2.Vec2, p1: vec2.Vec2, p2: vec2.Vec2, p3: vec2.Vec2, t: f32) vec2.Vec2 {
    return vec2.init(
        catmullRom(vec2.X(p0), vec2.X(p1), vec2.X(p2), vec2.X(p3), t),
        catmullRom(vec2.Y(p0), vec2.Y(p1), vec2.Y(p2), vec2.Y(p3), t),
    );
}

/// Smootherstep interpolation for Vec2
pub fn smootherstepVec2(edge0: vec2.Vec2, edge1: vec2.Vec2, x: vec2.Vec2) vec2.Vec2 {
    return vec2.init(
        smootherstep(vec2.X(edge0), vec2.X(edge1), vec2.X(x)),
        smootherstep(vec2.Y(edge0), vec2.Y(edge1), vec2.Y(x)),
    );
}

// ===============
// Vec3 Interpolation

/// Cubic Hermite interpolation for Vec3
pub fn hermiteVec3(p0: vec3.Vec3, p1: vec3.Vec3, m0: vec3.Vec3, m1: vec3.Vec3, t: f32) vec3.Vec3 {
    return vec3.init(
        hermite(vec3.X(p0), vec3.X(p1), vec3.X(m0), vec3.X(m1), t),
        hermite(vec3.Y(p0), vec3.Y(p1), vec3.Y(m0), vec3.Y(m1), t),
        hermite(vec3.Z(p0), vec3.Z(p1), vec3.Z(m0), vec3.Z(m1), t),
    );
}

/// Quadratic Bezier interpolation for Vec3
pub fn bezierQuadraticVec3(p0: vec3.Vec3, p1: vec3.Vec3, p2: vec3.Vec3, t: f32) vec3.Vec3 {
    return vec3.init(
        bezierQuadratic(vec3.X(p0), vec3.X(p1), vec3.X(p2), t),
        bezierQuadratic(vec3.Y(p0), vec3.Y(p1), vec3.Y(p2), t),
        bezierQuadratic(vec3.Z(p0), vec3.Z(p1), vec3.Z(p2), t),
    );
}

/// Cubic Bezier interpolation for Vec3
pub fn bezierCubicVec3(p0: vec3.Vec3, p1: vec3.Vec3, p2: vec3.Vec3, p3: vec3.Vec3, t: f32) vec3.Vec3 {
    return vec3.init(
        bezierCubic(vec3.X(p0), vec3.X(p1), vec3.X(p2), vec3.X(p3), t),
        bezierCubic(vec3.Y(p0), vec3.Y(p1), vec3.Y(p2), vec3.Y(p3), t),
        bezierCubic(vec3.Z(p0), vec3.Z(p1), vec3.Z(p2), vec3.Z(p3), t),
    );
}

/// Catmull-Rom spline interpolation for Vec3
pub fn catmullRomVec3(p0: vec3.Vec3, p1: vec3.Vec3, p2: vec3.Vec3, p3: vec3.Vec3, t: f32) vec3.Vec3 {
    return vec3.init(
        catmullRom(vec3.X(p0), vec3.X(p1), vec3.X(p2), vec3.X(p3), t),
        catmullRom(vec3.Y(p0), vec3.Y(p1), vec3.Y(p2), vec3.Y(p3), t),
        catmullRom(vec3.Z(p0), vec3.Z(p1), vec3.Z(p2), vec3.Z(p3), t),
    );
}

/// Smootherstep interpolation for Vec3
pub fn smootherstepVec3(edge0: vec3.Vec3, edge1: vec3.Vec3, x: vec3.Vec3) vec3.Vec3 {
    return vec3.init(
        smootherstep(vec3.X(edge0), vec3.X(edge1), vec3.X(x)),
        smootherstep(vec3.Y(edge0), vec3.Y(edge1), vec3.Y(x)),
        smootherstep(vec3.Z(edge0), vec3.Z(edge1), vec3.Z(x)),
    );
}

// ===============
// Vec4 Interpolation

/// Cubic Hermite interpolation for Vec4
pub fn hermiteVec4(p0: vec4.Vec4, p1: vec4.Vec4, m0: vec4.Vec4, m1: vec4.Vec4, t: f32) vec4.Vec4 {
    return vec4.init(
        hermite(vec4.X(p0), vec4.X(p1), vec4.X(m0), vec4.X(m1), t),
        hermite(vec4.Y(p0), vec4.Y(p1), vec4.Y(m0), vec4.Y(m1), t),
        hermite(vec4.Z(p0), vec4.Z(p1), vec4.Z(m0), vec4.Z(m1), t),
        hermite(vec4.W(p0), vec4.W(p1), vec4.W(m0), vec4.W(m1), t),
    );
}

/// Quadratic Bezier interpolation for Vec4
pub fn bezierQuadraticVec4(p0: vec4.Vec4, p1: vec4.Vec4, p2: vec4.Vec4, t: f32) vec4.Vec4 {
    return vec4.init(
        bezierQuadratic(vec4.X(p0), vec4.X(p1), vec4.X(p2), t),
        bezierQuadratic(vec4.Y(p0), vec4.Y(p1), vec4.Y(p2), t),
        bezierQuadratic(vec4.Z(p0), vec4.Z(p1), vec4.Z(p2), t),
        bezierQuadratic(vec4.W(p0), vec4.W(p1), vec4.W(p2), t),
    );
}

/// Cubic Bezier interpolation for Vec4
pub fn bezierCubicVec4(p0: vec4.Vec4, p1: vec4.Vec4, p2: vec4.Vec4, p3: vec4.Vec4, t: f32) vec4.Vec4 {
    return vec4.init(
        bezierCubic(vec4.X(p0), vec4.X(p1), vec4.X(p2), vec4.X(p3), t),
        bezierCubic(vec4.Y(p0), vec4.Y(p1), vec4.Y(p2), vec4.Y(p3), t),
        bezierCubic(vec4.Z(p0), vec4.Z(p1), vec4.Z(p2), vec4.Z(p3), t),
        bezierCubic(vec4.W(p0), vec4.W(p1), vec4.W(p2), vec4.W(p3), t),
    );
}

/// Catmull-Rom spline interpolation for Vec4
pub fn catmullRomVec4(p0: vec4.Vec4, p1: vec4.Vec4, p2: vec4.Vec4, p3: vec4.Vec4, t: f32) vec4.Vec4 {
    return vec4.init(
        catmullRom(vec4.X(p0), vec4.X(p1), vec4.X(p2), vec4.X(p3), t),
        catmullRom(vec4.Y(p0), vec4.Y(p1), vec4.Y(p2), vec4.Y(p3), t),
        catmullRom(vec4.Z(p0), vec4.Z(p1), vec4.Z(p2), vec4.Z(p3), t),
        catmullRom(vec4.W(p0), vec4.W(p1), vec4.W(p2), vec4.W(p3), t),
    );
}

/// Smootherstep interpolation for Vec4
pub fn smootherstepVec4(edge0: vec4.Vec4, edge1: vec4.Vec4, x: vec4.Vec4) vec4.Vec4 {
    return vec4.init(
        smootherstep(vec4.X(edge0), vec4.X(edge1), vec4.X(x)),
        smootherstep(vec4.Y(edge0), vec4.Y(edge1), vec4.Y(x)),
        smootherstep(vec4.Z(edge0), vec4.Z(edge1), vec4.Z(x)),
        smootherstep(vec4.W(edge0), vec4.W(edge1), vec4.W(x)),
    );
}

// ===============
// Tests

const expectApprox = std.testing.expectApproxEqAbs;
const eps: f32 = 0.001;

// -- Smootherstep Tests --

test "smootherstep - boundary values" {
    try expectApprox(@as(f32, 0.0), smootherstep(0.0, 1.0, 0.0), eps);
    try expectApprox(@as(f32, 1.0), smootherstep(0.0, 1.0, 1.0), eps);
    try expectApprox(@as(f32, 0.5), smootherstep(0.0, 1.0, 0.5), eps);
}

test "smootherstep - clamps outside range" {
    try expectApprox(@as(f32, 0.0), smootherstep(0.0, 1.0, -1.0), eps);
    try expectApprox(@as(f32, 1.0), smootherstep(0.0, 1.0, 2.0), eps);
}

test "smootherstep - custom range" {
    try expectApprox(@as(f32, 0.0), smootherstep(2.0, 8.0, 2.0), eps);
    try expectApprox(@as(f32, 1.0), smootherstep(2.0, 8.0, 8.0), eps);
    try expectApprox(@as(f32, 0.5), smootherstep(2.0, 8.0, 5.0), eps);
}

// -- Hermite Tests --

test "hermite - boundary values" {
    // At t=0, should return p0; at t=1, should return p1
    try expectApprox(@as(f32, 0.0), hermite(0.0, 10.0, 0.0, 0.0, 0.0), eps);
    try expectApprox(@as(f32, 10.0), hermite(0.0, 10.0, 0.0, 0.0, 1.0), eps);
}

test "hermite - with zero tangents equals smooth interpolation" {
    const mid = hermite(0.0, 1.0, 0.0, 0.0, 0.5);
    try expectApprox(@as(f32, 0.5), mid, eps);
}

test "hermite - tangents affect curve shape" {
    // Strong positive start tangent should push curve above linear
    const with_tangent = hermite(0.0, 0.0, 10.0, 0.0, 0.25);
    try std.testing.expect(with_tangent > 0.0);
}

// -- Bezier Quadratic Tests --

test "bezierQuadratic - boundary values" {
    try expectApprox(@as(f32, 0.0), bezierQuadratic(0.0, 5.0, 10.0, 0.0), eps);
    try expectApprox(@as(f32, 10.0), bezierQuadratic(0.0, 5.0, 10.0, 1.0), eps);
}

test "bezierQuadratic - linear when control point is midpoint" {
    // If control point is midpoint of start and end, curve is linear
    const mid = bezierQuadratic(0.0, 5.0, 10.0, 0.5);
    try expectApprox(@as(f32, 5.0), mid, eps);
}

test "bezierQuadratic - control point pulls curve" {
    // Control point above midpoint should pull curve up
    const val = bezierQuadratic(0.0, 10.0, 0.0, 0.5);
    try std.testing.expect(val > 0.0); // pulled toward control point
    try expectApprox(@as(f32, 5.0), val, eps);
}

// -- Bezier Cubic Tests --

test "bezierCubic - boundary values" {
    try expectApprox(@as(f32, 0.0), bezierCubic(0.0, 3.0, 7.0, 10.0, 0.0), eps);
    try expectApprox(@as(f32, 10.0), bezierCubic(0.0, 3.0, 7.0, 10.0, 1.0), eps);
}

test "bezierCubic - midpoint with symmetric control points" {
    const mid = bezierCubic(0.0, 5.0, 5.0, 10.0, 0.5);
    try expectApprox(@as(f32, 5.0), mid, eps);
}

// -- Catmull-Rom Tests --

test "catmullRom - passes through p1 and p2" {
    // At t=0, returns p1; at t=1, returns p2
    try expectApprox(@as(f32, 2.0), catmullRom(0.0, 2.0, 4.0, 6.0, 0.0), eps);
    try expectApprox(@as(f32, 4.0), catmullRom(0.0, 2.0, 4.0, 6.0, 1.0), eps);
}

test "catmullRom - midpoint of evenly spaced points" {
    // For evenly spaced points, midpoint should be average of p1 and p2
    const mid = catmullRom(0.0, 1.0, 2.0, 3.0, 0.5);
    try expectApprox(@as(f32, 1.5), mid, eps);
}

test "catmullRom - smooth curve through points" {
    // Result at t=0.5 should be close to midpoint of p1 and p2
    const mid = catmullRom(0.0, 10.0, 20.0, 30.0, 0.5);
    try expectApprox(@as(f32, 15.0), mid, eps);
}

// -- Vec2 Interpolation Tests --

test "hermiteVec2 - boundary values" {
    const p0 = vec2.init(0, 0);
    const p1 = vec2.init(10, 10);
    const m0 = vec2.zero();
    const m1 = vec2.zero();

    const at_start = hermiteVec2(p0, p1, m0, m1, 0.0);
    try std.testing.expect(vec2.approxEqual(at_start, p0, eps));

    const at_end = hermiteVec2(p0, p1, m0, m1, 1.0);
    try std.testing.expect(vec2.approxEqual(at_end, p1, eps));
}

test "bezierQuadraticVec2 - boundary values" {
    const p0 = vec2.init(0, 0);
    const p1 = vec2.init(5, 10);
    const p2 = vec2.init(10, 0);

    const at_start = bezierQuadraticVec2(p0, p1, p2, 0.0);
    try std.testing.expect(vec2.approxEqual(at_start, p0, eps));

    const at_end = bezierQuadraticVec2(p0, p1, p2, 1.0);
    try std.testing.expect(vec2.approxEqual(at_end, p2, eps));
}

test "bezierCubicVec2 - boundary values" {
    const p0 = vec2.init(0, 0);
    const p1 = vec2.init(2, 8);
    const p2 = vec2.init(8, 8);
    const p3 = vec2.init(10, 0);

    const at_start = bezierCubicVec2(p0, p1, p2, p3, 0.0);
    try std.testing.expect(vec2.approxEqual(at_start, p0, eps));

    const at_end = bezierCubicVec2(p0, p1, p2, p3, 1.0);
    try std.testing.expect(vec2.approxEqual(at_end, p3, eps));
}

test "catmullRomVec2 - passes through control points" {
    const p0 = vec2.init(0, 0);
    const p1 = vec2.init(1, 2);
    const p2 = vec2.init(3, 4);
    const p3 = vec2.init(4, 6);

    const at_p1 = catmullRomVec2(p0, p1, p2, p3, 0.0);
    try std.testing.expect(vec2.approxEqual(at_p1, p1, eps));

    const at_p2 = catmullRomVec2(p0, p1, p2, p3, 1.0);
    try std.testing.expect(vec2.approxEqual(at_p2, p2, eps));
}

// -- Vec3 Interpolation Tests --

test "hermiteVec3 - boundary values" {
    const p0 = vec3.init(0, 0, 0);
    const p1 = vec3.init(10, 10, 10);
    const m0 = vec3.zero();
    const m1 = vec3.zero();

    const at_start = hermiteVec3(p0, p1, m0, m1, 0.0);
    try std.testing.expect(vec3.approxEqual(at_start, p0, eps));

    const at_end = hermiteVec3(p0, p1, m0, m1, 1.0);
    try std.testing.expect(vec3.approxEqual(at_end, p1, eps));
}

test "bezierCubicVec3 - boundary values" {
    const p0 = vec3.init(0, 0, 0);
    const p1 = vec3.init(2, 8, 4);
    const p2 = vec3.init(8, 8, 4);
    const p3 = vec3.init(10, 0, 0);

    const at_start = bezierCubicVec3(p0, p1, p2, p3, 0.0);
    try std.testing.expect(vec3.approxEqual(at_start, p0, eps));

    const at_end = bezierCubicVec3(p0, p1, p2, p3, 1.0);
    try std.testing.expect(vec3.approxEqual(at_end, p3, eps));
}

test "catmullRomVec3 - passes through control points" {
    const p0 = vec3.init(0, 0, 0);
    const p1 = vec3.init(1, 2, 3);
    const p2 = vec3.init(3, 4, 5);
    const p3 = vec3.init(4, 6, 7);

    const at_p1 = catmullRomVec3(p0, p1, p2, p3, 0.0);
    try std.testing.expect(vec3.approxEqual(at_p1, p1, eps));

    const at_p2 = catmullRomVec3(p0, p1, p2, p3, 1.0);
    try std.testing.expect(vec3.approxEqual(at_p2, p2, eps));
}

// -- Vec4 Interpolation Tests --

test "hermiteVec4 - boundary values" {
    const p0 = vec4.init(0, 0, 0, 0);
    const p1 = vec4.init(10, 10, 10, 10);
    const m0 = vec4.zero();
    const m1 = vec4.zero();

    const at_start = hermiteVec4(p0, p1, m0, m1, 0.0);
    try std.testing.expect(vec4.approxEqual(at_start, p0, eps));

    const at_end = hermiteVec4(p0, p1, m0, m1, 1.0);
    try std.testing.expect(vec4.approxEqual(at_end, p1, eps));
}

test "catmullRomVec4 - passes through control points" {
    const p0 = vec4.init(0, 0, 0, 0);
    const p1 = vec4.init(1, 2, 3, 4);
    const p2 = vec4.init(3, 4, 5, 6);
    const p3 = vec4.init(4, 6, 7, 8);

    const at_p1 = catmullRomVec4(p0, p1, p2, p3, 0.0);
    try std.testing.expect(vec4.approxEqual(at_p1, p1, eps));

    const at_p2 = catmullRomVec4(p0, p1, p2, p3, 1.0);
    try std.testing.expect(vec4.approxEqual(at_p2, p2, eps));
}
