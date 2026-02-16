// @analogAlex
const std = @import("std");
const vec3 = @import("../vectors/vec3.zig");

pub const Vec3 = vec3.Vec3;

pub const Segment = struct {
    start: Vec3,
    end: Vec3,
};

pub fn from(start: Vec3, end: Vec3) Segment {
    return .{ .start = start, .end = end };
}

pub inline fn direction(s: Segment) Vec3 {
    return vec3.sub(s.end, s.start);
}

pub inline fn lengthSquared(s: Segment) f32 {
    return vec3.lengthSquared(direction(s));
}

pub inline fn length(s: Segment) f32 {
    return vec3.length(direction(s));
}

pub fn midpoint(s: Segment) Vec3 {
    return vec3.lerp(s.start, s.end, 0.5);
}

pub fn pointAt(s: Segment, t: f32) Vec3 {
    return vec3.lerp(s.start, s.end, t);
}

pub fn closestPointToPoint(s: Segment, p: Vec3) Vec3 {
    const ab = direction(s);
    const ap = vec3.sub(p, s.start);
    const len_sq = vec3.lengthSquared(ab);
    if (len_sq == 0) return s.start;
    const t = @max(0.0, @min(1.0, vec3.dot(ap, ab) / len_sq));
    return pointAt(s, t);
}

// ===============
// Tests

test "direction - returns end minus start" {
    // given
    const s = from(vec3.from(1, 2, 3), vec3.from(4, 6, 8));

    // when
    const d = direction(s);

    // then
    try std.testing.expect(vec3.equal(d, vec3.from(3, 4, 5)));
}

test "length - calculates segment length" {
    // given
    const s = from(vec3.from(0, 0, 0), vec3.from(3, 4, 0));

    // when
    const l = length(s);

    // then
    try std.testing.expectApproxEqAbs(@as(f32, 5.0), l, 0.0001);
}

test "midpoint - returns center of segment" {
    // given
    const s = from(vec3.from(0, 0, 0), vec3.from(10, 10, 10));

    // when
    const m = midpoint(s);

    // then
    try std.testing.expect(vec3.equal(m, vec3.from(5, 5, 5)));
}

test "closestPointToPoint - returns start when projected before segment" {
    // given
    const s = from(vec3.from(0, 0, 0), vec3.from(10, 0, 0));
    const p = vec3.from(-5, 3, 0);

    // when
    const closest = closestPointToPoint(s, p);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.from(0, 0, 0), 0.0001));
}

test "closestPointToPoint - returns end when projected beyond segment" {
    // given
    const s = from(vec3.from(0, 0, 0), vec3.from(10, 0, 0));
    const p = vec3.from(15, 3, 0);

    // when
    const closest = closestPointToPoint(s, p);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.from(10, 0, 0), 0.0001));
}

test "closestPointToPoint - returns projection onto segment" {
    // given
    const s = from(vec3.from(0, 0, 0), vec3.from(10, 0, 0));
    const p = vec3.from(5, 3, 0);

    // when
    const closest = closestPointToPoint(s, p);

    // then
    try std.testing.expect(vec3.approxEqual(closest, vec3.from(5, 0, 0), 0.0001));
}
