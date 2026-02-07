// @analogAlex
const std = @import("std");

pub const Vec2 = [2]f32;

// ===============
// Construction & Accessors

pub fn from(x: f32, y: f32) Vec2 {
    return [2]f32{ x, y };
}

pub inline fn X(v: Vec2) f32 {
    return v[0];
}

pub inline fn Y(v: Vec2) f32 {
    return v[1];
}

// ===============
// Essential Arithmetic

pub fn sum(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] + rhs[0], lhs[1] + rhs[1] };
}

pub fn sub(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] - rhs[0], lhs[1] - rhs[1] };
}

pub fn mul(v: Vec2, scalar: f32) Vec2 {
    return [2]f32{ v[0] * scalar, v[1] * scalar };
}

pub fn div(v: Vec2, scalar: f32) Vec2 {
    return [2]f32{ v[0] / scalar, v[1] / scalar };
}

pub fn neg(v: Vec2) Vec2 {
    return [2]f32{ -v[0], -v[1] };
}

// ===============
// Length/Distance Operations

pub inline fn lengthSquared(v: Vec2) f32 {
    return v[0] * v[0] + v[1] * v[1];
}

pub fn length(v: Vec2) f32 {
    return @sqrt(lengthSquared(v));
}

pub fn normalize(v: Vec2) Vec2 {
    const len = length(v);
    if (len == 0) return zero();
    return div(v, len);
}

pub fn distance(a: Vec2, b: Vec2) f32 {
    return length(sub(b, a));
}

pub inline fn distanceSquared(a: Vec2, b: Vec2) f32 {
    return lengthSquared(sub(b, a));
}

// ===============
// Products

pub inline fn dot(lhs: Vec2, rhs: Vec2) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}

pub inline fn cross(lhs: Vec2, rhs: Vec2) f32 {
    return lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

// ===============
// Geometric Projections

/// Projects vector v onto another vector
/// Returns the component of v that lies in the direction of onto
pub fn project(v: Vec2, onto: Vec2) Vec2 {
    const onto_len_sq = lengthSquared(onto);
    if (onto_len_sq == 0) return zero();
    const scalar = dot(v, onto) / onto_len_sq;
    return mul(onto, scalar);
}

/// Returns the rejection of v from another vector
/// This is the perpendicular component of v relative to ref
pub fn reject(v: Vec2, ref: Vec2) Vec2 {
    return sub(v, project(v, ref));
}

/// Reflects vector v across a normal vector
/// The normal should be normalized for correct results
pub fn reflect(v: Vec2, normal: Vec2) Vec2 {
    const d = dot(v, normal);
    return sub(v, mul(normal, 2 * d));
}

// ===============
// Interpolation & Clamping

pub fn lerp(a: Vec2, b: Vec2, t: f32) Vec2 {
    return [2]f32{
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
    };
}

pub fn clamp(v: Vec2, min_v: Vec2, max_v: Vec2) Vec2 {
    return [2]f32{
        @max(min_v[0], @min(max_v[0], v[0])),
        @max(min_v[1], @min(max_v[1], v[1])),
    };
}

// ===============
// Angle Operations

pub fn angle(v: Vec2) f32 {
    return std.math.atan2(v[1], v[0]);
}

pub fn angleBetween(a: Vec2, b: Vec2) f32 {
    const dot_product = dot(a, b);
    const len_product = length(a) * length(b);
    if (len_product == 0) return 0;
    const cos_angle = dot_product / len_product;
    return std.math.acos(@max(-1.0, @min(1.0, cos_angle)));
}

pub fn rotate(v: Vec2, radians: f32) Vec2 {
    const cos_r = @cos(radians);
    const sin_r = @sin(radians);
    return [2]f32{
        v[0] * cos_r - v[1] * sin_r,
        v[0] * sin_r + v[1] * cos_r,
    };
}

// ===============
// Utility

pub fn equal(a: Vec2, b: Vec2) bool {
    return a[0] == b[0] and a[1] == b[1];
}

pub fn approxEqual(a: Vec2, b: Vec2, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and @abs(a[1] - b[1]) <= epsilon;
}

pub fn min(a: Vec2, b: Vec2) Vec2 {
    return [2]f32{
        @min(a[0], b[0]),
        @min(a[1], b[1]),
    };
}

pub fn max(a: Vec2, b: Vec2) Vec2 {
    return [2]f32{
        @max(a[0], b[0]),
        @max(a[1], b[1]),
    };
}

pub fn zero() Vec2 {
    return [2]f32{ 0, 0 };
}

pub fn one() Vec2 {
    return [2]f32{ 1, 1 };
}

pub fn unitX() Vec2 {
    return [2]f32{ 1, 0 };
}

pub fn unitY() Vec2 {
    return [2]f32{ 0, 1 };
}

// ===============
// tests

test "X return the first coordinate" {
    // given
    const v = from(1, 2);

    // when
    const x = X(v);

    // then
    try std.testing.expect(x == 1);
}

test "Y return the second coordinate" {
    // given
    const v = from(1, 2);

    // when
    const y = Y(v);

    // then
    try std.testing.expect(y == 2);
}

test "sum - can sum" {
    // given
    const l = from(1, 2);
    const r = from(2, 4);

    // when
    const result = sum(l, r);

    // then
    try std.testing.expect(equal(result, from(3, 6)));
}

// ===============
// Essential Arithmetic Tests

test "sub - can subtract vectors" {
    // given
    const l = from(5, 7);
    const r = from(2, 3);

    // when
    const result = sub(l, r);

    // then
    try std.testing.expect(equal(result, from(3, 4)));
}

test "mul - can multiply vector by scalar" {
    // given
    const v = from(2, 3);
    const scalar: f32 = 3;

    // when
    const result = mul(v, scalar);

    // then
    try std.testing.expect(equal(result, from(6, 9)));
}

test "div - can divide vector by scalar" {
    // given
    const v = from(6, 9);
    const scalar: f32 = 3;

    // when
    const result = div(v, scalar);

    // then
    try std.testing.expect(equal(result, from(2, 3)));
}

test "neg - can negate vector" {
    // given
    const v = from(2, -3);

    // when
    const result = neg(v);

    // then
    try std.testing.expect(equal(result, from(-2, 3)));
}

// ===============
// Length/Distance Tests

test "lengthSquared - calculates squared magnitude" {
    // given
    const v = from(3, 4);

    // when
    const result = lengthSquared(v);

    // then
    try std.testing.expect(result == 25);
}

test "length - calculates magnitude using Pythagorean triple" {
    // given
    const v = from(3, 4);

    // when
    const result = length(v);

    // then
    try std.testing.expect(result == 5);
}

test "normalize - creates unit vector" {
    // given
    const v = from(3, 4);

    // when
    const result = normalize(v);

    // then
    try std.testing.expect(approxEqual(result, from(0.6, 0.8), 0.0001));
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "normalize - handles zero vector" {
    // given
    const v = zero();

    // when
    const result = normalize(v);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "distance - calculates Euclidean distance" {
    // given
    const a = from(1, 2);
    const b = from(4, 6);

    // when
    const result = distance(a, b);

    // then
    try std.testing.expect(result == 5);
}

test "distanceSquared - calculates squared distance" {
    // given
    const a = from(1, 2);
    const b = from(4, 6);

    // when
    const result = distanceSquared(a, b);

    // then
    try std.testing.expect(result == 25);
}

// ===============
// Product Tests

test "dot - calculates dot product" {
    // given
    const a = from(2, 3);
    const b = from(4, 5);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 23);
}

test "dot - perpendicular vectors have zero dot product" {
    // given
    const a = from(1, 0);
    const b = from(0, 1);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "cross - calculates 2D cross product" {
    // given
    const a = from(2, 3);
    const b = from(4, 5);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(result == -2);
}

test "cross - parallel vectors have zero cross product" {
    // given
    const a = from(2, 4);
    const b = from(1, 2);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(result == 0);
}

// ===============
// Geometric Projection Tests

test "project - projects onto horizontal vector" {
    // given
    const v = from(3, 4);
    const onto = from(1, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, from(3, 0)));
}

test "project - projects onto vertical vector" {
    // given
    const v = from(3, 4);
    const onto = from(0, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, from(0, 4)));
}

test "project - projects onto diagonal vector" {
    // given
    const v = from(4, 2);
    const onto = from(1, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, from(3, 3)));
}

test "project - handles zero onto vector" {
    // given
    const v = from(3, 4);
    const onto = zero();

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "project - parallel vectors project fully" {
    // given
    const v = from(6, 8);
    const onto = from(3, 4);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - returns perpendicular component to horizontal" {
    // given
    const v = from(3, 4);
    const ref = from(1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, from(0, 4)));
}

test "reject - returns perpendicular component to vertical" {
    // given
    const v = from(3, 4);
    const ref = from(0, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, from(3, 0)));
}

test "reject - returns perpendicular component to diagonal" {
    // given
    const v = from(4, 2);
    const ref = from(1, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, from(1, -1)));
}

test "reject - returns original vector when ref is perpendicular" {
    // given
    const v = from(0, 5);
    const ref = from(1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - parallel vectors reject to zero" {
    // given
    const v = from(6, 8);
    const ref = from(3, 4);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(approxEqual(result, zero(), 0.0001));
}

test "reflect - reflects across horizontal normal" {
    // given
    const v = from(3, 4);
    const normal = from(0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, from(3, -4)));
}

test "reflect - reflects across vertical normal" {
    // given
    const v = from(3, 4);
    const normal = from(1, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, from(-3, 4)));
}

test "reflect - reflects across diagonal normal" {
    // given
    const v = from(1, 0);
    const sqrt2_inv: f32 = 1.0 / @sqrt(2.0);
    const normal = from(sqrt2_inv, sqrt2_inv);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(approxEqual(result, from(0, -1), 0.0001));
}

test "reflect - perpendicular vector reflects back" {
    // given
    const v = from(0, 5);
    const normal = from(0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, from(0, -5)));
}

test "reflect - preserves magnitude" {
    // given
    const v = from(3, 4);
    const normal = normalize(from(1, 1));

    // when
    const result = reflect(v, normal);

    // then
    const original_len = length(v);
    const reflected_len = length(result);
    try std.testing.expect(@abs(original_len - reflected_len) < 0.0001);
}

// ===============
// Interpolation & Clamping Tests

test "lerp - interpolates at t=0" {
    // given
    const a = from(0, 0);
    const b = from(10, 10);

    // when
    const result = lerp(a, b, 0);

    // then
    try std.testing.expect(equal(result, a));
}

test "lerp - interpolates at t=1" {
    // given
    const a = from(0, 0);
    const b = from(10, 10);

    // when
    const result = lerp(a, b, 1);

    // then
    try std.testing.expect(equal(result, b));
}

test "lerp - interpolates at t=0.5" {
    // given
    const a = from(0, 0);
    const b = from(10, 20);

    // when
    const result = lerp(a, b, 0.5);

    // then
    try std.testing.expect(equal(result, from(5, 10)));
}

test "clamp - clamps vector to bounds" {
    // given
    const v = from(-5, 15);
    const min_v = from(0, 0);
    const max_v = from(10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, from(0, 10)));
}

test "clamp - vector within bounds unchanged" {
    // given
    const v = from(5, 5);
    const min_v = from(0, 0);
    const max_v = from(10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, v));
}

// ===============
// Angle Tests

test "angle - calculates angle for positive x-axis" {
    // given
    const v = from(1, 0);

    // when
    const result = angle(v);

    // then
    try std.testing.expect(result == 0);
}

test "angle - calculates angle for positive y-axis" {
    // given
    const v = from(0, 1);

    // when
    const result = angle(v);

    // then
    const expected = std.math.pi / 2.0;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angle - calculates angle for negative x-axis" {
    // given
    const v = from(-1, 0);

    // when
    const result = angle(v);

    // then
    const expected = std.math.pi;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - calculates angle between perpendicular vectors" {
    // given
    const a = from(1, 0);
    const b = from(0, 1);

    // when
    const result = angleBetween(a, b);

    // then
    const expected = std.math.pi / 2.0;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - calculates angle between parallel vectors" {
    // given
    const a = from(1, 0);
    const b = from(2, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(@abs(result - 0.0) < 0.0001);
}

test "angleBetween - handles zero vector" {
    // given
    const a = zero();
    const b = from(1, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "rotate - rotates 90 degrees counterclockwise" {
    // given
    const v = from(1, 0);
    const radians: f32 = std.math.pi / 2.0;

    // when
    const result = rotate(v, radians);

    // then
    try std.testing.expect(approxEqual(result, from(0, 1), 0.0001));
}

test "rotate - rotates 180 degrees" {
    // given
    const v = from(1, 0);
    const radians: f32 = std.math.pi;

    // when
    const result = rotate(v, radians);

    // then
    try std.testing.expect(approxEqual(result, from(-1, 0), 0.0001));
}

test "rotate - rotates 45 degrees" {
    // given
    const v = from(1, 0);
    const radians: f32 = std.math.pi / 4.0;

    // when
    const result = rotate(v, radians);

    // then
    const sqrt2_inv: f32 = 1.0 / @sqrt(2.0);
    try std.testing.expect(approxEqual(result, from(sqrt2_inv, sqrt2_inv), 0.0001));
}

// ===============
// Utility Tests

test "equal - returns true for equal vectors" {
    // given
    const a = from(1, 2);
    const b = from(1, 2);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == true);
}

test "equal - returns false for different vectors" {
    // given
    const a = from(1, 2);
    const b = from(1, 3);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == false);
}

test "approxEqual - returns true for approximately equal vectors" {
    // given
    const a = from(1.0001, 2.0001);
    const b = from(1.0002, 2.0002);

    // when
    const result = approxEqual(a, b, 0.001);

    // then
    try std.testing.expect(result == true);
}

test "approxEqual - returns false when difference exceeds epsilon" {
    // given
    const a = from(1.0, 2.0);
    const b = from(1.1, 2.0);

    // when
    const result = approxEqual(a, b, 0.01);

    // then
    try std.testing.expect(result == false);
}

test "min - returns component-wise minimum" {
    // given
    const a = from(1, 5);
    const b = from(3, 2);

    // when
    const result = min(a, b);

    // then
    try std.testing.expect(equal(result, from(1, 2)));
}

test "max - returns component-wise maximum" {
    // given
    const a = from(1, 5);
    const b = from(3, 2);

    // when
    const result = max(a, b);

    // then
    try std.testing.expect(equal(result, from(3, 5)));
}

test "zero - returns zero vector" {
    // when
    const result = zero();

    // then
    try std.testing.expect(equal(result, from(0, 0)));
}

test "one - returns one vector" {
    // when
    const result = one();

    // then
    try std.testing.expect(equal(result, from(1, 1)));
}

test "unitX - returns (1, 0)" {
    // when
    const result = unitX();

    // then
    try std.testing.expect(equal(result, from(1, 0)));
    try std.testing.expect(X(result) == 1);
    try std.testing.expect(Y(result) == 0);
}

test "unitY - returns (0, 1)" {
    // when
    const result = unitY();

    // then
    try std.testing.expect(equal(result, from(0, 1)));
    try std.testing.expect(X(result) == 0);
    try std.testing.expect(Y(result) == 1);
}
