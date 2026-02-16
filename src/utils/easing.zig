const std = @import("std");
const math = std.math;

/// Clamp a value between 0 and 1
inline fn clamp01(t: f32) f32 {
    return @max(0.0, @min(1.0, t));
}

// ===============
// Ease In Functions

/// Quadratic ease-in: accelerating from zero velocity
pub fn easeInQuad(t: f32) f32 {
    const c = clamp01(t);
    return c * c;
}

/// Cubic ease-in: accelerating from zero velocity
pub fn easeInCubic(t: f32) f32 {
    const c = clamp01(t);
    return c * c * c;
}

/// Quartic ease-in: accelerating from zero velocity
pub fn easeInQuart(t: f32) f32 {
    const c = clamp01(t);
    return c * c * c * c;
}

/// Quintic ease-in: accelerating from zero velocity
pub fn easeInQuint(t: f32) f32 {
    const c = clamp01(t);
    return c * c * c * c * c;
}

/// Exponential ease-in: exponential accelerating from zero velocity
pub fn easeInExpo(t: f32) f32 {
    const c = clamp01(t);
    if (c == 0.0) return 0.0;
    return math.pow(f32, 2.0, 10.0 * (c - 1.0));
}

/// Circular ease-in: circular accelerating from zero velocity
pub fn easeInCirc(t: f32) f32 {
    const c = clamp01(t);
    return 1.0 - @sqrt(1.0 - c * c);
}

/// Back ease-in: overshooting cubic ease-in
pub fn easeInBack(t: f32) f32 {
    const c = clamp01(t);
    const s: f32 = 1.70158;
    return c * c * ((s + 1.0) * c - s);
}

/// Elastic ease-in: exponentially decaying sine wave
pub fn easeInElastic(t: f32) f32 {
    const c = clamp01(t);
    if (c == 0.0) return 0.0;
    if (c == 1.0) return 1.0;
    const p: f32 = 0.3;
    return -math.pow(f32, 2.0, 10.0 * (c - 1.0)) * @sin((c - 1.0 - p / 4.0) * (2.0 * math.pi) / p);
}

/// Bounce ease-in
pub fn easeInBounce(t: f32) f32 {
    return 1.0 - easeOutBounce(1.0 - clamp01(t));
}

// ===============
// Ease Out Functions

/// Quadratic ease-out: decelerating to zero velocity
pub fn easeOutQuad(t: f32) f32 {
    const c = clamp01(t);
    return c * (2.0 - c);
}

/// Cubic ease-out: decelerating to zero velocity
pub fn easeOutCubic(t: f32) f32 {
    const c = clamp01(t) - 1.0;
    return c * c * c + 1.0;
}

/// Quartic ease-out: decelerating to zero velocity
pub fn easeOutQuart(t: f32) f32 {
    const c = clamp01(t) - 1.0;
    return 1.0 - c * c * c * c;
}

/// Quintic ease-out: decelerating to zero velocity
pub fn easeOutQuint(t: f32) f32 {
    const c = clamp01(t) - 1.0;
    return c * c * c * c * c + 1.0;
}

/// Exponential ease-out: exponential decelerating to zero velocity
pub fn easeOutExpo(t: f32) f32 {
    const c = clamp01(t);
    if (c == 1.0) return 1.0;
    return 1.0 - math.pow(f32, 2.0, -10.0 * c);
}

/// Circular ease-out: circular decelerating to zero velocity
pub fn easeOutCirc(t: f32) f32 {
    const c = clamp01(t) - 1.0;
    return @sqrt(1.0 - c * c);
}

/// Back ease-out: overshooting cubic ease-out
pub fn easeOutBack(t: f32) f32 {
    const c = clamp01(t) - 1.0;
    const s: f32 = 1.70158;
    return c * c * ((s + 1.0) * c + s) + 1.0;
}

/// Elastic ease-out: exponentially decaying sine wave
pub fn easeOutElastic(t: f32) f32 {
    const c = clamp01(t);
    if (c == 0.0) return 0.0;
    if (c == 1.0) return 1.0;
    const p: f32 = 0.3;
    return math.pow(f32, 2.0, -10.0 * c) * @sin((c - p / 4.0) * (2.0 * math.pi) / p) + 1.0;
}

/// Bounce ease-out
pub fn easeOutBounce(t: f32) f32 {
    var c = clamp01(t);
    const n1: f32 = 7.5625;
    const d1: f32 = 2.75;

    if (c < 1.0 / d1) {
        return n1 * c * c;
    } else if (c < 2.0 / d1) {
        c -= 1.5 / d1;
        return n1 * c * c + 0.75;
    } else if (c < 2.5 / d1) {
        c -= 2.25 / d1;
        return n1 * c * c + 0.9375;
    } else {
        c -= 2.625 / d1;
        return n1 * c * c + 0.984375;
    }
}

// ===============
// Ease In-Out Functions

/// Quadratic ease-in-out: acceleration until halfway, then deceleration
pub fn easeInOutQuad(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return 2.0 * c * c;
    const d = -2.0 * c + 2.0;
    return 1.0 - d * d / 2.0;
}

/// Cubic ease-in-out: acceleration until halfway, then deceleration
pub fn easeInOutCubic(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return 4.0 * c * c * c;
    const d = -2.0 * c + 2.0;
    return 1.0 - d * d * d / 2.0;
}

/// Quartic ease-in-out: acceleration until halfway, then deceleration
pub fn easeInOutQuart(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return 8.0 * c * c * c * c;
    const d = -2.0 * c + 2.0;
    return 1.0 - d * d * d * d / 2.0;
}

/// Quintic ease-in-out: acceleration until halfway, then deceleration
pub fn easeInOutQuint(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return 16.0 * c * c * c * c * c;
    const d = -2.0 * c + 2.0;
    return 1.0 - d * d * d * d * d / 2.0;
}

/// Exponential ease-in-out
pub fn easeInOutExpo(t: f32) f32 {
    const c = clamp01(t);
    if (c == 0.0) return 0.0;
    if (c == 1.0) return 1.0;
    if (c < 0.5) return math.pow(f32, 2.0, 20.0 * c - 10.0) / 2.0;
    return (2.0 - math.pow(f32, 2.0, -20.0 * c + 10.0)) / 2.0;
}

/// Circular ease-in-out
pub fn easeInOutCirc(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return (1.0 - @sqrt(1.0 - 4.0 * c * c)) / 2.0;
    const d = -2.0 * c + 2.0;
    return (1.0 + @sqrt(1.0 - d * d)) / 2.0;
}

/// Back ease-in-out
pub fn easeInOutBack(t: f32) f32 {
    const c = clamp01(t);
    const s: f32 = 1.70158 * 1.525;
    if (c < 0.5) {
        const d = 2.0 * c;
        return (d * d * ((s + 1.0) * d - s)) / 2.0;
    }
    const d = 2.0 * c - 2.0;
    return (d * d * ((s + 1.0) * d + s) + 2.0) / 2.0;
}

/// Elastic ease-in-out
pub fn easeInOutElastic(t: f32) f32 {
    const c = clamp01(t);
    if (c == 0.0) return 0.0;
    if (c == 1.0) return 1.0;
    if (c < 0.5) {
        return easeInElastic(2.0 * c) * 0.5;
    }
    return easeOutElastic(2.0 * c - 1.0) * 0.5 + 0.5;
}

/// Bounce ease-in-out
pub fn easeInOutBounce(t: f32) f32 {
    const c = clamp01(t);
    if (c < 0.5) return (1.0 - easeOutBounce(1.0 - 2.0 * c)) / 2.0;
    return (1.0 + easeOutBounce(2.0 * c - 1.0)) / 2.0;
}

// ===============
// Tests

const expectApprox = std.testing.expectApproxEqAbs;
const epsilon: f32 = 0.01;

// All easing functions must satisfy: f(0) = 0 and f(1) = 1
test "easeInQuad - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInQuad(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInQuad(1.0), epsilon);
}

test "easeInQuad - midpoint is less than 0.5 (accelerating)" {
    const mid = easeInQuad(0.5);
    try std.testing.expect(mid < 0.5);
    try expectApprox(@as(f32, 0.25), mid, epsilon);
}

test "easeInCubic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInCubic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInCubic(1.0), epsilon);
}

test "easeInCubic - midpoint is less than 0.5 (accelerating)" {
    const mid = easeInCubic(0.5);
    try std.testing.expect(mid < 0.5);
    try expectApprox(@as(f32, 0.125), mid, epsilon);
}

test "easeInQuart - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInQuart(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInQuart(1.0), epsilon);
}

test "easeInQuint - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInQuint(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInQuint(1.0), epsilon);
}

test "easeInExpo - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInExpo(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInExpo(1.0), epsilon);
}

test "easeInCirc - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInCirc(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInCirc(1.0), epsilon);
}

test "easeInBack - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInBack(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInBack(1.0), epsilon);
}

test "easeInBack - goes negative (overshoots)" {
    const val = easeInBack(0.2);
    try std.testing.expect(val < 0.0);
}

test "easeInElastic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInElastic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInElastic(1.0), epsilon);
}

test "easeInBounce - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInBounce(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInBounce(1.0), epsilon);
}

test "easeOutQuad - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutQuad(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutQuad(1.0), epsilon);
}

test "easeOutQuad - midpoint is greater than 0.5 (decelerating)" {
    const mid = easeOutQuad(0.5);
    try std.testing.expect(mid > 0.5);
    try expectApprox(@as(f32, 0.75), mid, epsilon);
}

test "easeOutCubic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutCubic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutCubic(1.0), epsilon);
}

test "easeOutQuart - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutQuart(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutQuart(1.0), epsilon);
}

test "easeOutQuint - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutQuint(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutQuint(1.0), epsilon);
}

test "easeOutExpo - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutExpo(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutExpo(1.0), epsilon);
}

test "easeOutCirc - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutCirc(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutCirc(1.0), epsilon);
}

test "easeOutBack - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutBack(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutBack(1.0), epsilon);
}

test "easeOutBack - overshoots past 1.0" {
    const val = easeOutBack(0.8);
    try std.testing.expect(val > 1.0);
}

test "easeOutElastic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutElastic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutElastic(1.0), epsilon);
}

test "easeOutBounce - boundary values" {
    try expectApprox(@as(f32, 0.0), easeOutBounce(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutBounce(1.0), epsilon);
}

test "easeOutBounce - all regions are covered" {
    // Region 1: t < 1/2.75
    const r1 = easeOutBounce(0.2);
    try std.testing.expect(r1 > 0.0 and r1 < 1.0);

    // Region 2: t < 2/2.75
    const r2 = easeOutBounce(0.5);
    try std.testing.expect(r2 > 0.0 and r2 < 1.0);

    // Region 3: t < 2.5/2.75
    const r3 = easeOutBounce(0.92);
    try std.testing.expect(r3 > 0.0 and r3 < 1.0);

    // Region 4: t >= 2.5/2.75
    const r4 = easeOutBounce(0.98);
    try std.testing.expect(r4 > 0.0 and r4 <= 1.0);
}

test "easeInOutQuad - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutQuad(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutQuad(1.0), epsilon);
}

test "easeInOutQuad - midpoint is exactly 0.5" {
    try expectApprox(@as(f32, 0.5), easeInOutQuad(0.5), epsilon);
}

test "easeInOutCubic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutCubic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutCubic(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutCubic(0.5), epsilon);
}

test "easeInOutQuart - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutQuart(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutQuart(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutQuart(0.5), epsilon);
}

test "easeInOutQuint - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutQuint(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutQuint(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutQuint(0.5), epsilon);
}

test "easeInOutExpo - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutExpo(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutExpo(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutExpo(0.5), epsilon);
}

test "easeInOutCirc - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutCirc(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutCirc(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutCirc(0.5), epsilon);
}

test "easeInOutBack - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutBack(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutBack(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutBack(0.5), epsilon);
}

test "easeInOutElastic - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutElastic(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutElastic(1.0), epsilon);
}

test "easeInOutElastic - symmetric around midpoint" {
    // f(0.5) should be close to 0.5 (elastic center)
    const mid = easeInOutElastic(0.5);
    try expectApprox(@as(f32, 0.5), mid, 0.05);
}

test "easeInOutBounce - boundary values" {
    try expectApprox(@as(f32, 0.0), easeInOutBounce(0.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeInOutBounce(1.0), epsilon);
    try expectApprox(@as(f32, 0.5), easeInOutBounce(0.5), epsilon);
}

test "ease-in is slower at start than ease-out" {
    // At t=0.25, ease-in should be less than linear, ease-out should be more
    const in_val = easeInQuad(0.25);
    const out_val = easeOutQuad(0.25);
    try std.testing.expect(in_val < 0.25);
    try std.testing.expect(out_val > 0.25);
}

test "clamping - values outside [0,1] are clamped" {
    try expectApprox(@as(f32, 0.0), easeInQuad(-0.5), epsilon);
    try expectApprox(@as(f32, 1.0), easeInQuad(1.5), epsilon);
    try expectApprox(@as(f32, 0.0), easeOutCubic(-1.0), epsilon);
    try expectApprox(@as(f32, 1.0), easeOutCubic(2.0), epsilon);
}
