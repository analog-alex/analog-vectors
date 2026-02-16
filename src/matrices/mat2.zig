// @analogAlex
const std = @import("std");
const vec2 = @import("../vectors/vec2.zig");

/// 2x2 matrix stored in column-major order for GPU compatibility
/// Layout: [m00, m10, m01, m11]
/// Where column 0 = [m00, m10], column 1 = [m01, m11]
pub const Mat2 = [4]f32;

// ===============
// Construction

pub fn from(m00: f32, m01: f32, m10: f32, m11: f32) Mat2 {
    return [4]f32{ m00, m10, m01, m11 };
}

pub fn fromCols(col0: vec2.Vec2, col1: vec2.Vec2) Mat2 {
    return [4]f32{ col0[0], col0[1], col1[0], col1[1] };
}

pub fn identity() Mat2 {
    return [4]f32{ 1, 0, 0, 1 };
}

pub fn zero() Mat2 {
    return [4]f32{ 0, 0, 0, 0 };
}

// ===============
// Accessors

pub inline fn get(m: Mat2, row: usize, col: usize) f32 {
    return m[col * 2 + row];
}

pub inline fn getCol(m: Mat2, col: usize) vec2.Vec2 {
    const offset = col * 2;
    return [2]f32{ m[offset], m[offset + 1] };
}

pub inline fn getRow(m: Mat2, row: usize) vec2.Vec2 {
    return [2]f32{ m[row], m[row + 2] };
}

// ===============
// Matrix Operations

pub fn multiply(lhs: Mat2, rhs: Mat2) Mat2 {
    return [4]f32{
        lhs[0] * rhs[0] + lhs[2] * rhs[1],
        lhs[1] * rhs[0] + lhs[3] * rhs[1],
        lhs[0] * rhs[2] + lhs[2] * rhs[3],
        lhs[1] * rhs[2] + lhs[3] * rhs[3],
    };
}

pub fn transpose(m: Mat2) Mat2 {
    return [4]f32{ m[0], m[2], m[1], m[3] };
}

pub fn determinant(m: Mat2) f32 {
    return m[0] * m[3] - m[2] * m[1];
}

pub fn inverse(m: Mat2) ?Mat2 {
    const det = determinant(m);
    if (@abs(det) < 1e-6) return null;

    const inv_det = 1.0 / det;
    return [4]f32{
        m[3] * inv_det,
        -m[1] * inv_det,
        -m[2] * inv_det,
        m[0] * inv_det,
    };
}

// ===============
// Vector Transformation

pub fn transformVec2(m: Mat2, v: vec2.Vec2) vec2.Vec2 {
    return [2]f32{
        m[0] * v[0] + m[2] * v[1],
        m[1] * v[0] + m[3] * v[1],
    };
}

// ===============
// Arithmetic

pub fn add(lhs: Mat2, rhs: Mat2) Mat2 {
    return [4]f32{
        lhs[0] + rhs[0],
        lhs[1] + rhs[1],
        lhs[2] + rhs[2],
        lhs[3] + rhs[3],
    };
}

pub fn sub(lhs: Mat2, rhs: Mat2) Mat2 {
    return [4]f32{
        lhs[0] - rhs[0],
        lhs[1] - rhs[1],
        lhs[2] - rhs[2],
        lhs[3] - rhs[3],
    };
}

pub fn scale(m: Mat2, scalar: f32) Mat2 {
    return [4]f32{
        m[0] * scalar,
        m[1] * scalar,
        m[2] * scalar,
        m[3] * scalar,
    };
}

// ===============
// Transformation Constructors

pub fn rotation(radians: f32) Mat2 {
    const c = @cos(radians);
    const s = @sin(radians);
    return [4]f32{ c, s, -s, c };
}

pub fn scaling(sx: f32, sy: f32) Mat2 {
    return [4]f32{ sx, 0, 0, sy };
}

// ===============
// Utility

pub fn equal(a: Mat2, b: Mat2) bool {
    return a[0] == b[0] and a[1] == b[1] and a[2] == b[2] and a[3] == b[3];
}

pub fn approxEqual(a: Mat2, b: Mat2, epsilon: f32) bool {
    return @abs(a[0] - b[0]) <= epsilon and
        @abs(a[1] - b[1]) <= epsilon and
        @abs(a[2] - b[2]) <= epsilon and
        @abs(a[3] - b[3]) <= epsilon;
}

// ===============
// Tests

test "identity matrix" {
    const m = identity();
    try std.testing.expect(m[0] == 1 and m[1] == 0);
    try std.testing.expect(m[2] == 0 and m[3] == 1);
}

test "from creates matrix with correct element ordering" {
    const m = from(1, 2, 3, 4);
    try std.testing.expect(get(m, 0, 0) == 1);
    try std.testing.expect(get(m, 0, 1) == 2);
    try std.testing.expect(get(m, 1, 0) == 3);
    try std.testing.expect(get(m, 1, 1) == 4);
}

test "fromCols creates matrix from column vectors" {
    const col0 = vec2.from(1, 2);
    const col1 = vec2.from(3, 4);
    const m = fromCols(col0, col1);
    try std.testing.expect(equal(m, from(1, 3, 2, 4)));
}

test "getCol returns correct column vector" {
    const m = from(1, 2, 3, 4);
    const col0 = getCol(m, 0);
    const col1 = getCol(m, 1);
    try std.testing.expect(vec2.equal(col0, vec2.from(1, 3)));
    try std.testing.expect(vec2.equal(col1, vec2.from(2, 4)));
}

test "getRow returns correct row vector" {
    const m = from(1, 2, 3, 4);
    const row0 = getRow(m, 0);
    const row1 = getRow(m, 1);
    try std.testing.expect(vec2.equal(row0, vec2.from(1, 2)));
    try std.testing.expect(vec2.equal(row1, vec2.from(3, 4)));
}

test "multiply - identity matrix" {
    const m = from(2, 3, 4, 5);
    const id = identity();
    const result = multiply(m, id);
    try std.testing.expect(equal(result, m));
}

test "multiply - matrices" {
    const a = from(1, 2, 3, 4);
    const b = from(5, 6, 7, 8);
    const result = multiply(a, b);
    const expected = from(19, 22, 43, 50);
    try std.testing.expect(equal(result, expected));
}

test "transpose swaps rows and columns" {
    const m = from(1, 2, 3, 4);
    const t = transpose(m);
    try std.testing.expect(equal(t, from(1, 3, 2, 4)));
}

test "determinant calculates correctly" {
    const m = from(3, 8, 4, 6);
    const det = determinant(m);
    try std.testing.expect(det == -14);
}

test "inverse - calculates inverse matrix" {
    const m = from(4, 7, 2, 6);
    const inv = inverse(m).?;
    const product = multiply(m, inv);
    try std.testing.expect(approxEqual(product, identity(), 0.0001));
}

test "inverse - returns null for singular matrix" {
    const m = from(2, 4, 1, 2);
    const inv = inverse(m);
    try std.testing.expect(inv == null);
}

test "transformVec2 transforms vector correctly" {
    const m = rotation(std.math.pi / 2.0);
    const v = vec2.from(1, 0);
    const result = transformVec2(m, v);
    try std.testing.expect(vec2.approxEqual(result, vec2.from(0, 1), 0.0001));
}

test "rotation creates rotation matrix" {
    const angle: f32 = std.math.pi / 4.0;
    const m = rotation(angle);
    const v = vec2.from(1, 0);
    const rotated = transformVec2(m, v);

    const expected_x = @cos(angle);
    const expected_y = @sin(angle);
    try std.testing.expect(@abs(rotated[0] - expected_x) < 0.0001);
    try std.testing.expect(@abs(rotated[1] - expected_y) < 0.0001);
}

test "scaling creates scaling matrix" {
    const m = scaling(2, 3);
    const v = vec2.from(4, 5);
    const scaled = transformVec2(m, v);
    try std.testing.expect(vec2.equal(scaled, vec2.from(8, 15)));
}

test "add matrices" {
    const a = from(1, 2, 3, 4);
    const b = from(5, 6, 7, 8);
    const result = add(a, b);
    try std.testing.expect(equal(result, from(6, 8, 10, 12)));
}

test "sub matrices" {
    const a = from(5, 6, 7, 8);
    const b = from(1, 2, 3, 4);
    const result = sub(a, b);
    try std.testing.expect(equal(result, from(4, 4, 4, 4)));
}

test "scale matrix by scalar" {
    const m = from(1, 2, 3, 4);
    const result = scale(m, 2);
    try std.testing.expect(equal(result, from(2, 4, 6, 8)));
}
