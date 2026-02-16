// @analogAlex
const std = @import("std");
const vec2 = @import("../vectors/vec2.zig");
const vec3 = @import("../vectors/vec3.zig");

/// 3x3 matrix stored in column-major order for GPU compatibility
/// Layout: [m00, m10, m20, m01, m11, m21, m02, m12, m22]
pub const Mat3 = [9]f32;

// ===============
// Construction

pub fn from(
    m00: f32,
    m01: f32,
    m02: f32,
    m10: f32,
    m11: f32,
    m12: f32,
    m20: f32,
    m21: f32,
    m22: f32,
) Mat3 {
    return [9]f32{ m00, m10, m20, m01, m11, m21, m02, m12, m22 };
}

pub fn fromCols(col0: vec3.Vec3, col1: vec3.Vec3, col2: vec3.Vec3) Mat3 {
    return [9]f32{
        col0[0], col0[1], col0[2],
        col1[0], col1[1], col1[2],
        col2[0], col2[1], col2[2],
    };
}

pub fn identity() Mat3 {
    return [9]f32{ 1, 0, 0, 0, 1, 0, 0, 0, 1 };
}

pub fn zero() Mat3 {
    return [9]f32{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
}

// ===============
// Accessors

pub inline fn get(m: Mat3, row: usize, col: usize) f32 {
    return m[col * 3 + row];
}

pub inline fn getCol(m: Mat3, col: usize) vec3.Vec3 {
    const offset = col * 3;
    return [3]f32{ m[offset], m[offset + 1], m[offset + 2] };
}

pub inline fn getRow(m: Mat3, row: usize) vec3.Vec3 {
    return [3]f32{ m[row], m[row + 3], m[row + 6] };
}

// ===============
// Matrix Operations

pub fn multiply(lhs: Mat3, rhs: Mat3) Mat3 {
    var result: Mat3 = undefined;
    var col: usize = 0;
    while (col < 3) : (col += 1) {
        var row: usize = 0;
        while (row < 3) : (row += 1) {
            result[col * 3 + row] =
                lhs[row] * rhs[col * 3] +
                lhs[row + 3] * rhs[col * 3 + 1] +
                lhs[row + 6] * rhs[col * 3 + 2];
        }
    }
    return result;
}

pub fn transpose(m: Mat3) Mat3 {
    return [9]f32{
        m[0], m[3], m[6],
        m[1], m[4], m[7],
        m[2], m[5], m[8],
    };
}

pub fn determinant(m: Mat3) f32 {
    return m[0] * (m[4] * m[8] - m[7] * m[5]) -
        m[3] * (m[1] * m[8] - m[7] * m[2]) +
        m[6] * (m[1] * m[5] - m[4] * m[2]);
}

pub fn inverse(m: Mat3) ?Mat3 {
    const det = determinant(m);
    if (@abs(det) < 1e-6) return null;

    const inv_det = 1.0 / det;

    return [9]f32{
        (m[4] * m[8] - m[7] * m[5]) * inv_det,
        (m[7] * m[2] - m[1] * m[8]) * inv_det,
        (m[1] * m[5] - m[4] * m[2]) * inv_det,
        (m[6] * m[5] - m[3] * m[8]) * inv_det,
        (m[0] * m[8] - m[6] * m[2]) * inv_det,
        (m[3] * m[2] - m[0] * m[5]) * inv_det,
        (m[3] * m[7] - m[6] * m[4]) * inv_det,
        (m[6] * m[1] - m[0] * m[7]) * inv_det,
        (m[0] * m[4] - m[3] * m[1]) * inv_det,
    };
}

// ===============
// Vector Transformation

pub fn transformVec2(m: Mat3, v: vec2.Vec2) vec2.Vec2 {
    return [2]f32{
        m[0] * v[0] + m[3] * v[1] + m[6],
        m[1] * v[0] + m[4] * v[1] + m[7],
    };
}

pub fn transformVec3(m: Mat3, v: vec3.Vec3) vec3.Vec3 {
    return [3]f32{
        m[0] * v[0] + m[3] * v[1] + m[6] * v[2],
        m[1] * v[0] + m[4] * v[1] + m[7] * v[2],
        m[2] * v[0] + m[5] * v[1] + m[8] * v[2],
    };
}

// ===============
// Arithmetic

pub fn add(lhs: Mat3, rhs: Mat3) Mat3 {
    var result: Mat3 = undefined;
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        result[i] = lhs[i] + rhs[i];
    }
    return result;
}

pub fn sub(lhs: Mat3, rhs: Mat3) Mat3 {
    var result: Mat3 = undefined;
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        result[i] = lhs[i] - rhs[i];
    }
    return result;
}

pub fn scale(m: Mat3, scalar: f32) Mat3 {
    var result: Mat3 = undefined;
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        result[i] = m[i] * scalar;
    }
    return result;
}

// ===============
// Transformation Constructors

pub fn translation2D(tx: f32, ty: f32) Mat3 {
    return [9]f32{ 1, 0, 0, 0, 1, 0, tx, ty, 1 };
}

pub fn rotation2D(radians: f32) Mat3 {
    const c = @cos(radians);
    const s = @sin(radians);
    return [9]f32{ c, s, 0, -s, c, 0, 0, 0, 1 };
}

pub fn scaling2D(sx: f32, sy: f32) Mat3 {
    return [9]f32{ sx, 0, 0, 0, sy, 0, 0, 0, 1 };
}

pub fn rotationX(radians: f32) Mat3 {
    const c = @cos(radians);
    const s = @sin(radians);
    return [9]f32{ 1, 0, 0, 0, c, s, 0, -s, c };
}

pub fn rotationY(radians: f32) Mat3 {
    const c = @cos(radians);
    const s = @sin(radians);
    return [9]f32{ c, 0, -s, 0, 1, 0, s, 0, c };
}

pub fn rotationZ(radians: f32) Mat3 {
    const c = @cos(radians);
    const s = @sin(radians);
    return [9]f32{ c, s, 0, -s, c, 0, 0, 0, 1 };
}

pub fn scaling3D(sx: f32, sy: f32, sz: f32) Mat3 {
    return [9]f32{ sx, 0, 0, 0, sy, 0, 0, 0, sz };
}

// ===============
// Utility

pub fn equal(a: Mat3, b: Mat3) bool {
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        if (a[i] != b[i]) return false;
    }
    return true;
}

pub fn approxEqual(a: Mat3, b: Mat3, epsilon: f32) bool {
    var i: usize = 0;
    while (i < 9) : (i += 1) {
        if (@abs(a[i] - b[i]) > epsilon) return false;
    }
    return true;
}

// ===============
// Tests

test "identity matrix" {
    const m = identity();
    try std.testing.expect(equal(m, from(1, 0, 0, 0, 1, 0, 0, 0, 1)));
}

test "from creates matrix with correct element ordering" {
    const m = from(1, 2, 3, 4, 5, 6, 7, 8, 9);
    try std.testing.expect(get(m, 0, 0) == 1);
    try std.testing.expect(get(m, 0, 1) == 2);
    try std.testing.expect(get(m, 0, 2) == 3);
    try std.testing.expect(get(m, 2, 2) == 9);
}

test "fromCols creates matrix from column vectors" {
    const col0 = vec3.from(1, 2, 3);
    const col1 = vec3.from(4, 5, 6);
    const col2 = vec3.from(7, 8, 9);
    const m = fromCols(col0, col1, col2);
    try std.testing.expect(equal(m, from(1, 4, 7, 2, 5, 8, 3, 6, 9)));
}

test "multiply - identity matrix" {
    const m = from(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const id = identity();
    const result = multiply(m, id);
    try std.testing.expect(approxEqual(result, m, 0.0001));
}

test "transpose swaps rows and columns" {
    const m = from(1, 2, 3, 4, 5, 6, 7, 8, 9);
    const t = transpose(m);
    try std.testing.expect(equal(t, from(1, 4, 7, 2, 5, 8, 3, 6, 9)));
}

test "determinant calculates correctly" {
    const m = from(1, 2, 3, 0, 1, 4, 5, 6, 0);
    const det = determinant(m);
    try std.testing.expect(det == 1);
}

test "inverse - calculates inverse matrix" {
    const m = from(1, 0, 5, 2, 1, 6, 3, 4, 0);
    const inv = inverse(m).?;
    const product = multiply(m, inv);
    try std.testing.expect(approxEqual(product, identity(), 0.0001));
}

test "inverse - returns null for singular matrix" {
    const m = from(1, 2, 3, 2, 4, 6, 3, 6, 9);
    const inv = inverse(m);
    try std.testing.expect(inv == null);
}

test "transformVec2 - 2D translation" {
    const m = translation2D(10, 20);
    const v = vec2.from(5, 5);
    const result = transformVec2(m, v);
    try std.testing.expect(vec2.equal(result, vec2.from(15, 25)));
}

test "transformVec3 transforms vector correctly" {
    const m = rotationZ(std.math.pi / 2.0);
    const v = vec3.from(1, 0, 0);
    const result = transformVec3(m, v);
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 1, 0), 0.0001));
}

test "translation2D creates correct matrix" {
    const m = translation2D(5, 10);
    const v = vec2.from(0, 0);
    const translated = transformVec2(m, v);
    try std.testing.expect(vec2.equal(translated, vec2.from(5, 10)));
}

test "rotation2D creates rotation matrix" {
    const m = rotation2D(std.math.pi / 2.0);
    const v = vec2.from(1, 0);
    const rotated = transformVec2(m, v);
    try std.testing.expect(vec2.approxEqual(rotated, vec2.from(0, 1), 0.0001));
}

test "scaling2D creates scaling matrix" {
    const m = scaling2D(2, 3);
    const v = vec2.from(4, 5);
    const scaled = transformVec2(m, v);
    try std.testing.expect(vec2.equal(scaled, vec2.from(8, 15)));
}

test "rotationX rotates around x-axis" {
    const m = rotationX(std.math.pi / 2.0);
    const v = vec3.from(0, 1, 0);
    const result = transformVec3(m, v);
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 0, 1), 0.0001));
}

test "rotationY rotates around y-axis" {
    const m = rotationY(std.math.pi / 2.0);
    const v = vec3.from(1, 0, 0);
    const result = transformVec3(m, v);
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 0, -1), 0.0001));
}

test "rotationZ rotates around z-axis" {
    const m = rotationZ(std.math.pi / 2.0);
    const v = vec3.from(1, 0, 0);
    const result = transformVec3(m, v);
    try std.testing.expect(vec3.approxEqual(result, vec3.from(0, 1, 0), 0.0001));
}
