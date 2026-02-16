const std = @import("std");
const math = std.math;

/// RGB color with values in range [0, 1]
pub const RGB = struct {
    r: f32,
    g: f32,
    b: f32,

    pub fn from(r: f32, g: f32, b: f32) RGB {
        return .{ .r = r, .g = g, .b = b };
    }
};

/// HSV color (Hue, Saturation, Value)
/// Hue in range [0, 360), Saturation and Value in range [0, 1]
pub const HSV = struct {
    h: f32,
    s: f32,
    v: f32,

    pub fn from(h: f32, s: f32, v: f32) HSV {
        return .{ .h = h, .s = s, .v = v };
    }
};

/// HSL color (Hue, Saturation, Lightness)
/// Hue in range [0, 360), Saturation and Lightness in range [0, 1]
pub const HSL = struct {
    h: f32,
    s: f32,
    l: f32,

    pub fn from(h: f32, s: f32, l: f32) HSL {
        return .{ .h = h, .s = s, .l = l };
    }
};

/// Convert RGB to HSV
pub fn rgbToHsv(rgb: RGB) HSV {
    const r = rgb.r;
    const g = rgb.g;
    const b = rgb.b;

    const max_val = @max(@max(r, g), b);
    const min_val = @min(@min(r, g), b);
    const delta = max_val - min_val;

    var h: f32 = 0;
    var s: f32 = 0;
    const v: f32 = max_val;

    if (delta > 0.00001) {
        s = delta / max_val;

        if (max_val == r) {
            h = 60.0 * (@mod((g - b) / delta, 6.0));
        } else if (max_val == g) {
            h = 60.0 * (((b - r) / delta) + 2.0);
        } else {
            h = 60.0 * (((r - g) / delta) + 4.0);
        }

        if (h < 0) {
            h += 360.0;
        }
    }

    return HSV.from(h, s, v);
}

/// Convert HSV to RGB
pub fn hsvToRgb(hsv: HSV) RGB {
    const h = hsv.h;
    const s = hsv.s;
    const v = hsv.v;

    if (s <= 0.00001) {
        return RGB.from(v, v, v);
    }

    const hh = if (h >= 360.0) 0.0 else h / 60.0;
    const i: i32 = @intFromFloat(@floor(hh));
    const ff = hh - @as(f32, @floatFromInt(i));
    const p = v * (1.0 - s);
    const q = v * (1.0 - (s * ff));
    const t = v * (1.0 - (s * (1.0 - ff)));

    return switch (i) {
        0 => RGB.from(v, t, p),
        1 => RGB.from(q, v, p),
        2 => RGB.from(p, v, t),
        3 => RGB.from(p, q, v),
        4 => RGB.from(t, p, v),
        else => RGB.from(v, p, q),
    };
}

/// Convert RGB to HSL
pub fn rgbToHsl(rgb: RGB) HSL {
    const r = rgb.r;
    const g = rgb.g;
    const b = rgb.b;

    const max_val = @max(@max(r, g), b);
    const min_val = @min(@min(r, g), b);
    const delta = max_val - min_val;

    var h: f32 = 0;
    var s: f32 = 0;
    const l: f32 = (max_val + min_val) / 2.0;

    if (delta > 0.00001) {
        s = if (l < 0.5) delta / (max_val + min_val) else delta / (2.0 - max_val - min_val);

        if (max_val == r) {
            h = 60.0 * (@mod((g - b) / delta, 6.0));
        } else if (max_val == g) {
            h = 60.0 * (((b - r) / delta) + 2.0);
        } else {
            h = 60.0 * (((r - g) / delta) + 4.0);
        }

        if (h < 0) {
            h += 360.0;
        }
    }

    return HSL.from(h, s, l);
}

/// Helper function for HSL to RGB conversion
fn hueToRgb(p: f32, q: f32, t_input: f32) f32 {
    var t = t_input;
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

/// Convert HSL to RGB
pub fn hslToRgb(hsl: HSL) RGB {
    const h = hsl.h / 360.0;
    const s = hsl.s;
    const l = hsl.l;

    if (s <= 0.00001) {
        return RGB.from(l, l, l);
    }

    const q = if (l < 0.5) l * (1.0 + s) else l + s - l * s;
    const p = 2.0 * l - q;

    const r = hueToRgb(p, q, h + 1.0 / 3.0);
    const g = hueToRgb(p, q, h);
    const b = hueToRgb(p, q, h - 1.0 / 3.0);

    return RGB.from(r, g, b);
}

/// Linear interpolation between two RGB colors
pub fn lerpRgb(from: RGB, to: RGB, t: f32) RGB {
    return RGB.from(
        from.r + (to.r - from.r) * t,
        from.g + (to.g - from.g) * t,
        from.b + (to.b - from.b) * t,
    );
}

/// Interpolation in HSV color space
pub fn lerpHsv(from: RGB, to: RGB, t: f32) RGB {
    const from_hsv = rgbToHsv(from);
    const to_hsv = rgbToHsv(to);

    // Interpolate hue using shortest path around the color wheel
    var h_diff = to_hsv.h - from_hsv.h;
    if (h_diff > 180.0) {
        h_diff -= 360.0;
    } else if (h_diff < -180.0) {
        h_diff += 360.0;
    }
    var h = from_hsv.h + h_diff * t;
    if (h < 0) h += 360.0;
    if (h >= 360.0) h -= 360.0;

    const s = from_hsv.s + (to_hsv.s - from_hsv.s) * t;
    const v = from_hsv.v + (to_hsv.v - from_hsv.v) * t;

    return hsvToRgb(HSV.from(h, s, v));
}

/// Interpolation in HSL color space
pub fn lerpHsl(from: RGB, to: RGB, t: f32) RGB {
    const from_hsl = rgbToHsl(from);
    const to_hsl = rgbToHsl(to);

    // Interpolate hue using shortest path around the color wheel
    var h_diff = to_hsl.h - from_hsl.h;
    if (h_diff > 180.0) {
        h_diff -= 360.0;
    } else if (h_diff < -180.0) {
        h_diff += 360.0;
    }
    var h = from_hsl.h + h_diff * t;
    if (h < 0) h += 360.0;
    if (h >= 360.0) h -= 360.0;

    const s = from_hsl.s + (to_hsl.s - from_hsl.s) * t;
    const l = from_hsl.l + (to_hsl.l - from_hsl.l) * t;

    return hslToRgb(HSL.from(h, s, l));
}

/// Apply gamma correction to a color value
pub fn gammaCorrect(value: f32, gamma: f32) f32 {
    return math.pow(f32, value, 1.0 / gamma);
}

/// Apply gamma correction to an RGB color
pub fn gammaCorrectRgb(rgb: RGB, gamma: f32) RGB {
    return RGB.from(
        gammaCorrect(rgb.r, gamma),
        gammaCorrect(rgb.g, gamma),
        gammaCorrect(rgb.b, gamma),
    );
}

/// Remove gamma correction from a color value
pub fn linearize(value: f32, gamma: f32) f32 {
    return math.pow(f32, value, gamma);
}

/// Remove gamma correction from an RGB color
pub fn linearizeRgb(rgb: RGB, gamma: f32) RGB {
    return RGB.from(
        linearize(rgb.r, gamma),
        linearize(rgb.g, gamma),
        linearize(rgb.b, gamma),
    );
}

// Tests

test "RGB to HSV conversion for primary colors" {
    // Red
    const red = RGB.from(1, 0, 0);
    const red_hsv = rgbToHsv(red);
    try std.testing.expectApproxEqAbs(0.0, red_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsv.v, 0.01);

    // Green
    const green = RGB.from(0, 1, 0);
    const green_hsv = rgbToHsv(green);
    try std.testing.expectApproxEqAbs(120.0, green_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsv.v, 0.01);

    // Blue
    const blue = RGB.from(0, 0, 1);
    const blue_hsv = rgbToHsv(blue);
    try std.testing.expectApproxEqAbs(240.0, blue_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsv.v, 0.01);
}

test "HSV to RGB conversion for primary colors" {
    // Red
    const red_hsv = HSV.from(0, 1, 1);
    const red = hsvToRgb(red_hsv);
    try std.testing.expectApproxEqAbs(1.0, red.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.b, 0.01);

    // Green
    const green_hsv = HSV.from(120, 1, 1);
    const green = hsvToRgb(green_hsv);
    try std.testing.expectApproxEqAbs(0.0, green.r, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, green.b, 0.01);

    // Blue
    const blue_hsv = HSV.from(240, 1, 1);
    const blue = hsvToRgb(blue_hsv);
    try std.testing.expectApproxEqAbs(0.0, blue.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, blue.g, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue.b, 0.01);
}

test "RGB to HSV roundtrip" {
    const original = RGB.from(0.5, 0.7, 0.3);
    const hsv = rgbToHsv(original);
    const back = hsvToRgb(hsv);

    try std.testing.expectApproxEqAbs(original.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(original.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(original.b, back.b, 0.01);
}

test "RGB to HSL conversion for primary colors" {
    // Red
    const red = RGB.from(1, 0, 0);
    const red_hsl = rgbToHsl(red);
    try std.testing.expectApproxEqAbs(0.0, red_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, red_hsl.l, 0.01);

    // Green
    const green = RGB.from(0, 1, 0);
    const green_hsl = rgbToHsl(green);
    try std.testing.expectApproxEqAbs(120.0, green_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, green_hsl.l, 0.01);

    // Blue
    const blue = RGB.from(0, 0, 1);
    const blue_hsl = rgbToHsl(blue);
    try std.testing.expectApproxEqAbs(240.0, blue_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, blue_hsl.l, 0.01);
}

test "HSL to RGB conversion for primary colors" {
    // Red
    const red_hsl = HSL.from(0, 1, 0.5);
    const red = hslToRgb(red_hsl);
    try std.testing.expectApproxEqAbs(1.0, red.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.b, 0.01);

    // Green
    const green_hsl = HSL.from(120, 1, 0.5);
    const green = hslToRgb(green_hsl);
    try std.testing.expectApproxEqAbs(0.0, green.r, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, green.b, 0.01);

    // Blue
    const blue_hsl = HSL.from(240, 1, 0.5);
    const blue = hslToRgb(blue_hsl);
    try std.testing.expectApproxEqAbs(0.0, blue.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, blue.g, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue.b, 0.01);
}

test "RGB to HSL roundtrip" {
    const original = RGB.from(0.5, 0.7, 0.3);
    const hsl = rgbToHsl(original);
    const back = hslToRgb(hsl);

    try std.testing.expectApproxEqAbs(original.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(original.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(original.b, back.b, 0.01);
}

test "lerpRgb interpolates correctly" {
    const black = RGB.from(0, 0, 0);
    const white = RGB.from(1, 1, 1);

    const mid = lerpRgb(black, white, 0.5);
    try std.testing.expectApproxEqAbs(0.5, mid.r, 0.01);
    try std.testing.expectApproxEqAbs(0.5, mid.g, 0.01);
    try std.testing.expectApproxEqAbs(0.5, mid.b, 0.01);
}

test "gamma correction" {
    const value: f32 = 0.5;
    const gamma: f32 = 2.2;

    const corrected = gammaCorrect(value, gamma);
    const back = linearize(corrected, gamma);

    try std.testing.expectApproxEqAbs(value, back, 0.01);
}

test "gamma correction RGB" {
    const color = RGB.from(0.5, 0.6, 0.7);
    const gamma: f32 = 2.2;

    const corrected = gammaCorrectRgb(color, gamma);
    const back = linearizeRgb(corrected, gamma);

    try std.testing.expectApproxEqAbs(color.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(color.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(color.b, back.b, 0.01);
}
