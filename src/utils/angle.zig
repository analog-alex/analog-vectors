const std = @import("std");
const math = std.math;

/// Convert degrees to radians
pub inline fn degToRad(degrees: f32) f32 {
    return degrees * (math.pi / 180.0);
}

/// Convert radians to degrees
pub inline fn radToDeg(radians: f32) f32 {
    return radians * (180.0 / math.pi);
}

/// Wrap angle to range [-π, π]
pub fn wrapPi(angle: f32) f32 {
    var result = @mod(angle + math.pi, 2.0 * math.pi);
    if (result < 0) {
        result += 2.0 * math.pi;
    }
    return result - math.pi;
}

/// Wrap angle to range [0, 2π]
pub fn wrapTwoPi(angle: f32) f32 {
    var result = @mod(angle, 2.0 * math.pi);
    if (result < 0) {
        result += 2.0 * math.pi;
    }
    return result;
}

/// Calculate the shortest rotation between two angles
/// Returns an angle in range [-π, π]
pub fn shortestRotation(from: f32, to: f32) f32 {
    const diff = wrapPi(to - from);
    return diff;
}

/// Linear interpolation between two angles with wrapping
/// t should be in range [0, 1]
/// Returns angle in range [-π, π]
pub fn lerpAngle(from: f32, to: f32, t: f32) f32 {
    const diff = shortestRotation(from, to);
    return wrapPi(from + diff * t);
}

// Tests

test "degToRad converts correctly" {
    const deg_0 = degToRad(0);
    try std.testing.expectApproxEqAbs(0.0, deg_0, 0.0001);

    const deg_90 = degToRad(90);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, deg_90, 0.0001);

    const deg_180 = degToRad(180);
    try std.testing.expectApproxEqAbs(math.pi, deg_180, 0.0001);

    const deg_360 = degToRad(360);
    try std.testing.expectApproxEqAbs(2.0 * math.pi, deg_360, 0.0001);
}

test "radToDeg converts correctly" {
    const rad_0 = radToDeg(0);
    try std.testing.expectApproxEqAbs(0.0, rad_0, 0.0001);

    const rad_pi_2 = radToDeg(math.pi / 2.0);
    try std.testing.expectApproxEqAbs(90.0, rad_pi_2, 0.0001);

    const rad_pi = radToDeg(math.pi);
    try std.testing.expectApproxEqAbs(180.0, rad_pi, 0.0001);

    const rad_2pi = radToDeg(2.0 * math.pi);
    try std.testing.expectApproxEqAbs(360.0, rad_2pi, 0.0001);
}

test "degToRad and radToDeg are inverses" {
    const original_deg: f32 = 45.0;
    const rad = degToRad(original_deg);
    const back_to_deg = radToDeg(rad);
    try std.testing.expectApproxEqAbs(original_deg, back_to_deg, 0.0001);

    const original_rad: f32 = math.pi / 3.0;
    const deg = radToDeg(original_rad);
    const back_to_rad = degToRad(deg);
    try std.testing.expectApproxEqAbs(original_rad, back_to_rad, 0.0001);
}

test "wrapPi normalizes angles to [-π, π]" {
    try std.testing.expectApproxEqAbs(0.0, wrapPi(0), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, wrapPi(math.pi / 2.0), 0.0001);
    try std.testing.expectApproxEqAbs(-math.pi / 2.0, wrapPi(-math.pi / 2.0), 0.0001);

    // Test wrapping from above
    try std.testing.expectApproxEqAbs(0.0, wrapPi(2.0 * math.pi), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, wrapPi(2.0 * math.pi + math.pi / 2.0), 0.0001);

    // Test wrapping from below
    try std.testing.expectApproxEqAbs(0.0, wrapPi(-2.0 * math.pi), 0.0001);
    try std.testing.expectApproxEqAbs(-math.pi / 2.0, wrapPi(-2.0 * math.pi - math.pi / 2.0), 0.0001);

    // π and -π should both wrap to near π (or -π, they're equivalent)
    const pi_wrapped = wrapPi(math.pi);
    const neg_pi_wrapped = wrapPi(-math.pi);
    try std.testing.expect(@abs(pi_wrapped - neg_pi_wrapped) < 0.0001 or @abs(@abs(pi_wrapped) - math.pi) < 0.0001);
}

test "wrapTwoPi normalizes angles to [0, 2π]" {
    try std.testing.expectApproxEqAbs(0.0, wrapTwoPi(0), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, wrapTwoPi(math.pi / 2.0), 0.0001);
    try std.testing.expectApproxEqAbs(3.0 * math.pi / 2.0, wrapTwoPi(-math.pi / 2.0), 0.0001);

    // Test wrapping from above
    try std.testing.expectApproxEqAbs(0.0, wrapTwoPi(2.0 * math.pi), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, wrapTwoPi(2.0 * math.pi + math.pi / 2.0), 0.0001);

    // Test wrapping from below
    try std.testing.expectApproxEqAbs(0.0, wrapTwoPi(-2.0 * math.pi), 0.0001);
    try std.testing.expectApproxEqAbs(3.0 * math.pi / 2.0, wrapTwoPi(-math.pi / 2.0), 0.0001);
}

test "shortestRotation calculates correct rotation" {
    // No rotation
    try std.testing.expectApproxEqAbs(0.0, shortestRotation(0, 0), 0.0001);

    // Simple positive rotation
    try std.testing.expectApproxEqAbs(math.pi / 2.0, shortestRotation(0, math.pi / 2.0), 0.0001);

    // Simple negative rotation
    try std.testing.expectApproxEqAbs(-math.pi / 2.0, shortestRotation(0, -math.pi / 2.0), 0.0001);

    // Wrapping case: going from 0 to -π should be equivalent to going to π (shortest is either direction)
    const rot_to_pi = shortestRotation(0, math.pi);
    try std.testing.expect(@abs(@abs(rot_to_pi) - math.pi) < 0.0001);

    // Going from 0 to 3π/2 should wrap to -π/2 (shorter to go backwards)
    try std.testing.expectApproxEqAbs(-math.pi / 2.0, shortestRotation(0, 3.0 * math.pi / 2.0), 0.0001);

    // Going from 3π/2 to π/2 should wrap to -π (or close to it)
    const rot = shortestRotation(3.0 * math.pi / 2.0, math.pi / 2.0);
    try std.testing.expectApproxEqAbs(-math.pi, rot, 0.0001);
}

test "lerpAngle interpolates correctly" {
    // Lerp from 0 to π/2
    try std.testing.expectApproxEqAbs(0.0, lerpAngle(0, math.pi / 2.0, 0), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 4.0, lerpAngle(0, math.pi / 2.0, 0.5), 0.0001);
    try std.testing.expectApproxEqAbs(math.pi / 2.0, lerpAngle(0, math.pi / 2.0, 1), 0.0001);

    // Lerp with wrapping: from π/2 to -π/2
    // When angles are exactly π apart, both directions are valid
    const mid1 = lerpAngle(math.pi / 2.0, -math.pi / 2.0, 0.5);
    const abs_mid1 = @abs(mid1);
    // Result should be close to either 0 or π (they're equivalent on the circle)
    try std.testing.expect(abs_mid1 < 0.0001 or @abs(abs_mid1 - math.pi) < 0.0001);

    // Lerp from -π/2 to π/2 (reverse direction)
    // When angles are exactly π apart, both directions are valid
    const mid2 = lerpAngle(-math.pi / 2.0, math.pi / 2.0, 0.5);
    const abs_mid2 = @abs(mid2);
    // Result should be close to either 0 or π (they're equivalent on the circle)
    try std.testing.expect(abs_mid2 < 0.0001 or @abs(abs_mid2 - math.pi) < 0.0001);
}
