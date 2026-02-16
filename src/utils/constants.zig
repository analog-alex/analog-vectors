const std = @import("std");
const color = @import("color.zig");

// Vector constants - Vec2
pub const vec2_zero = [2]f32{ 0, 0 };
pub const vec2_one = [2]f32{ 1, 1 };
pub const vec2_unit_x = [2]f32{ 1, 0 };
pub const vec2_unit_y = [2]f32{ 0, 1 };
pub const vec2_left = [2]f32{ -1, 0 };
pub const vec2_right = [2]f32{ 1, 0 };
pub const vec2_up = [2]f32{ 0, 1 };
pub const vec2_down = [2]f32{ 0, -1 };

// Vector constants - Vec3
pub const vec3_zero = [3]f32{ 0, 0, 0 };
pub const vec3_one = [3]f32{ 1, 1, 1 };
pub const vec3_unit_x = [3]f32{ 1, 0, 0 };
pub const vec3_unit_y = [3]f32{ 0, 1, 0 };
pub const vec3_unit_z = [3]f32{ 0, 0, 1 };
pub const vec3_left = [3]f32{ -1, 0, 0 };
pub const vec3_right = [3]f32{ 1, 0, 0 };
pub const vec3_up = [3]f32{ 0, 1, 0 };
pub const vec3_down = [3]f32{ 0, -1, 0 };
pub const vec3_forward = [3]f32{ 0, 0, 1 };
pub const vec3_back = [3]f32{ 0, 0, -1 };

// Vector constants - Vec4
pub const vec4_zero = [4]f32{ 0, 0, 0, 0 };
pub const vec4_one = [4]f32{ 1, 1, 1, 1 };
pub const vec4_unit_x = [4]f32{ 1, 0, 0, 0 };
pub const vec4_unit_y = [4]f32{ 0, 1, 0, 0 };
pub const vec4_unit_z = [4]f32{ 0, 0, 1, 0 };
pub const vec4_unit_w = [4]f32{ 0, 0, 0, 1 };

// Common color constants (RGB values in range [0, 1])
pub const color_black = color.RGB.from(0, 0, 0);
pub const color_white = color.RGB.from(1, 1, 1);
pub const color_red = color.RGB.from(1, 0, 0);
pub const color_green = color.RGB.from(0, 1, 0);
pub const color_blue = color.RGB.from(0, 0, 1);
pub const color_yellow = color.RGB.from(1, 1, 0);
pub const color_cyan = color.RGB.from(0, 1, 1);
pub const color_magenta = color.RGB.from(1, 0, 1);
pub const color_gray = color.RGB.from(0.5, 0.5, 0.5);
pub const color_dark_gray = color.RGB.from(0.25, 0.25, 0.25);
pub const color_light_gray = color.RGB.from(0.75, 0.75, 0.75);

// Common color constants - Extended palette
pub const color_orange = color.RGB.from(1, 0.647, 0);
pub const color_purple = color.RGB.from(0.5, 0, 0.5);
pub const color_pink = color.RGB.from(1, 0.753, 0.796);
pub const color_brown = color.RGB.from(0.647, 0.165, 0.165);
pub const color_lime = color.RGB.from(0.75, 1, 0);
pub const color_navy = color.RGB.from(0, 0, 0.5);
pub const color_teal = color.RGB.from(0, 0.5, 0.5);
pub const color_maroon = color.RGB.from(0.5, 0, 0);
pub const color_olive = color.RGB.from(0.5, 0.5, 0);

// Tests

test "vec2 constants have correct values" {
    try std.testing.expectEqual(@as(f32, 0), vec2_zero[0]);
    try std.testing.expectEqual(@as(f32, 0), vec2_zero[1]);

    try std.testing.expectEqual(@as(f32, 1), vec2_one[0]);
    try std.testing.expectEqual(@as(f32, 1), vec2_one[1]);

    try std.testing.expectEqual(@as(f32, 1), vec2_unit_x[0]);
    try std.testing.expectEqual(@as(f32, 0), vec2_unit_x[1]);

    try std.testing.expectEqual(@as(f32, 0), vec2_unit_y[0]);
    try std.testing.expectEqual(@as(f32, 1), vec2_unit_y[1]);
}

test "vec3 constants have correct values" {
    try std.testing.expectEqual(@as(f32, 0), vec3_zero[0]);
    try std.testing.expectEqual(@as(f32, 0), vec3_zero[1]);
    try std.testing.expectEqual(@as(f32, 0), vec3_zero[2]);

    try std.testing.expectEqual(@as(f32, 1), vec3_one[0]);
    try std.testing.expectEqual(@as(f32, 1), vec3_one[1]);
    try std.testing.expectEqual(@as(f32, 1), vec3_one[2]);

    try std.testing.expectEqual(@as(f32, 1), vec3_unit_x[0]);
    try std.testing.expectEqual(@as(f32, 0), vec3_unit_y[0]);
    try std.testing.expectEqual(@as(f32, 0), vec3_unit_z[0]);

    try std.testing.expectEqual(@as(f32, 0), vec3_forward[0]);
    try std.testing.expectEqual(@as(f32, 0), vec3_forward[1]);
    try std.testing.expectEqual(@as(f32, 1), vec3_forward[2]);
}

test "vec4 constants have correct values" {
    try std.testing.expectEqual(@as(f32, 0), vec4_zero[0]);
    try std.testing.expectEqual(@as(f32, 0), vec4_zero[1]);
    try std.testing.expectEqual(@as(f32, 0), vec4_zero[2]);
    try std.testing.expectEqual(@as(f32, 0), vec4_zero[3]);

    try std.testing.expectEqual(@as(f32, 1), vec4_one[0]);
    try std.testing.expectEqual(@as(f32, 1), vec4_one[1]);
    try std.testing.expectEqual(@as(f32, 1), vec4_one[2]);
    try std.testing.expectEqual(@as(f32, 1), vec4_one[3]);
}

test "color constants have correct values" {
    try std.testing.expectEqual(@as(f32, 0), color_black.r);
    try std.testing.expectEqual(@as(f32, 0), color_black.g);
    try std.testing.expectEqual(@as(f32, 0), color_black.b);

    try std.testing.expectEqual(@as(f32, 1), color_white.r);
    try std.testing.expectEqual(@as(f32, 1), color_white.g);
    try std.testing.expectEqual(@as(f32, 1), color_white.b);

    try std.testing.expectEqual(@as(f32, 1), color_red.r);
    try std.testing.expectEqual(@as(f32, 0), color_red.g);
    try std.testing.expectEqual(@as(f32, 0), color_red.b);

    try std.testing.expectEqual(@as(f32, 0), color_green.r);
    try std.testing.expectEqual(@as(f32, 1), color_green.g);
    try std.testing.expectEqual(@as(f32, 0), color_green.b);

    try std.testing.expectEqual(@as(f32, 0), color_blue.r);
    try std.testing.expectEqual(@as(f32, 0), color_blue.g);
    try std.testing.expectEqual(@as(f32, 1), color_blue.b);
}
