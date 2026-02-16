// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Quat = [4]f32; // x, y, z, w

// ===============
// Construction & Accessors

/// Creates a quaternion from individual components (x, y, z, w)
pub fn from(x: f32, y: f32, z: f32, w: f32) Quat {
    return [4]f32{ x, y, z, w };
}

pub inline fn X(q: Quat) f32 {
    return q[0];
}

pub inline fn Y(q: Quat) f32 {
    return q[1];
}

pub inline fn Z(q: Quat) f32 {
    return q[2];
}

pub inline fn W(q: Quat) f32 {
    return q[3];
}

/// Returns the identity quaternion (no rotation)
pub fn identity() Quat {
    return [4]f32{ 0, 0, 0, 1 };
}

// ===============
// Axis-Angle Conversion

/// Creates a quaternion from an axis-angle representation
/// The axis should be normalized for correct results
pub fn fromAxisAngle(axis: vec3.Vec3, radians: f32) Quat {
    const half_angle = radians * 0.5;
    const s = @sin(half_angle);
    const c = @cos(half_angle);
    return [4]f32{ axis[0] * s, axis[1] * s, axis[2] * s, c };
}

/// Converts a quaternion to axis-angle representation
/// Returns the axis as a Vec3 and the angle in radians
/// For identity quaternion, returns (unitX, 0)
pub fn toAxisAngle(q: Quat) struct { axis: vec3.Vec3, angle: f32 } {
    const n = normalize(q);
    const half_angle = std.math.acos(@max(-1.0, @min(1.0, n[3])));
    const s = @sin(half_angle);

    if (s < 1e-6) {
        return .{ .axis = vec3.unitX(), .angle = 0 };
    }

    return .{
        .axis = vec3.from(n[0] / s, n[1] / s, n[2] / s),
        .angle = half_angle * 2.0,
    };
}

// ===============
// Quaternion Arithmetic

/// Multiplies two quaternions (Hamilton product)
/// This represents the composition of two rotations
pub fn multiply(lhs: Quat, rhs: Quat) Quat {
    return [4]f32{
        lhs[3] * rhs[0] + lhs[0] * rhs[3] + lhs[1] * rhs[2] - lhs[2] * rhs[1],
        lhs[3] * rhs[1] - lhs[0] * rhs[2] + lhs[1] * rhs[3] + lhs[2] * rhs[0],
        lhs[3] * rhs[2] + lhs[0] * rhs[1] - lhs[1] * rhs[0] + lhs[2] * rhs[3],
        lhs[3] * rhs[3] - lhs[0] * rhs[0] - lhs[1] * rhs[1] - lhs[2] * rhs[2],
    };
}

/// Returns the conjugate of a quaternion (negates the vector part)
pub fn conjugate(q: Quat) Quat {
    return [4]f32{ -q[0], -q[1], -q[2], q[3] };
}

/// Returns the inverse of a quaternion
/// For unit quaternions, the inverse equals the conjugate
pub fn inverse(q: Quat) Quat {
    const len_sq = lengthSquared(q);
    if (len_sq < 1e-12) return identity();
    const conj = conjugate(q);
    return [4]f32{ conj[0] / len_sq, conj[1] / len_sq, conj[2] / len_sq, conj[3] / len_sq };
}

// ===============
// Length Operations

pub inline fn dot(lhs: Quat, rhs: Quat) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

pub inline fn lengthSquared(q: Quat) f32 {
    return q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];
}

pub fn length(q: Quat) f32 {
    return @sqrt(lengthSquared(q));
}

pub fn normalize(q: Quat) Quat {
    const len = length(q);
    if (len == 0) return identity();
    return [4]f32{ q[0] / len, q[1] / len, q[2] / len, q[3] / len };
}

// ===============
// Interpolation

/// Linearly interpolates between two quaternions
/// Note: Does not preserve constant angular velocity. Use slerp for that.
pub fn lerp(a: Quat, b: Quat, t: f32) Quat {
    return [4]f32{
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
    };
}

/// Spherical linear interpolation between two quaternions
/// Produces constant angular velocity interpolation
/// Handles the double-cover issue (always takes shortest path)
pub fn slerp(a: Quat, b: Quat, t: f32) Quat {
    var cos_theta = dot(a, b);

    // If negative dot, negate one quaternion to take shortest path
    var b_adj = b;
    if (cos_theta < 0) {
        b_adj = [4]f32{ -b[0], -b[1], -b[2], -b[3] };
        cos_theta = -cos_theta;
    }

    // If quaternions are very close, fall back to normalized lerp
    if (cos_theta > 0.9995) {
        const result = lerp(a, b_adj, t);
        return normalize(result);
    }

    const theta = std.math.acos(@max(-1.0, @min(1.0, cos_theta)));
    const sin_theta = @sin(theta);

    const s0 = @sin((1.0 - t) * theta) / sin_theta;
    const s1 = @sin(t * theta) / sin_theta;

    return [4]f32{
        a[0] * s0 + b_adj[0] * s1,
        a[1] * s0 + b_adj[1] * s1,
        a[2] * s0 + b_adj[2] * s1,
        a[3] * s0 + b_adj[3] * s1,
    };
}

// ===============
// Vector Rotation

/// Rotates a Vec3 by this quaternion
/// Formula: v' = q * v * q^-1 (using quaternion sandwich product)
/// The quaternion should be normalized for correct results
pub fn rotateVec(q: Quat, v: vec3.Vec3) vec3.Vec3 {
    // Optimized rotation: v' = v + 2w(u × v) + 2(u × (u × v))
    // where u = (q.x, q.y, q.z) and w = q.w
    const u = vec3.from(q[0], q[1], q[2]);
    const uv = vec3.cross(u, v);
    const uuv = vec3.cross(u, uv);
    return vec3.sum(v, vec3.sum(vec3.mul(uv, 2 * q[3]), vec3.mul(uuv, 2)));
}

// ===============
// Utility

pub fn equal(a: Quat, b: Quat) bool {
    return a[0] == b[0] and a[1] == b[1] and a[2] == b[2] and a[3] == b[3];
}

pub fn approxEqual(a: Quat, b: Quat, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and
        @abs(a[1] - b[1]) <= epsilon and
        @abs(a[2] - b[2]) <= epsilon and
        @abs(a[3] - b[3]) <= epsilon;
}

// ===============
// Tests - Construction & Accessors

test "from - creates quaternion with correct components" {
    // given / when
    const q = from(1, 2, 3, 4);

    // then
    try std.testing.expect(X(q) == 1);
    try std.testing.expect(Y(q) == 2);
    try std.testing.expect(Z(q) == 3);
    try std.testing.expect(W(q) == 4);
}

test "identity - returns unit quaternion" {
    // when
    const q = identity();

    // then
    try std.testing.expect(equal(q, from(0, 0, 0, 1)));
}

// ===============
// Axis-Angle Tests

test "fromAxisAngle - 90 degree rotation around z-axis" {
    // given
    const axis = vec3.unitZ();
    const angle: f32 = std.math.pi / 2.0;

    // when
    const q = fromAxisAngle(axis, angle);

    // then
    const expected_s: f32 = @sin(std.math.pi / 4.0);
    const expected_c: f32 = @cos(std.math.pi / 4.0);
    try std.testing.expect(approxEqual(q, from(0, 0, expected_s, expected_c), 0.0001));
}

test "fromAxisAngle - zero angle returns identity" {
    // given
    const axis = vec3.unitX();

    // when
    const q = fromAxisAngle(axis, 0);

    // then
    try std.testing.expect(approxEqual(q, identity(), 0.0001));
}

test "toAxisAngle - recovers axis and angle" {
    // given
    const axis = vec3.unitY();
    const angle: f32 = std.math.pi / 3.0;
    const q = fromAxisAngle(axis, angle);

    // when
    const result = toAxisAngle(q);

    // then
    try std.testing.expect(vec3.approxEqual(result.axis, axis, 0.0001));
    try std.testing.expect(@abs(result.angle - angle) < 0.0001);
}

test "toAxisAngle - identity quaternion returns zero angle" {
    // given
    const q = identity();

    // when
    const result = toAxisAngle(q);

    // then
    try std.testing.expect(result.angle == 0);
}

test "fromAxisAngle - round trip preserves rotation" {
    // given
    const axis = vec3.normalize(vec3.from(1, 1, 1));
    const angle: f32 = std.math.pi / 4.0;

    // when
    const q = fromAxisAngle(axis, angle);
    const result = toAxisAngle(q);

    // then
    try std.testing.expect(vec3.approxEqual(result.axis, axis, 0.0001));
    try std.testing.expect(@abs(result.angle - angle) < 0.0001);
}

// ===============
// Arithmetic Tests

test "multiply - identity * q = q" {
    // given
    const q = fromAxisAngle(vec3.unitZ(), std.math.pi / 4.0);

    // when
    const result = multiply(identity(), q);

    // then
    try std.testing.expect(approxEqual(result, q, 0.0001));
}

test "multiply - q * identity = q" {
    // given
    const q = fromAxisAngle(vec3.unitZ(), std.math.pi / 4.0);

    // when
    const result = multiply(q, identity());

    // then
    try std.testing.expect(approxEqual(result, q, 0.0001));
}

test "multiply - composing two 90 degree rotations gives 180 degrees" {
    // given
    const q90 = fromAxisAngle(vec3.unitZ(), std.math.pi / 2.0);

    // when
    const q180 = multiply(q90, q90);

    // then
    const expected = fromAxisAngle(vec3.unitZ(), std.math.pi);
    try std.testing.expect(approxEqual(q180, expected, 0.0001));
}

test "conjugate - negates vector part" {
    // given
    const q = from(1, 2, 3, 4);

    // when
    const result = conjugate(q);

    // then
    try std.testing.expect(equal(result, from(-1, -2, -3, 4)));
}

test "conjugate - identity conjugate is identity" {
    // when
    const result = conjugate(identity());

    // then
    try std.testing.expect(equal(result, identity()));
}

test "inverse - q * q_inv = identity" {
    // given
    const q = normalize(from(1, 2, 3, 4));

    // when
    const q_inv = inverse(q);
    const result = multiply(q, q_inv);

    // then
    try std.testing.expect(approxEqual(result, identity(), 0.0001));
}

test "inverse - unit quaternion inverse equals conjugate" {
    // given
    const q = normalize(from(1, 2, 3, 4));

    // when
    const q_inv = inverse(q);
    const q_conj = conjugate(q);

    // then
    try std.testing.expect(approxEqual(q_inv, q_conj, 0.0001));
}

// ===============
// Length Tests

test "dot - calculates dot product" {
    // given
    const a = from(1, 2, 3, 4);
    const b = from(5, 6, 7, 8);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 70); // 5 + 12 + 21 + 32 = 70
}

test "lengthSquared - calculates squared magnitude" {
    // given
    const q = from(1, 2, 3, 4);

    // when
    const result = lengthSquared(q);

    // then
    try std.testing.expect(result == 30); // 1 + 4 + 9 + 16 = 30
}

test "length - identity has unit length" {
    // when
    const result = length(identity());

    // then
    try std.testing.expect(result == 1);
}

test "normalize - produces unit quaternion" {
    // given
    const q = from(1, 2, 3, 4);

    // when
    const result = normalize(q);

    // then
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "normalize - preserves direction" {
    // given
    const q = from(0, 0, 0, 2);

    // when
    const result = normalize(q);

    // then
    try std.testing.expect(approxEqual(result, from(0, 0, 0, 1), 0.0001));
}

// ===============
// Interpolation Tests

test "lerp - at t=0 returns first quaternion" {
    // given
    const a = from(0, 0, 0, 1);
    const b = from(1, 0, 0, 0);

    // when
    const result = lerp(a, b, 0);

    // then
    try std.testing.expect(equal(result, a));
}

test "lerp - at t=1 returns second quaternion" {
    // given
    const a = from(0, 0, 0, 1);
    const b = from(1, 0, 0, 0);

    // when
    const result = lerp(a, b, 1);

    // then
    try std.testing.expect(equal(result, b));
}

test "slerp - at t=0 returns first quaternion" {
    // given
    const a = identity();
    const b = fromAxisAngle(vec3.unitZ(), std.math.pi / 2.0);

    // when
    const result = slerp(a, b, 0);

    // then
    try std.testing.expect(approxEqual(result, a, 0.0001));
}

test "slerp - at t=1 returns second quaternion" {
    // given
    const a = identity();
    const b = fromAxisAngle(vec3.unitZ(), std.math.pi / 2.0);

    // when
    const result = slerp(a, b, 1);

    // then
    try std.testing.expect(approxEqual(result, b, 0.0001));
}

test "slerp - at t=0.5 returns halfway rotation" {
    // given
    const a = identity();
    const b = fromAxisAngle(vec3.unitZ(), std.math.pi / 2.0);

    // when
    const result = slerp(a, b, 0.5);

    // then
    const expected = fromAxisAngle(vec3.unitZ(), std.math.pi / 4.0);
    try std.testing.expect(approxEqual(result, expected, 0.0001));
}

test "slerp - result is always unit length" {
    // given
    const a = fromAxisAngle(vec3.unitX(), std.math.pi / 6.0);
    const b = fromAxisAngle(vec3.unitY(), std.math.pi / 3.0);

    // when
    const result = slerp(a, b, 0.3);

    // then
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "slerp - takes shortest path with negative dot" {
    // given
    const a = identity();
    const b = from(0, 0, 0, -1); // equivalent to identity but negated

    // when
    const result = slerp(a, b, 0.5);

    // then — should stay near identity (shortest path)
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
    try std.testing.expect(approxEqual(result, identity(), 0.0001));
}

// ===============
// Vector Rotation Tests

test "rotateVec - identity quaternion preserves vector" {
    // given
    const q = identity();
    const v = vec3.from(1, 2, 3);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, v, 0.0001));
}

test "rotateVec - 90 degrees around z rotates x to y" {
    // given
    const q = fromAxisAngle(vec3.unitZ(), std.math.pi / 2.0);
    const v = vec3.from(1, 0, 0);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 1, 0), 0.0001));
}

test "rotateVec - 90 degrees around x rotates y to z" {
    // given
    const q = fromAxisAngle(vec3.unitX(), std.math.pi / 2.0);
    const v = vec3.from(0, 1, 0);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 0, 1), 0.0001));
}

test "rotateVec - 90 degrees around y rotates z to x" {
    // given
    const q = fromAxisAngle(vec3.unitY(), std.math.pi / 2.0);
    const v = vec3.from(0, 0, 1);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, vec3.from(1, 0, 0), 0.0001));
}

test "rotateVec - 180 degree rotation" {
    // given
    const q = fromAxisAngle(vec3.unitZ(), std.math.pi);
    const v = vec3.from(1, 0, 0);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, vec3.from(-1, 0, 0), 0.0001));
}

test "rotateVec - preserves vector length" {
    // given
    const q = fromAxisAngle(vec3.normalize(vec3.from(1, 1, 1)), std.math.pi / 3.0);
    const v = vec3.from(2, 3, 6);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(@abs(vec3.length(result) - vec3.length(v)) < 0.0001);
}

test "rotateVec - full 360 rotation returns original" {
    // given
    const q = fromAxisAngle(vec3.unitY(), std.math.pi * 2.0);
    const v = vec3.from(2, 3, 4);

    // when
    const result = rotateVec(q, v);

    // then
    try std.testing.expect(vec3.approxEqual(result, v, 0.0001));
}

test "rotateVec - composed rotations match multiply" {
    // given
    const q1 = fromAxisAngle(vec3.unitX(), std.math.pi / 4.0);
    const q2 = fromAxisAngle(vec3.unitZ(), std.math.pi / 3.0);
    const v = vec3.from(1, 2, 3);

    // when — rotate by q1 then q2 vs multiply
    const step1 = rotateVec(q1, v);
    const sequential = rotateVec(q2, step1);
    const composed = multiply(q2, q1);
    const combined = rotateVec(composed, v);

    // then
    try std.testing.expect(vec3.approxEqual(sequential, combined, 0.0001));
}

// ===============
// Utility Tests

test "equal - returns true for equal quaternions" {
    // given
    const a = from(1, 2, 3, 4);
    const b = from(1, 2, 3, 4);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == true);
}

test "equal - returns false for different quaternions" {
    // given
    const a = from(1, 2, 3, 4);
    const b = from(1, 2, 3, 5);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == false);
}

test "approxEqual - returns true for approximately equal quaternions" {
    // given
    const a = from(1.0001, 2.0001, 3.0001, 4.0001);
    const b = from(1.0002, 2.0002, 3.0002, 4.0002);

    // when
    const result = approxEqual(a, b, 0.001);

    // then
    try std.testing.expect(result == true);
}

test "approxEqual - returns false when difference exceeds epsilon" {
    // given
    const a = from(1.0, 2.0, 3.0, 4.0);
    const b = from(1.1, 2.0, 3.0, 4.0);

    // when
    const result = approxEqual(a, b, 0.01);

    // then
    try std.testing.expect(result == false);
}
