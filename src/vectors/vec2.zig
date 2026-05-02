// @analogAlex
const std = @import("std");

/// 2D vector type, represented as a fixed-size array `[2]f32` for performance and simplicity.
/// Components are accessible via `X()`, `Y()` or direct indexing `[0]`, `[1]`.
/// All operations use `f32` scalars.
pub const Vec2 = [2]f32;

// ===============
// Construction & Accessors

/// Creates a Vec2 from explicit x and y components.
/// This is the primary constructor.
///
/// Example usage (test-backed):
/// ```zig
/// const v = vec2.init(3.0, 4.0);
/// try std.testing.expectEqual(@as(f32, 3.0), v[0]);
/// ```
pub fn init(x: f32, y: f32) Vec2 {
    return [2]f32{ x, y };
}

/// Creates a Vec2 by copying from a `[2]f32` array.
/// Useful for interoperability with array-based APIs.
pub fn fromArray(values: [2]f32) Vec2 {
    return values;
}

/// Creates a Vec2 by truncating a Vec3 (drops the z component).
/// Equivalent to `init(v[0], v[1])`.
pub fn fromVec3(v: [3]f32) Vec2 {
    return init(v[0], v[1]);
}

/// Creates a Vec2 by truncating a Vec4 (drops z and w components).
/// Equivalent to `init(v[0], v[1])`.
pub fn fromVec4(v: @Vector(4, f32)) Vec2 {
    return init(v[0], v[1]);
}

/// Returns the X (first) component of the vector.
/// Inline hot-path accessor.
pub inline fn X(v: Vec2) f32 {
    return v[0];
}

/// Returns the Y (second) component of the vector.
/// Inline hot-path accessor.
pub inline fn Y(v: Vec2) f32 {
    return v[1];
}

// ===============
// Essential Arithmetic

/// Component-wise addition of two vectors.
/// Returns `lhs + rhs`.
pub fn sum(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] + rhs[0], lhs[1] + rhs[1] };
}

/// Component-wise subtraction of two vectors.
/// Returns `lhs - rhs`.
pub fn sub(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] - rhs[0], lhs[1] - rhs[1] };
}

/// Multiplies vector by a scalar.
/// Returns `v * scalar`.
pub fn mul(v: Vec2, scalar: f32) Vec2 {
    return [2]f32{ v[0] * scalar, v[1] * scalar };
}

/// Divides vector by a scalar (no zero-check; caller must ensure scalar != 0).
/// Returns `v / scalar`.
pub fn div(v: Vec2, scalar: f32) Vec2 {
    return [2]f32{ v[0] / scalar, v[1] / scalar };
}

/// Negates all components of the vector.
/// Returns `-v`.
pub fn neg(v: Vec2) Vec2 {
    return [2]f32{ -v[0], -v[1] };
}

/// Component-wise (Hadamard) product of two vectors.
/// Returns `[lhs[0]*rhs[0], lhs[1]*rhs[1]]`.
pub fn componentMul(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] * rhs[0], lhs[1] * rhs[1] };
}

/// Component-wise division of two vectors (no zero-check).
/// Returns `[lhs[0]/rhs[0], lhs[1]/rhs[1]]`.
pub fn componentDiv(lhs: Vec2, rhs: Vec2) Vec2 {
    return [2]f32{ lhs[0] / rhs[0], lhs[1] / rhs[1] };
}

// ===============
// Length/Distance Operations

/// Returns the squared Euclidean length (avoids sqrt for comparisons).
/// Equivalent to `dot(v, v)`.
pub inline fn lengthSquared(v: Vec2) f32 {
    return v[0] * v[0] + v[1] * v[1];
}

/// Returns the Euclidean length (magnitude) of the vector.
/// Uses `std.math.sqrt`.
pub fn length(v: Vec2) f32 {
    return @sqrt(lengthSquared(v));
}

/// Returns a unit vector in the same direction.
/// Edge case: zero vector returns `zero()` (avoids div-by-zero).
pub fn normalize(v: Vec2) Vec2 {
    const len = length(v);
    if (len == 0) return zero();
    return div(v, len);
}

/// Returns the Euclidean distance between points a and b.
pub fn distance(a: Vec2, b: Vec2) f32 {
    return length(sub(b, a));
}

/// Returns squared distance (avoids sqrt).
pub inline fn distanceSquared(a: Vec2, b: Vec2) f32 {
    return lengthSquared(sub(b, a));
}

// ===============
// Products

/// Dot (scalar) product of two vectors.
/// Returns `lhs · rhs` = |lhs|*|rhs|*cos(theta).
pub inline fn dot(lhs: Vec2, rhs: Vec2) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}

/// 2D cross product (scalar result, the z-component of 3D cross).
/// Returns the signed area of parallelogram; positive = lhs rotated CCW toward rhs.
pub inline fn cross(lhs: Vec2, rhs: Vec2) f32 {
    return lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

// ===============
// Geometric Projections

/// Projects vector `v` onto `onto`.
/// Returns the parallel component: `proj = (dot(v, onto) / |onto|^2) * onto`.
/// Edge case: zero `onto` returns `zero()`.
/// This is a key geometric utility; test-backed in "project" tests.
pub fn project(v: Vec2, onto: Vec2) Vec2 {
    const onto_len_sq = lengthSquared(onto);
    if (onto_len_sq == 0) return zero();
    const scalar = dot(v, onto) / onto_len_sq;
    return mul(onto, scalar);
}

/// Returns the rejection (perpendicular component) of `v` from `ref`.
/// Equivalent to `v - project(v, ref)`.
pub fn reject(v: Vec2, ref: Vec2) Vec2 {
    return sub(v, project(v, ref));
}

/// Reflects `v` across `normal` (assumes `normal` is unit length for correctness).
/// Formula: `v - 2 * dot(v, normal) * normal`.
pub fn reflect(v: Vec2, normal: Vec2) Vec2 {
    const d = dot(v, normal);
    return sub(v, mul(normal, 2 * d));
}

// ===============
// Interpolation & Clamping

/// Linear interpolation between `a` and `b` at parameter `t` (t in [0,1]).
/// Returns `a + (b - a) * t`. No clamping of t performed.
pub fn lerp(a: Vec2, b: Vec2, t: f32) Vec2 {
    return [2]f32{
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
    };
}

/// Component-wise clamp: each component of `v` is clamped to [min_v[i], max_v[i]].
pub fn clamp(v: Vec2, min_v: Vec2, max_v: Vec2) Vec2 {
    return [2]f32{
        @max(min_v[0], @min(max_v[0], v[0])),
        @max(min_v[1], @min(max_v[1], v[1])),
    };
}

// ===============
// Angle Operations

/// Returns the angle (in radians) of the vector from positive X axis.
/// Range: (-pi, pi]. Uses `std.math.atan2`.
pub fn angle(v: Vec2) f32 {
    return std.math.atan2(v[1], v[0]);
}

/// Returns the smallest angle (radians) between vectors `a` and `b`.
/// Result in [0, pi]. Handles zero-length gracefully (returns 0).
pub fn angleBetween(a: Vec2, b: Vec2) f32 {
    const dot_product = dot(a, b);
    const len_product = length(a) * length(b);
    if (len_product == 0) return 0;
    const cos_angle = dot_product / len_product;
    return std.math.acos(@max(-1.0, @min(1.0, cos_angle)));
}

/// Rotates vector `v` counter-clockwise by `radians`.
/// Uses 2D rotation matrix.
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

/// Exact equality (bitwise for floats; use `approxEqual` for tolerance).
pub fn equal(a: Vec2, b: Vec2) bool {
    return a[0] == b[0] and a[1] == b[1];
}

/// Approximate equality within `epsilon` per component.
/// Preferred for floating-point comparisons.
pub fn approxEqual(a: Vec2, b: Vec2, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and @abs(a[1] - b[1]) <= epsilon;
}

/// Component-wise minimum.
pub fn min(a: Vec2, b: Vec2) Vec2 {
    return [2]f32{
        @min(a[0], b[0]),
        @min(a[1], b[1]),
    };
}

/// Component-wise maximum.
pub fn max(a: Vec2, b: Vec2) Vec2 {
    return [2]f32{
        @max(a[0], b[0]),
        @max(a[1], b[1]),
    };
}

/// Returns the zero vector `(0, 0)`.
pub fn zero() Vec2 {
    return [2]f32{ 0, 0 };
}

/// Returns the one vector `(1, 1)`.
pub fn one() Vec2 {
    return [2]f32{ 1, 1 };
}

/// Returns the unit vector along X `(1, 0)`.
pub fn unitX() Vec2 {
    return [2]f32{ 1, 0 };
}

/// Returns the unit vector along Y `(0, 1)`.
pub fn unitY() Vec2 {
    return [2]f32{ 0, 1 };
}

// ===============
// tests

test "init creates a vector from components" {
    const v = init(1, 2);
    try std.testing.expect(equal(v, .{ 1, 2 }));
}

test "fromArray creates vec2 from array" {
    const v = fromArray(.{ 1, 2 });
    try std.testing.expect(equal(v, init(1, 2)));
}

test "fromVec3 creates vec2 by dropping z" {
    const v = fromVec3(.{ 1, 2, 3 });
    try std.testing.expect(equal(v, init(1, 2)));
}

test "fromVec4 creates vec2 by dropping z and w" {
    const v = fromVec4(@Vector(4, f32){ 1, 2, 3, 4 });
    try std.testing.expect(equal(v, init(1, 2)));
}

test "X return the first coordinate" {
    // given
    const v = init(1, 2);

    // when
    const x = X(v);

    // then
    try std.testing.expect(x == 1);
}

test "Y return the second coordinate" {
    // given
    const v = init(1, 2);

    // when
    const y = Y(v);

    // then
    try std.testing.expect(y == 2);
}

test "sum - can sum" {
    // given
    const l = init(1, 2);
    const r = init(2, 4);

    // when
    const result = sum(l, r);

    // then
    try std.testing.expect(equal(result, init(3, 6)));
}

// ===============
// Essential Arithmetic Tests

test "sub - can subtract vectors" {
    // given
    const l = init(5, 7);
    const r = init(2, 3);

    // when
    const result = sub(l, r);

    // then
    try std.testing.expect(equal(result, init(3, 4)));
}

test "mul - can multiply vector by scalar" {
    // given
    const v = init(2, 3);
    const scalar: f32 = 3;

    // when
    const result = mul(v, scalar);

    // then
    try std.testing.expect(equal(result, init(6, 9)));
}

test "div - can divide vector by scalar" {
    // given
    const v = init(6, 9);
    const scalar: f32 = 3;

    // when
    const result = div(v, scalar);

    // then
    try std.testing.expect(equal(result, init(2, 3)));
}

test "neg - can negate vector" {
    // given
    const v = init(2, -3);

    // when
    const result = neg(v);

    // then
    try std.testing.expect(equal(result, init(-2, 3)));
}

test "componentMul - multiplies components element-wise" {
    // given
    const a = init(2, 3);
    const b = init(4, 5);

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, init(8, 15)));
}

test "componentMul - handles zero vector" {
    // given
    const a = init(5, 7);
    const b = zero();

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "componentMul - handles one vector as identity" {
    // given
    const v = init(3, 4);
    const identity = one();

    // when
    const result = componentMul(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - divides components element-wise" {
    // given
    const a = init(8, 15);
    const b = init(2, 3);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(4, 5)));
}

test "componentDiv - handles one vector as identity" {
    // given
    const v = init(6, 9);
    const identity = one();

    // when
    const result = componentDiv(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - handles different divisors per component" {
    // given
    const a = init(10, 20);
    const b = init(2, 4);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(5, 5)));
}

// ===============
// Length/Distance Tests

test "lengthSquared - calculates squared magnitude" {
    // given
    const v = init(3, 4);

    // when
    const result = lengthSquared(v);

    // then
    try std.testing.expect(result == 25);
}

test "length - calculates magnitude using Pythagorean triple" {
    // given
    const v = init(3, 4);

    // when
    const result = length(v);

    // then
    try std.testing.expect(result == 5);
}

test "normalize - creates unit vector" {
    // given
    const v = init(3, 4);

    // when
    const result = normalize(v);

    // then
    try std.testing.expect(approxEqual(result, init(0.6, 0.8), 0.0001));
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
    const a = init(1, 2);
    const b = init(4, 6);

    // when
    const result = distance(a, b);

    // then
    try std.testing.expect(result == 5);
}

test "distanceSquared - calculates squared distance" {
    // given
    const a = init(1, 2);
    const b = init(4, 6);

    // when
    const result = distanceSquared(a, b);

    // then
    try std.testing.expect(result == 25);
}

// ===============
// Product Tests

test "dot - calculates dot product" {
    // given
    const a = init(2, 3);
    const b = init(4, 5);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 23);
}

test "dot - perpendicular vectors have zero dot product" {
    // given
    const a = init(1, 0);
    const b = init(0, 1);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "cross - calculates 2D cross product" {
    // given
    const a = init(2, 3);
    const b = init(4, 5);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(result == -2);
}

test "cross - parallel vectors have zero cross product" {
    // given
    const a = init(2, 4);
    const b = init(1, 2);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(result == 0);
}

// ===============
// Geometric Projection Tests

test "project - projects onto horizontal vector" {
    // given
    const v = init(3, 4);
    const onto = init(1, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(3, 0)));
}

test "project - projects onto vertical vector" {
    // given
    const v = init(3, 4);
    const onto = init(0, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 4)));
}

test "project - projects onto diagonal vector" {
    // given
    const v = init(4, 2);
    const onto = init(1, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(3, 3)));
}

test "project - handles zero onto vector" {
    // given
    const v = init(3, 4);
    const onto = zero();

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "project - parallel vectors project fully" {
    // given
    const v = init(6, 8);
    const onto = init(3, 4);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - returns perpendicular component to horizontal" {
    // given
    const v = init(3, 4);
    const ref = init(1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(0, 4)));
}

test "reject - returns perpendicular component to vertical" {
    // given
    const v = init(3, 4);
    const ref = init(0, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 0)));
}

test "reject - returns perpendicular component to diagonal" {
    // given
    const v = init(4, 2);
    const ref = init(1, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(1, -1)));
}

test "reject - returns original vector when ref is perpendicular" {
    // given
    const v = init(0, 5);
    const ref = init(1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - parallel vectors reject to zero" {
    // given
    const v = init(6, 8);
    const ref = init(3, 4);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(approxEqual(result, zero(), 0.0001));
}

test "reflect - reflects across horizontal normal" {
    // given
    const v = init(3, 4);
    const normal = init(0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, -4)));
}

test "reflect - reflects across vertical normal" {
    // given
    const v = init(3, 4);
    const normal = init(1, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(-3, 4)));
}

test "reflect - reflects across diagonal normal" {
    // given
    const v = init(1, 0);
    const sqrt2_inv: f32 = 1.0 / @sqrt(2.0);
    const normal = init(sqrt2_inv, sqrt2_inv);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(approxEqual(result, init(0, -1), 0.0001));
}

test "reflect - perpendicular vector reflects back" {
    // given
    const v = init(0, 5);
    const normal = init(0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(0, -5)));
}

test "reflect - preserves magnitude" {
    // given
    const v = init(3, 4);
    const normal = normalize(init(1, 1));

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
    const a = init(0, 0);
    const b = init(10, 10);

    // when
    const result = lerp(a, b, 0);

    // then
    try std.testing.expect(equal(result, a));
}

test "lerp - interpolates at t=1" {
    // given
    const a = init(0, 0);
    const b = init(10, 10);

    // when
    const result = lerp(a, b, 1);

    // then
    try std.testing.expect(equal(result, b));
}

test "lerp - interpolates at t=0.5" {
    // given
    const a = init(0, 0);
    const b = init(10, 20);

    // when
    const result = lerp(a, b, 0.5);

    // then
    try std.testing.expect(equal(result, init(5, 10)));
}

test "clamp - clamps vector to bounds" {
    // given
    const v = init(-5, 15);
    const min_v = init(0, 0);
    const max_v = init(10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, init(0, 10)));
}

test "clamp - vector within bounds unchanged" {
    // given
    const v = init(5, 5);
    const min_v = init(0, 0);
    const max_v = init(10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, v));
}

// ===============
// Angle Tests

test "angle - calculates angle for positive x-axis" {
    // given
    const v = init(1, 0);

    // when
    const result = angle(v);

    // then
    try std.testing.expect(result == 0);
}

test "angle - calculates angle for positive y-axis" {
    // given
    const v = init(0, 1);

    // when
    const result = angle(v);

    // then
    const expected = std.math.pi / 2.0;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angle - calculates angle for negative x-axis" {
    // given
    const v = init(-1, 0);

    // when
    const result = angle(v);

    // then
    const expected = std.math.pi;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - calculates angle between perpendicular vectors" {
    // given
    const a = init(1, 0);
    const b = init(0, 1);

    // when
    const result = angleBetween(a, b);

    // then
    const expected = std.math.pi / 2.0;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - calculates angle between parallel vectors" {
    // given
    const a = init(1, 0);
    const b = init(2, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(@abs(result - 0.0) < 0.0001);
}

test "angleBetween - handles zero vector" {
    // given
    const a = zero();
    const b = init(1, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "rotate - rotates 90 degrees counterclockwise" {
    // given
    const v = init(1, 0);
    const radians: f32 = std.math.pi / 2.0;

    // when
    const result = rotate(v, radians);

    // then
    try std.testing.expect(approxEqual(result, init(0, 1), 0.0001));
}

test "rotate - rotates 180 degrees" {
    // given
    const v = init(1, 0);
    const radians: f32 = std.math.pi;

    // when
    const result = rotate(v, radians);

    // then
    try std.testing.expect(approxEqual(result, init(-1, 0), 0.0001));
}

test "rotate - rotates 45 degrees" {
    // given
    const v = init(1, 0);
    const radians: f32 = std.math.pi / 4.0;

    // when
    const result = rotate(v, radians);

    // then
    const sqrt2_inv: f32 = 1.0 / @sqrt(2.0);
    try std.testing.expect(approxEqual(result, init(sqrt2_inv, sqrt2_inv), 0.0001));
}

// ===============
// Utility Tests

test "equal - returns true for equal vectors" {
    // given
    const a = init(1, 2);
    const b = init(1, 2);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == true);
}

test "equal - returns false for different vectors" {
    // given
    const a = init(1, 2);
    const b = init(1, 3);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == false);
}

test "approxEqual - returns true for approximately equal vectors" {
    // given
    const a = init(1.0001, 2.0001);
    const b = init(1.0002, 2.0002);

    // when
    const result = approxEqual(a, b, 0.001);

    // then
    try std.testing.expect(result == true);
}

test "approxEqual - returns false when difference exceeds epsilon" {
    // given
    const a = init(1.0, 2.0);
    const b = init(1.1, 2.0);

    // when
    const result = approxEqual(a, b, 0.01);

    // then
    try std.testing.expect(result == false);
}

test "min - returns component-wise minimum" {
    // given
    const a = init(1, 5);
    const b = init(3, 2);

    // when
    const result = min(a, b);

    // then
    try std.testing.expect(equal(result, init(1, 2)));
}

test "max - returns component-wise maximum" {
    // given
    const a = init(1, 5);
    const b = init(3, 2);

    // when
    const result = max(a, b);

    // then
    try std.testing.expect(equal(result, init(3, 5)));
}

test "zero - returns zero vector" {
    // when
    const result = zero();

    // then
    try std.testing.expect(equal(result, init(0, 0)));
}

test "one - returns one vector" {
    // when
    const result = one();

    // then
    try std.testing.expect(equal(result, init(1, 1)));
}

test "unitX - returns (1, 0)" {
    // when
    const result = unitX();

    // then
    try std.testing.expect(equal(result, init(1, 0)));
    try std.testing.expect(X(result) == 1);
    try std.testing.expect(Y(result) == 0);
}

test "unitY - returns (0, 1)" {
    // when
    const result = unitY();

    // then
    try std.testing.expect(equal(result, init(0, 1)));
    try std.testing.expect(X(result) == 0);
    try std.testing.expect(Y(result) == 1);
}
