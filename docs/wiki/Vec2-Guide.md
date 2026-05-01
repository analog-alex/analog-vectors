# Vec2 Guide

## Purpose

Show the most common `vec2` operations with examples that match the current public API and project terminology.

## Audience

Users who already installed the package and want a practical tour of 2D vector operations.

## Related Links

- [Home](./Home.md)
- [Getting Started](./Getting-Started.md)
- [Vec2 source](../../src/vectors/vec2.zig)
- [Examples/Cookbook](./Examples-Cookbook.md)

## Construction

```zig
const vec2 = vectors.vec2;

const origin = vec2.zero();
const unit_x = vec2.unitX();
const point = vec2.init(2, 3);
```

## Arithmetic

```zig
const moved = vec2.sum(point, unit_x);
const delta = vec2.sub(moved, origin);
const scaled = vec2.scale(delta, 0.5);
```

## Analysis

```zig
const len = vec2.length(point);
const unit = vec2.normalize(point);
const alignment = vec2.dot(point, unit_x);
const area_sign = vec2.cross(point, unit_x);
```

## Rotation

```zig
const quarter_turn = vec2.rotate(point, std.math.pi / 2.0);
```

Read the implementation in [`src/vectors/vec2.zig`](../../src/vectors/vec2.zig) when exact edge-case behavior matters.
