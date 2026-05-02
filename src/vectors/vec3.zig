// @analogAlex
const std = @import("std");

/// 3D vector type, represented as `[3]f32`.
/// Primary type for positions, directions, normals in 3D graphics.
/// Hot-path accessors: `X()`, `Y()`, `Z()`.
pub const Vec3 = [3]f32;

// ===============
// Construction & Accessors

/// Creates a Vec3 from x, y, z components.
/// Primary constructor. Test-backed example in root.zig accessibility test.
pub fn init(x: f32, y: f32, z: f32) Vec3 {
    return [3]f32{ x, y, z };
}

pub fn fromArray(values: [3]f32) Vec3 {
    return values;
}

pub fn fromVec2(v: [2]f32, z: f32) Vec3 {
    return init(v[0], v[1], z);
}

pub fn fromVec4(v: @Vector(4, f32)) Vec3 {
    return init(v[0], v[1], v[2]);
}

pub inline fn X(v: Vec3) f32 {
    return v[0];
}

pub inline fn Y(v: Vec3) f32 {
    return v[1];
}

pub inline fn Z(v: Vec3) f32 {
    return v[2];
}

// ===============
// Essential Arithmetic

/// Component-wise addition.
pub fn sum(lhs: Vec3, rhs: Vec3) Vec3 {
    return [3]f32{ lhs[0] + rhs[0], lhs[1] + rhs[1], lhs[2] + rhs[2] };
}

/// Component-wise subtraction.
pub fn sub(lhs: Vec3, rhs: Vec3) Vec3 {
    return [3]f32{ lhs[0] - rhs[0], lhs[1] - rhs[1], lhs[2] - rhs[2] };
}

/// Scalar multiplication.
pub fn mul(v: Vec3, scalar: f32) Vec3 {
    return [3]f32{ v[0] * scalar, v[1] * scalar, v[2] * scalar };
}

/// Scalar division (caller ensures scalar != 0).
pub fn div(v: Vec3, scalar: f32) Vec3 {
    return [3]f32{ v[0] / scalar, v[1] / scalar, v[2] / scalar };
}

/// Negation.
pub fn neg(v: Vec3) Vec3 {
    return [3]f32{ -v[0], -v[1], -v[2] };
}

/// Component-wise multiplication.
pub fn componentMul(lhs: Vec3, rhs: Vec3) Vec3 {
    return [3]f32{ lhs[0] * rhs[0], lhs[1] * rhs[1], lhs[2] * rhs[2] };
}

/// Component-wise division.
pub fn componentDiv(lhs: Vec3, rhs: Vec3) Vec3 {
    return [3]f32{ lhs[0] / rhs[0], lhs[1] / rhs[1], lhs[2] / rhs[2] };
}

// ===============
// Length/Distance Operations

pub inline fn lengthSquared(v: Vec3) f32 {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
}

pub fn length(v: Vec3) f32 {
    return @sqrt(lengthSquared(v));
}

pub fn normalize(v: Vec3) Vec3 {
    const len = length(v);
    if (len == 0) return zero();
    return div(v, len);
}

pub fn distance(a: Vec3, b: Vec3) f32 {
    return length(sub(b, a));
}

pub inline fn distanceSquared(a: Vec3, b: Vec3) f32 {
    return lengthSquared(sub(b, a));
}

// ===============
// Products

pub inline fn dot(lhs: Vec3, rhs: Vec3) f32 {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2];
}

/// Cross product of two 3D vectors. Returns a vector perpendicular to both input vectors.
/// Note: The magnitude of the result equals |a| * |b| * sin(theta), where theta is the angle between a and b.
pub inline fn cross(lhs: Vec3, rhs: Vec3) Vec3 {
    return [3]f32{
        lhs[1] * rhs[2] - lhs[2] * rhs[1],
        lhs[2] * rhs[0] - lhs[0] * rhs[2],
        lhs[0] * rhs[1] - lhs[1] * rhs[0],
    };
}

// ===============
// Geometric Projections

/// Projects vector v onto another vector
/// Returns the component of v that lies in the direction of onto
pub fn project(v: Vec3, onto: Vec3) Vec3 {
    const onto_len_sq = lengthSquared(onto);
    if (onto_len_sq == 0) return zero();
    const scalar = dot(v, onto) / onto_len_sq;
    return mul(onto, scalar);
}

/// Returns the rejection of v from another vector
/// This is the perpendicular component of v relative to ref
pub fn reject(v: Vec3, ref: Vec3) Vec3 {
    return sub(v, project(v, ref));
}

/// Reflects vector v across a normal vector
/// The normal should be normalized for correct results
pub fn reflect(v: Vec3, normal: Vec3) Vec3 {
    const d = dot(v, normal);
    return sub(v, mul(normal, 2 * d));
}

// ===============
// Interpolation & Clamping

pub fn lerp(a: Vec3, b: Vec3, t: f32) Vec3 {
    return [3]f32{
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
    };
}

/// Spherical linear interpolation between two vectors.
/// Better than lerp for rotating vectors as it maintains constant angular velocity.
/// Both input vectors should ideally be normalized for best results.
/// When t=0, returns a. When t=1, returns b. For t in (0,1), returns a smooth interpolation.
pub fn slerp(a: Vec3, b: Vec3, t: f32) Vec3 {
    const epsilon = 0.0001;

    // Compute the cosine of the angle between the two vectors
    const dot_product = dot(a, b);

    // If the vectors are very close, use lerp to avoid division by zero
    if (dot_product > 1.0 - epsilon) {
        return normalize(lerp(a, b, t));
    }

    // If the vectors are opposite, find a perpendicular vector and interpolate through it
    if (dot_product < -1.0 + epsilon) {
        // Find a perpendicular vector to a
        const perp = if (@abs(a[0]) < 0.9)
            normalize(cross(a, init(1, 0, 0)))
        else
            normalize(cross(a, init(0, 1, 0)));

        // Rotate around the perpendicular axis
        const angle = std.math.pi * t;
        return rotate(a, perp, angle);
    }

    // Clamp dot product to valid range for acos
    const clamped_dot = @max(-1.0, @min(1.0, dot_product));
    const theta = std.math.acos(clamped_dot);
    const sin_theta = @sin(theta);

    // Additional safety check for sin_theta
    if (@abs(sin_theta) < epsilon) {
        return normalize(lerp(a, b, t));
    }

    // Calculate interpolation coefficients
    const a_coeff = @sin((1.0 - t) * theta) / sin_theta;
    const b_coeff = @sin(t * theta) / sin_theta;

    return [3]f32{
        a[0] * a_coeff + b[0] * b_coeff,
        a[1] * a_coeff + b[1] * b_coeff,
        a[2] * a_coeff + b[2] * b_coeff,
    };
}

pub fn clamp(v: Vec3, min_v: Vec3, max_v: Vec3) Vec3 {
    return [3]f32{
        @max(min_v[0], @min(max_v[0], v[0])),
        @max(min_v[1], @min(max_v[1], v[1])),
        @max(min_v[2], @min(max_v[2], v[2])),
    };
}

// ===============
// Angle Operations

pub fn angleBetween(a: Vec3, b: Vec3) f32 {
    const dot_product = dot(a, b);
    const len_product = length(a) * length(b);
    if (len_product == 0) return 0;
    const cos_angle = dot_product / len_product;
    return std.math.acos(@max(-1.0, @min(1.0, cos_angle)));
}

/// Rotates a vector around an axis by the given angle using Rodrigues' rotation formula.
/// Note: The axis vector should be normalized. If not, the rotation will be incorrect.
/// Formula: v*cos(θ) + (axis × v)*sin(θ) + axis*(axis·v)*(1-cos(θ))
pub fn rotate(v: Vec3, axis: Vec3, radians: f32) Vec3 {
    const cos_r = @cos(radians);
    const sin_r = @sin(radians);
    const one_minus_cos = 1.0 - cos_r;

    const cross_product = cross(axis, v);
    const dot_product = dot(axis, v);

    return [3]f32{
        v[0] * cos_r + cross_product[0] * sin_r + axis[0] * dot_product * one_minus_cos,
        v[1] * cos_r + cross_product[1] * sin_r + axis[1] * dot_product * one_minus_cos,
        v[2] * cos_r + cross_product[2] * sin_r + axis[2] * dot_product * one_minus_cos,
    };
}

// ===============
// Utility

pub fn equal(a: Vec3, b: Vec3) bool {
    return a[0] == b[0] and a[1] == b[1] and a[2] == b[2];
}

pub fn approxEqual(a: Vec3, b: Vec3, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and
        @abs(a[1] - b[1]) <= epsilon and
        @abs(a[2] - b[2]) <= epsilon;
}

pub fn min(a: Vec3, b: Vec3) Vec3 {
    return [3]f32{
        @min(a[0], b[0]),
        @min(a[1], b[1]),
        @min(a[2], b[2]),
    };
}

pub fn max(a: Vec3, b: Vec3) Vec3 {
    return [3]f32{
        @max(a[0], b[0]),
        @max(a[1], b[1]),
        @max(a[2], b[2]),
    };
}

pub fn zero() Vec3 {
    return [3]f32{ 0, 0, 0 };
}

pub fn one() Vec3 {
    return [3]f32{ 1, 1, 1 };
}

pub fn unitX() Vec3 {
    return [3]f32{ 1, 0, 0 };
}

pub fn unitY() Vec3 {
    return [3]f32{ 0, 1, 0 };
}

pub fn unitZ() Vec3 {
    return [3]f32{ 0, 0, 1 };
}

// ===============
// Tests - Construction & Accessors

test "init creates a vector from components" {
    const v = init(1, 2, 3);
    try std.testing.expect(equal(v, .{ 1, 2, 3 }));
}

test "fromArray creates vec3 from array" {
    const v = fromArray(.{ 1, 2, 3 });
    try std.testing.expect(equal(v, init(1, 2, 3)));
}

test "fromVec2 creates vec3 by appending z" {
    const v = fromVec2(.{ 1, 2 }, 3);
    try std.testing.expect(equal(v, init(1, 2, 3)));
}

test "fromVec4 creates vec3 by dropping w" {
    const v = fromVec4(@Vector(4, f32){ 1, 2, 3, 4 });
    try std.testing.expect(equal(v, init(1, 2, 3)));
}

test "X returns the first coordinate" {
    // given
    const v = init(1, 2, 3);

    // when
    const x = X(v);

    // then
    try std.testing.expect(x == 1);
}

test "Y returns the second coordinate" {
    // given
    const v = init(1, 2, 3);

    // when
    const y = Y(v);

    // then
    try std.testing.expect(y == 2);
}

test "Z returns the third coordinate" {
    // given
    const v = init(1, 2, 3);

    // when
    const z = Z(v);

    // then
    try std.testing.expect(z == 3);
}

// ===============
// Essential Arithmetic Tests

test "sum - can sum vectors" {
    // given
    const l = init(1, 2, 3);
    const r = init(2, 4, 6);

    // when
    const result = sum(l, r);

    // then
    try std.testing.expect(equal(result, init(3, 6, 9)));
}

test "sub - can subtract vectors" {
    // given
    const l = init(5, 7, 9);
    const r = init(2, 3, 4);

    // when
    const result = sub(l, r);

    // then
    try std.testing.expect(equal(result, init(3, 4, 5)));
}

test "mul - can multiply vector by scalar" {
    // given
    const v = init(2, 3, 4);
    const scalar: f32 = 3;

    // when
    const result = mul(v, scalar);

    // then
    try std.testing.expect(equal(result, init(6, 9, 12)));
}

test "div - can divide vector by scalar" {
    // given
    const v = init(6, 9, 12);
    const scalar: f32 = 3;

    // when
    const result = div(v, scalar);

    // then
    try std.testing.expect(equal(result, init(2, 3, 4)));
}

test "neg - can negate vector" {
    // given
    const v = init(2, -3, 4);

    // when
    const result = neg(v);

    // then
    try std.testing.expect(equal(result, init(-2, 3, -4)));
}

test "componentMul - multiplies components element-wise" {
    // given
    const a = init(2, 3, 4);
    const b = init(5, 6, 7);

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, init(10, 18, 28)));
}

test "componentMul - handles zero vector" {
    // given
    const a = init(5, 7, 9);
    const b = zero();

    // when
    const result = componentMul(a, b);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "componentMul - handles one vector as identity" {
    // given
    const v = init(3, 4, 5);
    const identity = one();

    // when
    const result = componentMul(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - divides components element-wise" {
    // given
    const a = init(10, 18, 28);
    const b = init(2, 3, 4);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(5, 6, 7)));
}

test "componentDiv - handles one vector as identity" {
    // given
    const v = init(6, 9, 12);
    const identity = one();

    // when
    const result = componentDiv(v, identity);

    // then
    try std.testing.expect(equal(result, v));
}

test "componentDiv - handles different divisors per component" {
    // given
    const a = init(10, 20, 30);
    const b = init(2, 4, 5);

    // when
    const result = componentDiv(a, b);

    // then
    try std.testing.expect(equal(result, init(5, 5, 6)));
}

// ===============
// Length/Distance Tests

test "lengthSquared - calculates squared magnitude" {
    // given
    const v = init(2, 3, 6);

    // when
    const result = lengthSquared(v);

    // then
    try std.testing.expect(result == 49); // 4 + 9 + 36 = 49
}

test "length - calculates magnitude using 3D Pythagorean" {
    // given
    const v = init(2, 3, 6);

    // when
    const result = length(v);

    // then
    try std.testing.expect(result == 7);
}

test "normalize - creates unit vector" {
    // given
    const v = init(2, 3, 6);

    // when
    const result = normalize(v);

    // then
    try std.testing.expect(approxEqual(result, init(2.0 / 7.0, 3.0 / 7.0, 6.0 / 7.0), 0.0001));
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
    const a = init(1, 2, 3);
    const b = init(3, 5, 9);

    // when
    const result = distance(a, b);

    // then
    try std.testing.expect(result == 7); // sqrt(4 + 9 + 36) = 7
}

test "distanceSquared - calculates squared distance" {
    // given
    const a = init(1, 2, 3);
    const b = init(3, 5, 9);

    // when
    const result = distanceSquared(a, b);

    // then
    try std.testing.expect(result == 49);
}

// ===============
// Product Tests

test "dot - calculates dot product" {
    // given
    const a = init(2, 3, 4);
    const b = init(5, 6, 7);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 56); // 10 + 18 + 28 = 56
}

test "dot - perpendicular vectors have zero dot product" {
    // given
    const a = init(1, 0, 0);
    const b = init(0, 1, 0);

    // when
    const result = dot(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "cross - i × j = k" {
    // given
    const i = unitX();
    const j = unitY();

    // when
    const result = cross(i, j);

    // then
    try std.testing.expect(equal(result, unitZ()));
}

test "cross - j × k = i" {
    // given
    const j = unitY();
    const k = unitZ();

    // when
    const result = cross(j, k);

    // then
    try std.testing.expect(equal(result, unitX()));
}

test "cross - k × i = j" {
    // given
    const k = unitZ();
    const i = unitX();

    // when
    const result = cross(k, i);

    // then
    try std.testing.expect(equal(result, unitY()));
}

test "cross - anti-commutativity: a × b = -(b × a)" {
    // given
    const a = init(2, 3, 4);
    const b = init(5, 6, 7);

    // when
    const ab = cross(a, b);
    const ba = cross(b, a);

    // then
    try std.testing.expect(equal(ab, neg(ba)));
}

test "cross - result is perpendicular to both inputs" {
    // given
    const a = init(1, 2, 3);
    const b = init(4, 5, 6);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(@abs(dot(result, a)) < 0.0001);
    try std.testing.expect(@abs(dot(result, b)) < 0.0001);
}

test "cross - parallel vectors have zero cross product" {
    // given
    const a = init(2, 4, 6);
    const b = init(1, 2, 3);

    // when
    const result = cross(a, b);

    // then
    try std.testing.expect(equal(result, zero()));
}

// ===============
// Geometric Projection Tests

test "project - projects onto x-axis" {
    // given
    const v = init(3, 4, 5);
    const onto = init(1, 0, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(3, 0, 0)));
}

test "project - projects onto y-axis" {
    // given
    const v = init(3, 4, 5);
    const onto = init(0, 1, 0);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 4, 0)));
}

test "project - projects onto z-axis" {
    // given
    const v = init(3, 4, 5);
    const onto = init(0, 0, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(0, 0, 5)));
}

test "project - projects onto diagonal vector" {
    // given
    const v = init(6, 3, 3);
    const onto = init(1, 1, 1);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, init(4, 4, 4)));
}

test "project - handles zero onto vector" {
    // given
    const v = init(3, 4, 5);
    const onto = zero();

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, zero()));
}

test "project - parallel vectors project fully" {
    // given
    const v = init(6, 8, 10);
    const onto = init(3, 4, 5);

    // when
    const result = project(v, onto);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - returns perpendicular component to x-axis" {
    // given
    const v = init(3, 4, 5);
    const ref = init(1, 0, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(0, 4, 5)));
}

test "reject - returns perpendicular component to y-axis" {
    // given
    const v = init(3, 4, 5);
    const ref = init(0, 1, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 0, 5)));
}

test "reject - returns perpendicular component to z-axis" {
    // given
    const v = init(3, 4, 5);
    const ref = init(0, 0, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(3, 4, 0)));
}

test "reject - returns perpendicular component to diagonal" {
    // given
    const v = init(6, 3, 3);
    const ref = init(1, 1, 1);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, init(2, -1, -1)));
}

test "reject - returns original vector when ref is perpendicular" {
    // given
    const v = init(0, 5, 0);
    const ref = init(1, 0, 0);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(equal(result, v));
}

test "reject - parallel vectors reject to zero" {
    // given
    const v = init(6, 8, 10);
    const ref = init(3, 4, 5);

    // when
    const result = reject(v, ref);

    // then
    try std.testing.expect(approxEqual(result, zero(), 0.0001));
}

test "reflect - reflects across x-axis normal" {
    // given
    const v = init(3, 4, 5);
    const normal = init(1, 0, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(-3, 4, 5)));
}

test "reflect - reflects across y-axis normal" {
    // given
    const v = init(3, 4, 5);
    const normal = init(0, 1, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, -4, 5)));
}

test "reflect - reflects across z-axis normal" {
    // given
    const v = init(3, 4, 5);
    const normal = init(0, 0, 1);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(3, 4, -5)));
}

test "reflect - reflects across diagonal normal" {
    // given
    const v = init(1, 0, 0);
    const sqrt3_inv: f32 = 1.0 / @sqrt(3.0);
    const normal = init(sqrt3_inv, sqrt3_inv, sqrt3_inv);

    // when
    const result = reflect(v, normal);

    // then
    const expected_x: f32 = 1.0 - 2.0 * sqrt3_inv * sqrt3_inv;
    const expected_yz: f32 = -2.0 * sqrt3_inv * sqrt3_inv;
    try std.testing.expect(approxEqual(result, init(expected_x, expected_yz, expected_yz), 0.0001));
}

test "reflect - perpendicular vector reflects back" {
    // given
    const v = init(0, 5, 0);
    const normal = init(0, 1, 0);

    // when
    const result = reflect(v, normal);

    // then
    try std.testing.expect(equal(result, init(0, -5, 0)));
}

test "reflect - preserves magnitude" {
    // given
    const v = init(3, 4, 5);
    const normal = normalize(init(1, 1, 1));

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
    const a = init(0, 0, 0);
    const b = init(10, 10, 10);

    // when
    const result = lerp(a, b, 0);

    // then
    try std.testing.expect(equal(result, a));
}

test "lerp - interpolates at t=1" {
    // given
    const a = init(0, 0, 0);
    const b = init(10, 10, 10);

    // when
    const result = lerp(a, b, 1);

    // then
    try std.testing.expect(equal(result, b));
}

test "lerp - interpolates at t=0.5" {
    // given
    const a = init(0, 0, 0);
    const b = init(10, 20, 30);

    // when
    const result = lerp(a, b, 0.5);

    // then
    try std.testing.expect(equal(result, init(5, 10, 15)));
}

test "slerp - interpolates at t=0" {
    // given
    const a = normalize(init(1, 0, 0));
    const b = normalize(init(0, 1, 0));

    // when
    const result = slerp(a, b, 0);

    // then
    try std.testing.expect(approxEqual(result, a, 0.0001));
}

test "slerp - interpolates at t=1" {
    // given
    const a = normalize(init(1, 0, 0));
    const b = normalize(init(0, 1, 0));

    // when
    const result = slerp(a, b, 1);

    // then
    try std.testing.expect(approxEqual(result, b, 0.0001));
}

test "slerp - interpolates at t=0.5 maintains unit length" {
    // given
    const a = normalize(init(1, 0, 0));
    const b = normalize(init(0, 1, 0));

    // when
    const result = slerp(a, b, 0.5);

    // then
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
}

test "slerp - interpolates smoothly between perpendicular vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(0, 1, 0);

    // when
    const result = slerp(a, b, 0.5);

    // then
    // At t=0.5 between perpendicular unit vectors, we expect a 45-degree angle
    const sqrt2_inv: f32 = 1.0 / @sqrt(2.0);
    try std.testing.expect(approxEqual(result, init(sqrt2_inv, sqrt2_inv, 0), 0.0001));
}

test "slerp - handles parallel vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(2, 0, 0);

    // when
    const result = slerp(a, b, 0.5);

    // then
    // For parallel vectors, slerp falls back to normalized lerp
    try std.testing.expect(approxEqual(result, init(1, 0, 0), 0.0001));
}

test "slerp - handles opposite vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(-1, 0, 0);

    // when
    const result = slerp(a, b, 0.5);

    // then
    // For opposite vectors at t=0.5, we rotate 180 degrees / 2 = 90 degrees
    // around a perpendicular axis. The result should be perpendicular to both a and b.
    try std.testing.expect(@abs(length(result) - 1.0) < 0.0001);
    try std.testing.expect(@abs(dot(result, a)) < 0.0001);
    try std.testing.expect(@abs(dot(result, b)) < 0.0001);
}

test "slerp - interpolates 3D rotation smoothly" {
    // given
    const a = normalize(init(1, 0, 0));
    const b = normalize(init(1, 1, 1));

    // when
    const result_quarter = slerp(a, b, 0.25);
    const result_half = slerp(a, b, 0.5);
    const result_three_quarter = slerp(a, b, 0.75);

    // then
    // Verify all results maintain unit length
    try std.testing.expect(@abs(length(result_quarter) - 1.0) < 0.0001);
    try std.testing.expect(@abs(length(result_half) - 1.0) < 0.0001);
    try std.testing.expect(@abs(length(result_three_quarter) - 1.0) < 0.0001);

    // Verify monotonic progression toward target
    const angle_start = angleBetween(a, b);
    const angle_quarter = angleBetween(a, result_quarter);
    const angle_half = angleBetween(a, result_half);
    const angle_three_quarter = angleBetween(a, result_three_quarter);

    try std.testing.expect(angle_quarter < angle_half);
    try std.testing.expect(angle_half < angle_three_quarter);
    try std.testing.expect(angle_three_quarter < angle_start);
}

test "slerp - maintains constant angular velocity" {
    // given
    const a = normalize(init(1, 0, 0));
    const b = normalize(init(0, 1, 0));

    // when
    const result_quarter = slerp(a, b, 0.25);
    const result_half = slerp(a, b, 0.5);
    const result_three_quarter = slerp(a, b, 0.75);

    // then
    // Angular distances should be approximately equal
    const angle1 = angleBetween(a, result_quarter);
    const angle2 = angleBetween(result_quarter, result_half);
    const angle3 = angleBetween(result_half, result_three_quarter);
    const angle4 = angleBetween(result_three_quarter, b);

    // All angular segments should be approximately equal (within tolerance)
    try std.testing.expect(@abs(angle1 - angle2) < 0.001);
    try std.testing.expect(@abs(angle2 - angle3) < 0.001);
    try std.testing.expect(@abs(angle3 - angle4) < 0.001);
}

test "clamp - clamps vector to bounds" {
    // given
    const v = init(-5, 15, 7);
    const min_v = init(0, 0, 0);
    const max_v = init(10, 10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, init(0, 10, 7)));
}

test "clamp - vector within bounds unchanged" {
    // given
    const v = init(5, 5, 5);
    const min_v = init(0, 0, 0);
    const max_v = init(10, 10, 10);

    // when
    const result = clamp(v, min_v, max_v);

    // then
    try std.testing.expect(equal(result, v));
}

// ===============
// Angle Tests

test "angleBetween - calculates angle between perpendicular vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(0, 1, 0);

    // when
    const result = angleBetween(a, b);

    // then
    const expected = std.math.pi / 2.0;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - calculates angle between parallel vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(2, 0, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(@abs(result - 0.0) < 0.0001);
}

test "angleBetween - calculates angle between opposite vectors" {
    // given
    const a = init(1, 0, 0);
    const b = init(-1, 0, 0);

    // when
    const result = angleBetween(a, b);

    // then
    const expected = std.math.pi;
    try std.testing.expect(@abs(result - expected) < 0.0001);
}

test "angleBetween - handles zero vector" {
    // given
    const a = zero();
    const b = init(1, 0, 0);

    // when
    const result = angleBetween(a, b);

    // then
    try std.testing.expect(result == 0);
}

test "rotate - rotates around x-axis by 90 degrees" {
    // given
    const v = init(0, 1, 0);
    const axis = unitX();
    const radians: f32 = std.math.pi / 2.0;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(approxEqual(result, init(0, 0, 1), 0.0001));
}

test "rotate - rotates around y-axis by 90 degrees" {
    // given
    const v = init(1, 0, 0);
    const axis = unitY();
    const radians: f32 = std.math.pi / 2.0;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(approxEqual(result, init(0, 0, -1), 0.0001));
}

test "rotate - rotates around z-axis by 90 degrees" {
    // given
    const v = init(1, 0, 0);
    const axis = unitZ();
    const radians: f32 = std.math.pi / 2.0;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(approxEqual(result, init(0, 1, 0), 0.0001));
}

test "rotate - preserves length" {
    // given
    const v = init(2, 3, 6);
    const axis = normalize(init(1, 1, 1));
    const radians: f32 = std.math.pi / 3.0;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(@abs(length(result) - length(v)) < 0.0001);
}

test "rotate - 180 degree rotation around x-axis" {
    // given
    const v = init(0, 1, 0);
    const axis = unitX();
    const radians: f32 = std.math.pi;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(approxEqual(result, init(0, -1, 0), 0.0001));
}

test "rotate - full 360 degree rotation returns original vector" {
    // given
    const v = init(2, 3, 4);
    const axis = normalize(init(1, 2, 3));
    const radians: f32 = std.math.pi * 2.0;

    // when
    const result = rotate(v, axis, radians);

    // then
    try std.testing.expect(approxEqual(result, v, 0.0001));
}

// ===============
// Utility Tests

test "equal - returns true for equal vectors" {
    // given
    const a = init(1, 2, 3);
    const b = init(1, 2, 3);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == true);
}

test "equal - returns false for different vectors" {
    // given
    const a = init(1, 2, 3);
    const b = init(1, 2, 4);

    // when
    const result = equal(a, b);

    // then
    try std.testing.expect(result == false);
}

test "approxEqual - returns true for approximately equal vectors" {
    // given
    const a = init(1.0001, 2.0001, 3.0001);
    const b = init(1.0002, 2.0002, 3.0002);

    // when
    const result = approxEqual(a, b, 0.001);

    // then
    try std.testing.expect(result == true);
}

test "approxEqual - returns false when difference exceeds epsilon" {
    // given
    const a = init(1.0, 2.0, 3.0);
    const b = init(1.1, 2.0, 3.0);

    // when
    const result = approxEqual(a, b, 0.01);

    // then
    try std.testing.expect(result == false);
}

test "min - returns component-wise minimum" {
    // given
    const a = init(1, 5, 3);
    const b = init(3, 2, 4);

    // when
    const result = min(a, b);

    // then
    try std.testing.expect(equal(result, init(1, 2, 3)));
}

test "max - returns component-wise maximum" {
    // given
    const a = init(1, 5, 3);
    const b = init(3, 2, 4);

    // when
    const result = max(a, b);

    // then
    try std.testing.expect(equal(result, init(3, 5, 4)));
}

test "zero - returns zero vector" {
    // when
    const result = zero();

    // then
    try std.testing.expect(equal(result, init(0, 0, 0)));
}

test "one - returns one vector" {
    // when
    const result = one();

    // then
    try std.testing.expect(equal(result, init(1, 1, 1)));
}

test "unitX - returns x-axis unit vector" {
    // when
    const result = unitX();

    // then
    try std.testing.expect(equal(result, init(1, 0, 0)));
    try std.testing.expect(X(result) == 1);
    try std.testing.expect(Y(result) == 0);
    try std.testing.expect(Z(result) == 0);
}

test "unitY - returns y-axis unit vector" {
    // when
    const result = unitY();

    // then
    try std.testing.expect(equal(result, init(0, 1, 0)));
    try std.testing.expect(X(result) == 0);
    try std.testing.expect(Y(result) == 1);
    try std.testing.expect(Z(result) == 0);
}

test "unitZ - returns z-axis unit vector" {
    // when
    const result = unitZ();

    // then
    try std.testing.expect(equal(result, init(0, 0, 1)));
    try std.testing.expect(X(result) == 0);
    try std.testing.expect(Y(result) == 0);
    try std.testing.expect(Z(result) == 1);
}
