const std = @import("std");
const math = std.math;

/// Generate a random float in the range [min, max]
pub fn randomFloat(rng: std.Random, min: f32, max: f32) f32 {
    return min + (max - min) * rng.float(f32);
}

/// Generate a random point on the unit circle (2D)
/// Returns [x, y] where x² + y² = 1
pub fn randomPointOnUnitCircle(rng: std.Random) [2]f32 {
    const angle = rng.float(f32) * 2.0 * math.pi;
    return .{
        @cos(angle),
        @sin(angle),
    };
}

/// Generate a random point inside the unit circle (2D)
/// Returns [x, y] where x² + y² ≤ 1
pub fn randomPointInUnitCircle(rng: std.Random) [2]f32 {
    while (true) {
        const x = rng.float(f32) * 2.0 - 1.0;
        const y = rng.float(f32) * 2.0 - 1.0;
        const len_sq = x * x + y * y;
        if (len_sq <= 1.0 and len_sq > 0.0) {
            return .{ x, y };
        }
    }
}

/// Generate a random point on the unit sphere (3D)
/// Returns [x, y, z] where x² + y² + z² = 1
pub fn randomPointOnUnitSphere(rng: std.Random) [3]f32 {
    // Using Marsaglia's method for uniform distribution on sphere
    while (true) {
        const x = rng.float(f32) * 2.0 - 1.0;
        const y = rng.float(f32) * 2.0 - 1.0;
        const len_sq = x * x + y * y;
        if (len_sq < 1.0 and len_sq > 0.0) {
            const scale = 2.0 * @sqrt(1.0 - len_sq);
            return .{
                x * scale,
                y * scale,
                1.0 - 2.0 * len_sq,
            };
        }
    }
}

/// Generate a random point inside the unit sphere (3D)
/// Returns [x, y, z] where x² + y² + z² ≤ 1
pub fn randomPointInUnitSphere(rng: std.Random) [3]f32 {
    while (true) {
        const x = rng.float(f32) * 2.0 - 1.0;
        const y = rng.float(f32) * 2.0 - 1.0;
        const z = rng.float(f32) * 2.0 - 1.0;
        const len_sq = x * x + y * y + z * z;
        if (len_sq <= 1.0 and len_sq > 0.0) {
            return .{ x, y, z };
        }
    }
}

/// Generate a random direction vector (normalized 2D vector)
pub fn randomDirection2D(rng: std.Random) [2]f32 {
    return randomPointOnUnitCircle(rng);
}

/// Generate a random direction vector (normalized 3D vector)
pub fn randomDirection3D(rng: std.Random) [3]f32 {
    return randomPointOnUnitSphere(rng);
}

// Tests

test "randomFloat generates values in range" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    const min: f32 = 10.0;
    const max: f32 = 20.0;

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const val = randomFloat(rng, min, max);
        try std.testing.expect(val >= min);
        try std.testing.expect(val <= max);
    }
}

test "randomPointOnUnitCircle generates points on unit circle" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const point = randomPointOnUnitCircle(rng);
        const len_sq = point[0] * point[0] + point[1] * point[1];
        try std.testing.expectApproxEqAbs(1.0, len_sq, 0.0001);
    }
}

test "randomPointInUnitCircle generates points inside unit circle" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const point = randomPointInUnitCircle(rng);
        const len_sq = point[0] * point[0] + point[1] * point[1];
        try std.testing.expect(len_sq <= 1.0);
        try std.testing.expect(len_sq > 0.0);
    }
}

test "randomPointOnUnitSphere generates points on unit sphere" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const point = randomPointOnUnitSphere(rng);
        const len_sq = point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
        try std.testing.expectApproxEqAbs(1.0, len_sq, 0.0001);
    }
}

test "randomPointInUnitSphere generates points inside unit sphere" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const point = randomPointInUnitSphere(rng);
        const len_sq = point[0] * point[0] + point[1] * point[1] + point[2] * point[2];
        try std.testing.expect(len_sq <= 1.0);
        try std.testing.expect(len_sq > 0.0);
    }
}

test "randomDirection2D generates normalized vectors" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const dir = randomDirection2D(rng);
        const len_sq = dir[0] * dir[0] + dir[1] * dir[1];
        try std.testing.expectApproxEqAbs(1.0, len_sq, 0.0001);
    }
}

test "randomDirection3D generates normalized vectors" {
    var prng = std.Random.DefaultPrng.init(12345);
    const rng = prng.random();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const dir = randomDirection3D(rng);
        const len_sq = dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2];
        try std.testing.expectApproxEqAbs(1.0, len_sq, 0.0001);
    }
}
