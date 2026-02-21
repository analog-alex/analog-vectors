const std = @import("std");

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
const Vec4 = @Vector(4, f32);
pub const vec4_zero: Vec4 = .{ 0, 0, 0, 0 };
pub const vec4_one: Vec4 = .{ 1, 1, 1, 1 };
pub const vec4_unit_x: Vec4 = .{ 1, 0, 0, 0 };
pub const vec4_unit_y: Vec4 = .{ 0, 1, 0, 0 };
pub const vec4_unit_z: Vec4 = .{ 0, 0, 1, 0 };
pub const vec4_unit_w: Vec4 = .{ 0, 0, 0, 1 };

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
