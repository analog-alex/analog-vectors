const std = @import("std");
const math = std.math;

/// RGBA color with values in range [0, 1]
pub const RGBA = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32 = 1.0,

    const Self = @This();

    pub fn from(r: f32, g: f32, b: f32, a: f32) RGBA {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    pub fn fromRgb(r: f32, g: f32, b: f32) RGBA {
        return .{ .r = r, .g = g, .b = b };
    }

    pub const Black = Self.fromRgb(0, 0, 0);
    pub const White = Self.fromRgb(1, 1, 1);
    pub const Red = Self.fromRgb(1, 0, 0);
    pub const Green = Self.fromRgb(0, 1, 0);
    pub const Blue = Self.fromRgb(0, 0, 1);
    pub const Yellow = Self.fromRgb(1, 1, 0);
    pub const Cyan = Self.fromRgb(0, 1, 1);
    pub const Magenta = Self.fromRgb(1, 0, 1);
    pub const Gray = Self.fromRgb(0.5, 0.5, 0.5);
    pub const DarkGray = Self.fromRgb(0.25, 0.25, 0.25);
    pub const LightGray = Self.fromRgb(0.75, 0.75, 0.75);
    pub const Orange = Self.fromRgb(1, 0.647, 0);
    pub const Purple = Self.fromRgb(0.5, 0, 0.5);
    pub const Pink = Self.fromRgb(1, 0.753, 0.796);
    pub const Brown = Self.fromRgb(0.647, 0.165, 0.165);
    pub const Lime = Self.fromRgb(0.75, 1, 0);
    pub const Navy = Self.fromRgb(0, 0, 0.5);
    pub const Teal = Self.fromRgb(0, 0.5, 0.5);
    pub const Maroon = Self.fromRgb(0.5, 0, 0);
    pub const Olive = Self.fromRgb(0.5, 0.5, 0);
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

/// Convert RGBA to HSV
pub fn rgbaToHsv(rgba: RGBA) HSV {
    const r = rgba.r;
    const g = rgba.g;
    const b = rgba.b;

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

/// Convert HSV to RGBA
pub fn hsvToRgba(hsv: HSV) RGBA {
    const h = hsv.h;
    const s = hsv.s;
    const v = hsv.v;

    if (s <= 0.00001) {
        return RGBA.fromRgb(v, v, v);
    }

    const hh = if (h >= 360.0) 0.0 else h / 60.0;
    const i: i32 = @intFromFloat(@floor(hh));
    const ff = hh - @as(f32, @floatFromInt(i));
    const p = v * (1.0 - s);
    const q = v * (1.0 - (s * ff));
    const t = v * (1.0 - (s * (1.0 - ff)));

    return switch (i) {
        0 => RGBA.fromRgb(v, t, p),
        1 => RGBA.fromRgb(q, v, p),
        2 => RGBA.fromRgb(p, v, t),
        3 => RGBA.fromRgb(p, q, v),
        4 => RGBA.fromRgb(t, p, v),
        else => RGBA.fromRgb(v, p, q),
    };
}

/// Convert RGBA to HSL
pub fn rgbaToHsl(rgba: RGBA) HSL {
    const r = rgba.r;
    const g = rgba.g;
    const b = rgba.b;

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

/// Helper function for HSL to RGBA conversion
fn hueToRgba(p: f32, q: f32, t_input: f32) f32 {
    var t = t_input;
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

/// Convert HSL to RGBA
pub fn hslToRgba(hsl: HSL) RGBA {
    const h = hsl.h / 360.0;
    const s = hsl.s;
    const l = hsl.l;

    if (s <= 0.00001) {
        return RGBA.fromRgb(l, l, l);
    }

    const q = if (l < 0.5) l * (1.0 + s) else l + s - l * s;
    const p = 2.0 * l - q;

    const r = hueToRgba(p, q, h + 1.0 / 3.0);
    const g = hueToRgba(p, q, h);
    const b = hueToRgba(p, q, h - 1.0 / 3.0);

    return RGBA.fromRgb(r, g, b);
}

/// Linear interpolation between two RGBA colors
pub fn lerpRgba(from: RGBA, to: RGBA, t: f32) RGBA {
    return RGBA.from(
        from.r + (to.r - from.r) * t,
        from.g + (to.g - from.g) * t,
        from.b + (to.b - from.b) * t,
        from.a + (to.a - from.a) * t,
    );
}

/// Interpolation in HSV color space
pub fn lerpHsv(from: RGBA, to: RGBA, t: f32) RGBA {
    const from_hsv = rgbaToHsv(from);
    const to_hsv = rgbaToHsv(to);

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

    return hsvToRgba(HSV.from(h, s, v));
}

/// Interpolation in HSL color space
pub fn lerpHsl(from: RGBA, to: RGBA, t: f32) RGBA {
    const from_hsl = rgbaToHsl(from);
    const to_hsl = rgbaToHsl(to);

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

    return hslToRgba(HSL.from(h, s, l));
}

/// Apply gamma correction to a color value
pub fn gammaCorrect(value: f32, gamma: f32) f32 {
    return math.pow(f32, value, 1.0 / gamma);
}

/// Apply gamma correction to an RGBA color
pub fn gammaCorrectRgba(rgba: RGBA, gamma: f32) RGBA {
    return RGBA.from(
        gammaCorrect(rgba.r, gamma),
        gammaCorrect(rgba.g, gamma),
        gammaCorrect(rgba.b, gamma),
        rgba.a,
    );
}

/// Remove gamma correction from a color value
pub fn linearize(value: f32, gamma: f32) f32 {
    return math.pow(f32, value, gamma);
}

/// Remove gamma correction from an RGBA color
pub fn linearizeRgba(rgba: RGBA, gamma: f32) RGBA {
    return RGBA.from(
        linearize(rgba.r, gamma),
        linearize(rgba.g, gamma),
        linearize(rgba.b, gamma),
        rgba.a,
    );
}

// Tests

test "RGBA predefined constants" {
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Black.r, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Black.g, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Black.b, 0.0001);

    try std.testing.expectApproxEqAbs(@as(f32, 1), RGBA.White.r, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 1), RGBA.White.g, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 1), RGBA.White.b, 0.0001);

    try std.testing.expectApproxEqAbs(@as(f32, 1), RGBA.Red.r, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Red.g, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Red.b, 0.0001);

    try std.testing.expectApproxEqAbs(@as(f32, 1), RGBA.Orange.r, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.647), RGBA.Orange.g, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Orange.b, 0.0001);

    try std.testing.expectApproxEqAbs(@as(f32, 0), RGBA.Teal.r, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.5), RGBA.Teal.g, 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.5), RGBA.Teal.b, 0.0001);
}

test "RGBA to HSV conversion for primary colors" {
    // Red
    const red = RGBA.fromRgb(1, 0, 0);
    const red_hsv = rgbaToHsv(red);
    try std.testing.expectApproxEqAbs(0.0, red_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsv.v, 0.01);

    // Green
    const green = RGBA.fromRgb(0, 1, 0);
    const green_hsv = rgbaToHsv(green);
    try std.testing.expectApproxEqAbs(120.0, green_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsv.v, 0.01);

    // Blue
    const blue = RGBA.fromRgb(0, 0, 1);
    const blue_hsv = rgbaToHsv(blue);
    try std.testing.expectApproxEqAbs(240.0, blue_hsv.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsv.s, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsv.v, 0.01);
}

test "HSV to RGBA conversion for primary colors" {
    // Red
    const red_hsv = HSV.from(0, 1, 1);
    const red = hsvToRgba(red_hsv);
    try std.testing.expectApproxEqAbs(1.0, red.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.b, 0.01);

    // Green
    const green_hsv = HSV.from(120, 1, 1);
    const green = hsvToRgba(green_hsv);
    try std.testing.expectApproxEqAbs(0.0, green.r, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, green.b, 0.01);

    // Blue
    const blue_hsv = HSV.from(240, 1, 1);
    const blue = hsvToRgba(blue_hsv);
    try std.testing.expectApproxEqAbs(0.0, blue.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, blue.g, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue.b, 0.01);
}

test "RGBA to HSV roundtrip" {
    const original = RGBA.fromRgb(0.5, 0.7, 0.3);
    const hsv = rgbaToHsv(original);
    const back = hsvToRgba(hsv);

    try std.testing.expectApproxEqAbs(original.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(original.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(original.b, back.b, 0.01);
}

test "RGBA to HSL conversion for primary colors" {
    // Red
    const red = RGBA.fromRgb(1, 0, 0);
    const red_hsl = rgbaToHsl(red);
    try std.testing.expectApproxEqAbs(0.0, red_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, red_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, red_hsl.l, 0.01);

    // Green
    const green = RGBA.fromRgb(0, 1, 0);
    const green_hsl = rgbaToHsl(green);
    try std.testing.expectApproxEqAbs(120.0, green_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, green_hsl.l, 0.01);

    // Blue
    const blue = RGBA.fromRgb(0, 0, 1);
    const blue_hsl = rgbaToHsl(blue);
    try std.testing.expectApproxEqAbs(240.0, blue_hsl.h, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue_hsl.s, 0.01);
    try std.testing.expectApproxEqAbs(0.5, blue_hsl.l, 0.01);
}

test "HSL to RGBA conversion for primary colors" {
    // Red
    const red_hsl = HSL.from(0, 1, 0.5);
    const red = hslToRgba(red_hsl);
    try std.testing.expectApproxEqAbs(1.0, red.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, red.b, 0.01);

    // Green
    const green_hsl = HSL.from(120, 1, 0.5);
    const green = hslToRgba(green_hsl);
    try std.testing.expectApproxEqAbs(0.0, green.r, 0.01);
    try std.testing.expectApproxEqAbs(1.0, green.g, 0.01);
    try std.testing.expectApproxEqAbs(0.0, green.b, 0.01);

    // Blue
    const blue_hsl = HSL.from(240, 1, 0.5);
    const blue = hslToRgba(blue_hsl);
    try std.testing.expectApproxEqAbs(0.0, blue.r, 0.01);
    try std.testing.expectApproxEqAbs(0.0, blue.g, 0.01);
    try std.testing.expectApproxEqAbs(1.0, blue.b, 0.01);
}

test "RGBA to HSL roundtrip" {
    const original = RGBA.fromRgb(0.5, 0.7, 0.3);
    const hsl = rgbaToHsl(original);
    const back = hslToRgba(hsl);

    try std.testing.expectApproxEqAbs(original.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(original.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(original.b, back.b, 0.01);
}

test "lerpRgba interpolates correctly" {
    const black = RGBA.fromRgb(0, 0, 0);
    const white = RGBA.fromRgb(1, 1, 1);

    const mid = lerpRgba(black, white, 0.5);
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

test "gamma correction RGBA" {
    const color = RGBA.fromRgb(0.5, 0.6, 0.7);
    const gamma: f32 = 2.2;

    const corrected = gammaCorrectRgba(color, gamma);
    const back = linearizeRgba(corrected, gamma);

    try std.testing.expectApproxEqAbs(color.r, back.r, 0.01);
    try std.testing.expectApproxEqAbs(color.g, back.g, 0.01);
    try std.testing.expectApproxEqAbs(color.b, back.b, 0.01);
}

test "RGBA default alpha is 1" {
    const c = RGBA.fromRgb(0.5, 0.5, 0.5);
    try std.testing.expectApproxEqAbs(1.0, c.a, 0.01);
}

test "RGBA from with explicit alpha" {
    const c = RGBA.from(0.5, 0.5, 0.5, 0.5);
    try std.testing.expectApproxEqAbs(0.5, c.a, 0.01);
}
