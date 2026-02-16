const std = @import("std");
const math = std.math;

// Vec2 utilities
const vec2 = @import("../vectors/vec2.zig");

// Vec3 utilities
const vec3 = @import("../vectors/vec3.zig");

// Vec4 utilities
const vec4 = @import("../vectors/vec4.zig");

/// Remap a value from one range to another
/// Maps value from range [from_min, from_max] to [to_min, to_max]
pub fn remap(value: f32, from_min: f32, from_max: f32, to_min: f32, to_max: f32) f32 {
    const normalized = (value - from_min) / (from_max - from_min);
    return to_min + normalized * (to_max - to_min);
}

/// Clamp a value between min and max
pub inline fn clamp(value: f32, min_val: f32, max_val: f32) f32 {
    return @max(min_val, @min(max_val, value));
}

/// Component-wise minimum of two Vec2
pub fn minVec2(a: vec2.Vec2, b: vec2.Vec2) vec2.Vec2 {
    return vec2.from(
        @min(vec2.X(a), vec2.X(b)),
        @min(vec2.Y(a), vec2.Y(b)),
    );
}

/// Component-wise maximum of two Vec2
pub fn maxVec2(a: vec2.Vec2, b: vec2.Vec2) vec2.Vec2 {
    return vec2.from(
        @max(vec2.X(a), vec2.X(b)),
        @max(vec2.Y(a), vec2.Y(b)),
    );
}

/// Component-wise minimum of two Vec3
pub fn minVec3(a: vec3.Vec3, b: vec3.Vec3) vec3.Vec3 {
    return vec3.from(
        @min(vec3.X(a), vec3.X(b)),
        @min(vec3.Y(a), vec3.Y(b)),
        @min(vec3.Z(a), vec3.Z(b)),
    );
}

/// Component-wise maximum of two Vec3
pub fn maxVec3(a: vec3.Vec3, b: vec3.Vec3) vec3.Vec3 {
    return vec3.from(
        @max(vec3.X(a), vec3.X(b)),
        @max(vec3.Y(a), vec3.Y(b)),
        @max(vec3.Z(a), vec3.Z(b)),
    );
}

/// Component-wise minimum of two Vec4
pub fn minVec4(a: vec4.Vec4, b: vec4.Vec4) vec4.Vec4 {
    return vec4.from(
        @min(vec4.X(a), vec4.X(b)),
        @min(vec4.Y(a), vec4.Y(b)),
        @min(vec4.Z(a), vec4.Z(b)),
        @min(vec4.W(a), vec4.W(b)),
    );
}

/// Component-wise maximum of two Vec4
pub fn maxVec4(a: vec4.Vec4, b: vec4.Vec4) vec4.Vec4 {
    return vec4.from(
        @max(vec4.X(a), vec4.X(b)),
        @max(vec4.Y(a), vec4.Y(b)),
        @max(vec4.Z(a), vec4.Z(b)),
        @max(vec4.W(a), vec4.W(b)),
    );
}

/// Return the Vec2 with smaller magnitude
pub fn minMagnitudeVec2(a: vec2.Vec2, b: vec2.Vec2) vec2.Vec2 {
    return if (vec2.lengthSquared(a) <= vec2.lengthSquared(b)) a else b;
}

/// Return the Vec2 with larger magnitude
pub fn maxMagnitudeVec2(a: vec2.Vec2, b: vec2.Vec2) vec2.Vec2 {
    return if (vec2.lengthSquared(a) >= vec2.lengthSquared(b)) a else b;
}

/// Return the Vec3 with smaller magnitude
pub fn minMagnitudeVec3(a: vec3.Vec3, b: vec3.Vec3) vec3.Vec3 {
    return if (vec3.lengthSquared(a) <= vec3.lengthSquared(b)) a else b;
}

/// Return the Vec3 with larger magnitude
pub fn maxMagnitudeVec3(a: vec3.Vec3, b: vec3.Vec3) vec3.Vec3 {
    return if (vec3.lengthSquared(a) >= vec3.lengthSquared(b)) a else b;
}

/// Return the Vec4 with smaller magnitude
pub fn minMagnitudeVec4(a: vec4.Vec4, b: vec4.Vec4) vec4.Vec4 {
    return if (vec4.lengthSquared(a) <= vec4.lengthSquared(b)) a else b;
}

/// Return the Vec4 with larger magnitude
pub fn maxMagnitudeVec4(a: vec4.Vec4, b: vec4.Vec4) vec4.Vec4 {
    return if (vec4.lengthSquared(a) >= vec4.lengthSquared(b)) a else b;
}

/// Linear interpolation between two values
pub inline fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

/// Smooth step interpolation (cubic Hermite)
pub fn smoothstep(edge0: f32, edge1: f32, x: f32) f32 {
    const t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
}

// Tests

test "remap maps values correctly" {
    // Map from [0, 10] to [0, 100]
    try std.testing.expectApproxEqAbs(0.0, remap(0, 0, 10, 0, 100), 0.01);
    try std.testing.expectApproxEqAbs(50.0, remap(5, 0, 10, 0, 100), 0.01);
    try std.testing.expectApproxEqAbs(100.0, remap(10, 0, 10, 0, 100), 0.01);

    // Map from [0, 1] to [-1, 1]
    try std.testing.expectApproxEqAbs(-1.0, remap(0, 0, 1, -1, 1), 0.01);
    try std.testing.expectApproxEqAbs(0.0, remap(0.5, 0, 1, -1, 1), 0.01);
    try std.testing.expectApproxEqAbs(1.0, remap(1, 0, 1, -1, 1), 0.01);
}

test "clamp constrains values" {
    try std.testing.expectEqual(@as(f32, 0), clamp(-1, 0, 10));
    try std.testing.expectEqual(@as(f32, 5), clamp(5, 0, 10));
    try std.testing.expectEqual(@as(f32, 10), clamp(15, 0, 10));
}

test "minVec2 and maxVec2 work component-wise" {
    const a = vec2.from(1, 5);
    const b = vec2.from(3, 2);

    const min_v = minVec2(a, b);
    try std.testing.expectEqual(@as(f32, 1), vec2.X(min_v));
    try std.testing.expectEqual(@as(f32, 2), vec2.Y(min_v));

    const max_v = maxVec2(a, b);
    try std.testing.expectEqual(@as(f32, 3), vec2.X(max_v));
    try std.testing.expectEqual(@as(f32, 5), vec2.Y(max_v));
}

test "minVec3 and maxVec3 work component-wise" {
    const a = vec3.from(1, 5, 2);
    const b = vec3.from(3, 2, 7);

    const min_v = minVec3(a, b);
    try std.testing.expectEqual(@as(f32, 1), vec3.X(min_v));
    try std.testing.expectEqual(@as(f32, 2), vec3.Y(min_v));
    try std.testing.expectEqual(@as(f32, 2), vec3.Z(min_v));

    const max_v = maxVec3(a, b);
    try std.testing.expectEqual(@as(f32, 3), vec3.X(max_v));
    try std.testing.expectEqual(@as(f32, 5), vec3.Y(max_v));
    try std.testing.expectEqual(@as(f32, 7), vec3.Z(max_v));
}

test "minVec4 and maxVec4 work component-wise" {
    const a = vec4.from(1, 5, 2, 8);
    const b = vec4.from(3, 2, 7, 4);

    const min_v = minVec4(a, b);
    try std.testing.expectEqual(@as(f32, 1), vec4.X(min_v));
    try std.testing.expectEqual(@as(f32, 2), vec4.Y(min_v));
    try std.testing.expectEqual(@as(f32, 2), vec4.Z(min_v));
    try std.testing.expectEqual(@as(f32, 4), vec4.W(min_v));

    const max_v = maxVec4(a, b);
    try std.testing.expectEqual(@as(f32, 3), vec4.X(max_v));
    try std.testing.expectEqual(@as(f32, 5), vec4.Y(max_v));
    try std.testing.expectEqual(@as(f32, 7), vec4.Z(max_v));
    try std.testing.expectEqual(@as(f32, 8), vec4.W(max_v));
}

test "minMagnitudeVec2 and maxMagnitudeVec2 compare by length" {
    const a = vec2.from(3, 4); // length = 5
    const b = vec2.from(1, 1); // length ≈ 1.41

    const min_v = minMagnitudeVec2(a, b);
    try std.testing.expectEqual(@as(f32, 1), vec2.X(min_v));
    try std.testing.expectEqual(@as(f32, 1), vec2.Y(min_v));

    const max_v = maxMagnitudeVec2(a, b);
    try std.testing.expectEqual(@as(f32, 3), vec2.X(max_v));
    try std.testing.expectEqual(@as(f32, 4), vec2.Y(max_v));
}

test "minMagnitudeVec3 and maxMagnitudeVec3 compare by length" {
    const a = vec3.from(2, 3, 6); // length = 7
    const b = vec3.from(1, 0, 0); // length = 1

    const min_v = minMagnitudeVec3(a, b);
    try std.testing.expectEqual(@as(f32, 1), vec3.X(min_v));
    try std.testing.expectEqual(@as(f32, 0), vec3.Y(min_v));
    try std.testing.expectEqual(@as(f32, 0), vec3.Z(min_v));

    const max_v = maxMagnitudeVec3(a, b);
    try std.testing.expectEqual(@as(f32, 2), vec3.X(max_v));
    try std.testing.expectEqual(@as(f32, 3), vec3.Y(max_v));
    try std.testing.expectEqual(@as(f32, 6), vec3.Z(max_v));
}

test "lerp interpolates correctly" {
    try std.testing.expectApproxEqAbs(0.0, lerp(0, 10, 0), 0.01);
    try std.testing.expectApproxEqAbs(5.0, lerp(0, 10, 0.5), 0.01);
    try std.testing.expectApproxEqAbs(10.0, lerp(0, 10, 1), 0.01);
}

test "smoothstep produces smooth interpolation" {
    try std.testing.expectApproxEqAbs(0.0, smoothstep(0, 1, 0), 0.01);
    try std.testing.expectApproxEqAbs(0.5, smoothstep(0, 1, 0.5), 0.01);
    try std.testing.expectApproxEqAbs(1.0, smoothstep(0, 1, 1), 0.01);

    // Values outside the range should be clamped
    try std.testing.expectApproxEqAbs(0.0, smoothstep(0, 1, -0.5), 0.01);
    try std.testing.expectApproxEqAbs(1.0, smoothstep(0, 1, 1.5), 0.01);
}
