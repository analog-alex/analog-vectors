// @analogAlex
const std = @import("std");

pub const Vec4 = @Vector(4, f32);

// ===============
// Construction & Accessors

pub fn init(x: f32, y: f32, z: f32, w: f32) Vec4 {
    return Vec4{ x, y, z, w };
}

pub fn fromArray(values: [4]f32) Vec4 {
    return init(values[0], values[1], values[2], values[3]);
}

pub fn fromVec2(v: [2]f32, z: f32, w: f32) Vec4 {
    return init(v[0], v[1], z, w);
}

pub fn fromVec3(v: [3]f32, w: f32) Vec4 {
    return init(v[0], v[1], v[2], w);
}

/// Deprecated: use init for direct component construction.
pub fn from(x: f32, y: f32, z: f32, w: f32) Vec4 {
    return init(x, y, z, w);
}

pub inline fn X(v: Vec4) f32 {
    return v[0];
}

pub inline fn Y(v: Vec4) f32 {
    return v[1];
}

pub inline fn Z(v: Vec4) f32 {
    return v[2];
}

pub inline fn W(v: Vec4) f32 {
    return v[3];
}

// ===============
// Essential Arithmetic

pub fn sum(lhs: Vec4, rhs: Vec4) Vec4 {
    return lhs + rhs;
}

pub fn sub(lhs: Vec4, rhs: Vec4) Vec4 {
    return lhs - rhs;
}

pub fn mul(v: Vec4, scalar: f32) Vec4 {
    return v * @as(Vec4, @splat(scalar));
}

pub fn div(v: Vec4, scalar: f32) Vec4 {
    return v / @as(Vec4, @splat(scalar));
}

pub fn neg(v: Vec4) Vec4 {
    return -v;
}

pub fn componentMul(lhs: Vec4, rhs: Vec4) Vec4 {
    return lhs * rhs;
}

pub fn componentDiv(lhs: Vec4, rhs: Vec4) Vec4 {
    return lhs / rhs;
}

// ===============
// Length/Distance Operations

pub inline fn lengthSquared(v: Vec4) f32 {
    return @reduce(.Add, v * v);
}

pub fn length(v: Vec4) f32 {
    return @sqrt(lengthSquared(v));
}

pub fn normalize(v: Vec4) Vec4 {
    const len = length(v);
    if (len == 0) return zero();
    return div(v, len);
}

pub fn distance(a: Vec4, b: Vec4) f32 {
    return length(sub(b, a));
}

pub inline fn distanceSquared(a: Vec4, b: Vec4) f32 {
    return lengthSquared(sub(b, a));
}

// ===============
// Products

pub inline fn dot(lhs: Vec4, rhs: Vec4) f32 {
    return @reduce(.Add, lhs * rhs);
}

// ===============
// Geometric Projections

/// Projects vector v onto another vector
/// Returns the component of v that lies in the direction of onto
pub fn project(v: Vec4, onto: Vec4) Vec4 {
    const onto_len_sq = lengthSquared(onto);
    if (onto_len_sq == 0) return zero();
    const scalar = dot(v, onto) / onto_len_sq;
    return mul(onto, scalar);
}

/// Returns the rejection of v from another vector
/// This is the perpendicular component of v relative to ref
pub fn reject(v: Vec4, ref: Vec4) Vec4 {
    return sub(v, project(v, ref));
}

/// Reflects vector v across a normal vector
/// The normal should be normalized for correct results
pub fn reflect(v: Vec4, normal: Vec4) Vec4 {
    const d = dot(v, normal);
    return sub(v, mul(normal, 2 * d));
}

// ===============
// Interpolation & Clamping

pub fn lerp(a: Vec4, b: Vec4, t: f32) Vec4 {
    const tv: Vec4 = @splat(t);
    return a + (b - a) * tv;
}

pub fn clamp(v: Vec4, min_v: Vec4, max_v: Vec4) Vec4 {
    return @min(max_v, @max(min_v, v));
}

// ===============
// Utility

pub fn equal(a: Vec4, b: Vec4) bool {
    return @reduce(.And, a == b);
}

pub fn approxEqual(a: Vec4, b: Vec4, epsilon: f32) bool {
    const eps: Vec4 = @splat(epsilon);
    return @reduce(.And, @abs(a - b) <= eps);
}

pub fn min(a: Vec4, b: Vec4) Vec4 {
    return @min(a, b);
}

pub fn max(a: Vec4, b: Vec4) Vec4 {
    return @max(a, b);
}

pub fn zero() Vec4 {
    return @splat(0);
}

pub fn one() Vec4 {
    return @splat(1);
}

pub fn unitX() Vec4 {
    return Vec4{ 1, 0, 0, 0 };
}

pub fn unitY() Vec4 {
    return Vec4{ 0, 1, 0, 0 };
}

pub fn unitZ() Vec4 {
    return Vec4{ 0, 0, 1, 0 };
}

pub fn unitW() Vec4 {
    return Vec4{ 0, 0, 0, 1 };
}

// ===============
// Tests

test "init creates a vector from components" {
    const v = init(1, 2, 3, 4);
    try std.testing.expect(equal(v, .{ 1, 2, 3, 4 }));
}

test "fromArray creates vec4 from array" {
    const v = fromArray(.{ 1, 2, 3, 4 });
    try std.testing.expect(equal(v, init(1, 2, 3, 4)));
}

test "fromVec2 creates vec4 by appending z and w" {
    const v = fromVec2(.{ 1, 2 }, 3, 4);
    try std.testing.expect(equal(v, init(1, 2, 3, 4)));
}

test "fromVec3 creates vec4 by appending w" {
    const v = fromVec3(.{ 1, 2, 3 }, 4);
    try std.testing.expect(equal(v, init(1, 2, 3, 4)));
}

test "from is a deprecated alias for init" {
    const v = from(1, 2, 3, 4);
    try std.testing.expect(equal(v, init(1, 2, 3, 4)));
}

test "X returns the first coordinate" {
    const v = init(1, 2, 3, 4);
    const x = X(v);
    try std.testing.expect(x == 1);
}

test "Y returns the second coordinate" {
    const v = init(1, 2, 3, 4);
    const y = Y(v);
    try std.testing.expect(y == 2);
}

test "Z returns the third coordinate" {
    const v = init(1, 2, 3, 4);
    const z = Z(v);
    try std.testing.expect(z == 3);
}

test "W returns the fourth coordinate" {
    const v = init(1, 2, 3, 4);
    const w = W(v);
    try std.testing.expect(w == 4);
}

test "sum - can sum vectors" {
    const l = init(1, 2, 3, 4);
    const r = init(2, 4, 6, 8);
    const result = sum(l, r);
    try std.testing.expect(equal(result, init(3, 6, 9, 12)));
}

test "sub - can subtract vectors" {
    const l = init(5, 7, 9, 11);
    const r = init(2, 3, 4, 5);
    const result = sub(l, r);
    try std.testing.expect(equal(result, init(3, 4, 5, 6)));
}

test "mul - can multiply vector by scalar" {
    const v = init(2, 3, 4, 5);
    const scalar: f32 = 3;
    const result = mul(v, scalar);
    try std.testing.expect(equal(result, init(6, 9, 12, 15)));
}

test "div - can divide vector by scalar" {
    const v = init(6, 9, 12, 15);
    const scalar: f32 = 3;
    const result = div(v, scalar);
    try std.testing.expect(equal(result, init(2, 3, 4, 5)));
}

test "neg - can negate vector" {
    const v = init(2, -3, 4, -5);
    const result = neg(v);
    try std.testing.expect(equal(result, init(-2, 3, -4, 5)));
}

test "componentMul - multiplies components element-wise" {
    // given
    const a = init(2, 3, 4, 5);
    const b = init(6, 7, 8, 9);

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, init(12, 21, 32, 45)));
}

test "componentMul - handles zero vector" {
    // given
    const a = init(5, 7, 9, 11);
    const b = zero();

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "componentMul - handles one vector as identity" {
    // given
    const v = init(3, 4, 5, 6);
    const identity = one();

    // when
    const result = componentMul(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - divides components element-wise" {
    // given
    const a = init(12, 21, 32, 45);
    const b = init(2, 3, 4, 5);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(6, 7, 8, 9)));
}

test "componentDiv - handles one vector as identity" {
    // given
    const v = init(6, 9, 12, 15);
    const identity = one();

    // when
    const result = componentDiv(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - handles different divisors per component" {
    // given
    const a = init(10, 20, 30, 40);
    const b = init(2, 4, 5, 8);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(5, 5, 6, 5)));
}

test "length - calculates magnitude" {
    const v = init(2, 2, 1, 0);
    const result = length(v);
    try std.testing.expect(result == 3);
}

test "normalize - creates unit vector" {
    const v = init(2, 2, 1, 0);
    const result = normalize(v);
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "dot - calculates dot product" {
    const a = init(1, 2, 3, 4);
    const b = init(5, 6, 7, 8);
    const result = dot(a, b);
    try std.testing.expect(result == 70);
}

// ===============
// Geometric Projection Tests

test "project - projects onto x-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const onto = init(1, 0, 0, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(3, 0, 0, 0)));
}

test "project - projects onto y-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const onto = init(0, 1, 0, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 4, 0, 0)));
}

test "project - projects onto z-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const onto = init(0, 0, 1, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 0, 5, 0)));
}

test "project - projects onto w-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const onto = init(0, 0, 0, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 0, 0, 6)));
}

test "project - projects onto diagonal vector" {
    // given
    const v = init(8, 4, 4, 4);
    const onto = init(1, 1, 1, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(5, 5, 5, 5)));
}

test "project - handles zero onto vector" {
    // given
    const v = init(3, 4, 5, 6);
    const onto = zero();

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "project - parallel vectors project fully" {
    // given
    const v = init(6, 8, 10, 12);
    const onto = init(3, 4, 5, 6);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - returns perpendicular component to x-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const ref = init(1, 0, 0, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(0, 4, 5, 6)));
}

test "reject - returns perpendicular component to y-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const ref = init(0, 1, 0, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 0, 5, 6)));
}

test "reject - returns perpendicular component to z-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const ref = init(0, 0, 1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 4, 0, 6)));
}

test "reject - returns perpendicular component to w-axis" {
    // given
    const v = init(3, 4, 5, 6);
    const ref = init(0, 0, 0, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 4, 5, 0)));
}

test "reject - returns perpendicular component to diagonal" {
    // given
    const v = init(8, 4, 4, 4);
    const ref = init(1, 1, 1, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, -1, -1, -1)));
}

test "reject - returns original vector when ref is perpendicular" {
    // given
    const v = init(0, 5, 0, 0);
    const ref = init(1, 0, 0, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - parallel vectors reject to zero" {
    // given
    const v = init(6, 8, 10, 12);
    const ref = init(3, 4, 5, 6);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(approxEqual(result, zero(), 0.0001));
}

test "reflect - reflects across x-axis normal" {
    // given
    const v = init(3, 4, 5, 6);
    const normal = init(1, 0, 0, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(-3, 4, 5, 6)));
}

test "reflect - reflects across y-axis normal" {
    // given
    const v = init(3, 4, 5, 6);
    const normal = init(0, 1, 0, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, -4, 5, 6)));
}

test "reflect - reflects across z-axis normal" {
    // given
    const v = init(3, 4, 5, 6);
    const normal = init(0, 0, 1, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, 4, -5, 6)));
}

test "reflect - reflects across w-axis normal" {
    // given
    const v = init(3, 4, 5, 6);
    const normal = init(0, 0, 0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, 4, 5, -6)));
}

test "reflect - reflects across diagonal normal" {
    // given
    const v = init(1, 0, 0, 0);
    const sqrt4_inv: f32 = 1.0 / 2.0;
    const normal = init(sqrt4_inv, sqrt4_inv, sqrt4_inv, sqrt4_inv);

    // when
    const result = reflect(v, normal);

    // then
    const expected_x: f32 = 1.0 - 2.0 * sqrt4_inv * sqrt4_inv;
    const expected_yzw: f32 = -2.0 * sqrt4_inv * sqrt4_inv;
    try std.testing.expect(approxEqual(result, init(expected_x, expected_yzw, expected_yzw, expected_yzw), 0.0001));
}

test "reflect - perpendicular vector reflects back" {
    // given
    const v = init(0, 5, 0, 0);
    const normal = init(0, 1, 0, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(0, -5, 0, 0)));
}

test "reflect - preserves magnitude" {
    // given
    const v = init(3, 4, 5, 6);
    const normal = normalize(init(1, 1, 1, 1));

    // when
    const result = reflect(v, normal);

    // then
    const original_len = length(v);
    const reflected_len = length(result);
    try std.testing.expect(@abs(original_len - reflected_len) < 0.0001);
}

// ===============
// Interpolation & Clamping Tests

test "lerp - interpolates at t=0.5" {
    const a = init(0, 0, 0, 0);
    const b = init(10, 20, 30, 40);
    const result = lerp(a, b, 0.5);
    try std.testing.expect(equal(result, init(5, 10, 15, 20)));
}

test "equal - returns true for equal vectors" {
    const a = init(1, 2, 3, 4);
    const b = init(1, 2, 3, 4);
    const result = equal(a, b);
    try std.testing.expect(result == true);
}

test "approxEqual - returns true for approximately equal vectors" {
    const a = init(1.0001, 2.0001, 3.0001, 4.0001);
    const b = init(1.0002, 2.0002, 3.0002, 4.0002);
    const result = approxEqual(a, b, 0.001);
    try std.testing.expect(result == true);
}
