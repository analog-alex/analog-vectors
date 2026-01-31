// @analogAlex
const std = @import("std");

pub const Vec4 = [4]f32;

// ===============
// Construction & Accessors

pub fn from(x: f32, y: f32, z: f32, w: f32) Vec4 {
    return [4]f32{ x, y, z, w };
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
    return [4]f32{ lhs[0] + rhs[0], lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3] };
}

pub fn sub(lhs: Vec4, rhs: Vec4) Vec4 {
    return [4]f32{ lhs[0] - rhs[0], lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3] };
}

pub fn mul(v: Vec4, scalar: f32) Vec4 {
    return [4]f32{ v[0] * scalar, v[1] * scalar, v[2] * scalar, v[3] * scalar };
}

pub fn div(v: Vec4, scalar: f32) Vec4 {
    return [4]f32{ v[0] / scalar, v[1] / scalar, v[2] / scalar, v[3] / scalar };
}

pub fn neg(v: Vec4) Vec4 {
    return [4]f32{ -v[0], -v[1], -v[2], -v[3] };
}

// ===============
// Length/Distance Operations

pub inline fn lengthSquared(v: Vec4) f32 {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2] + v[3] * v[3];
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
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

// ===============
// Interpolation & Clamping

pub fn lerp(a: Vec4, b: Vec4, t: f32) Vec4 {
    return [4]f32{
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
    };
}

pub fn clamp(v: Vec4, min_v: Vec4, max_v: Vec4) Vec4 {
    return [4]f32{
        @max(min_v[0], @min(max_v[0], v[0])),
        @max(min_v[1], @min(max_v[1], v[1])),
        @max(min_v[2], @min(max_v[2], v[2])),
        @max(min_v[3], @min(max_v[3], v[3])),
    };
}

// ===============
// Utility

pub fn equal(a: Vec4, b: Vec4) bool {
    return a[0] == b[0] and a[1] == b[1] and a[2] == b[2] and a[3] == b[3];
}

pub fn approxEqual(a: Vec4, b: Vec4, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and
        @abs(a[1] - b[1]) <= epsilon and
        @abs(a[2] - b[2]) <= epsilon and
        @abs(a[3] - b[3]) <= epsilon;
}

pub fn min(a: Vec4, b: Vec4) Vec4 {
    return [4]f32{
        @min(a[0], b[0]),
        @min(a[1], b[1]),
        @min(a[2], b[2]),
        @min(a[3], b[3]),
    };
}

pub fn max(a: Vec4, b: Vec4) Vec4 {
    return [4]f32{
        @max(a[0], b[0]),
        @max(a[1], b[1]),
        @max(a[2], b[2]),
        @max(a[3], b[3]),
    };
}

pub fn zero() Vec4 {
    return [4]f32{ 0, 0, 0, 0 };
}

pub fn one() Vec4 {
    return [4]f32{ 1, 1, 1, 1 };
}

pub fn unitX() Vec4 {
    return [4]f32{ 1, 0, 0, 0 };
}

pub fn unitY() Vec4 {
    return [4]f32{ 0, 1, 0, 0 };
}

pub fn unitZ() Vec4 {
    return [4]f32{ 0, 0, 1, 0 };
}

pub fn unitW() Vec4 {
    return [4]f32{ 0, 0, 0, 1 };
}

// ===============
// Tests

test "X returns the first coordinate" {
    const v = from(1, 2, 3, 4);
    const x = X(v);
    try std.testing.expect(x == 1);
}

test "Y returns the second coordinate" {
    const v = from(1, 2, 3, 4);
    const y = Y(v);
    try std.testing.expect(y == 2);
}

test "Z returns the third coordinate" {
    const v = from(1, 2, 3, 4);
    const z = Z(v);
    try std.testing.expect(z == 3);
}

test "W returns the fourth coordinate" {
    const v = from(1, 2, 3, 4);
    const w = W(v);
    try std.testing.expect(w == 4);
}

test "sum - can sum vectors" {
    const l = from(1, 2, 3, 4);
    const r = from(2, 4, 6, 8);
    const result = sum(l, r);
    try std.testing.expect(equal(result, from(3, 6, 9, 12)));
}

test "sub - can subtract vectors" {
    const l = from(5, 7, 9, 11);
    const r = from(2, 3, 4, 5);
    const result = sub(l, r);
    try std.testing.expect(equal(result, from(3, 4, 5, 6)));
}

test "mul - can multiply vector by scalar" {
    const v = from(2, 3, 4, 5);
    const scalar: f32 = 3;
    const result = mul(v, scalar);
    try std.testing.expect(equal(result, from(6, 9, 12, 15)));
}

test "div - can divide vector by scalar" {
    const v = from(6, 9, 12, 15);
    const scalar: f32 = 3;
    const result = div(v, scalar);
    try std.testing.expect(equal(result, from(2, 3, 4, 5)));
}

test "neg - can negate vector" {
    const v = from(2, -3, 4, -5);
    const result = neg(v);
    try std.testing.expect(equal(result, from(-2, 3, -4, 5)));
}

test "length - calculates magnitude" {
    const v = from(2, 2, 1, 0);
    const result = length(v);
    try std.testing.expect(result == 3);
}

test "normalize - creates unit vector" {
    const v = from(2, 2, 1, 0);
    const result = normalize(v);
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "dot - calculates dot product" {
    const a = from(1, 2, 3, 4);
    const b = from(5, 6, 7, 8);
    const result = dot(a, b);
    try std.testing.expect(result == 70);
}

test "lerp - interpolates at t=0.5" {
    const a = from(0, 0, 0, 0);
    const b = from(10, 20, 30, 40);
    const result = lerp(a, b, 0.5);
    try std.testing.expect(equal(result, from(5, 10, 15, 20)));
}

test "equal - returns true for equal vectors" {
    const a = from(1, 2, 3, 4);
    const b = from(1, 2, 3, 4);
    const result = equal(a, b);
    try std.testing.expect(result == true);
}

test "approxEqual - returns true for approximately equal vectors" {
    const a = from(1.0001, 2.0001, 3.0001, 4.0001);
    const b = from(1.0002, 2.0002, 3.0002, 4.0002);
    const result = approxEqual(a, b, 0.001);
    try std.testing.expect(result == true);
}
