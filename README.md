# Vectors

A lightweight and efficient Zig library for 2D and 3D vector mathematics.

## Features

- **Vec2**: 2D vector operations (`[2]f32`)
- **Vec3**: 3D vector operations (`[3]f32`)
- Array-based implementation for optimal performance
- Comprehensive test coverage
- Inline functions for critical accessors
- Zero dependencies beyond Zig standard library

### Available Operations

**Arithmetic**
- Addition, subtraction, negation
- Scalar multiplication and division

**Geometric**
- Length (magnitude) and squared length
- Normalization
- Distance between vectors
- Dot product
- Cross product (2D returns scalar, 3D returns vector)

**Transformations**
- Linear interpolation (lerp)
- Clamping
- Component-wise min/max
- Rotation (2D: by angle, 3D: around axis)

**Utilities**
- Angle calculations
- Equality checks (exact and approximate)
- Common vector constants (zero, one, unit vectors)

## Installation

### Using Zig Package Manager

Add this to your `build.zig.zon`:

```zig
.dependencies = .{
    .vectors = .{
        .url = "https://github.com/YOUR_USERNAME/vectors/archive/VERSION.tar.gz",
        .hash = "...",
    },
},
```

Then in your `build.zig`:

```zig
const vectors = b.dependency("vectors", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("vectors", vectors.module("vectors"));
```

### Manual Installation

Clone the repository and import it as a local dependency in your project.

## Usage

```zig
const std = @import("std");
const vectors = @import("vectors");
const vec2 = vectors.vec2;
const vec3 = vectors.vec3;

pub fn main() void {
    // 2D Vector Operations
    const a = vec2.from(3, 4);
    const b = vec2.from(1, 2);

    const sum = vec2.sum(a, b);              // [4, 6]
    const length = vec2.length(a);           // 5.0
    const normalized = vec2.normalize(a);    // [0.6, 0.8]
    const dot = vec2.dot(a, b);             // 11.0

    // Rotation
    const rotated = vec2.rotate(a, std.math.pi / 2); // Rotate 90 degrees

    // 3D Vector Operations
    const v1 = vec3.from(1, 0, 0);
    const v2 = vec3.from(0, 1, 0);

    const cross = vec3.cross(v1, v2);       // [0, 0, 1] (unit Z)
    const angle = vec3.angleBetween(v1, v2); // π/2 radians

    // Rotation around arbitrary axis
    const axis = vec3.normalize(vec3.from(1, 1, 0));
    const rotated3d = vec3.rotate(v1, axis, std.math.pi / 4);
}
```

## API Reference

### Vec2

#### Construction & Accessors
```zig
pub fn from(x: f32, y: f32) Vec2
pub fn X(v: Vec2) f32
pub fn Y(v: Vec2) f32
```

#### Arithmetic
```zig
pub fn sum(lhs: Vec2, rhs: Vec2) Vec2
pub fn sub(lhs: Vec2, rhs: Vec2) Vec2
pub fn mul(v: Vec2, scalar: f32) Vec2
pub fn div(v: Vec2, scalar: f32) Vec2
pub fn neg(v: Vec2) Vec2
```

#### Length & Distance
```zig
pub fn length(v: Vec2) f32
pub fn lengthSquared(v: Vec2) f32
pub fn normalize(v: Vec2) Vec2
pub fn distance(a: Vec2, b: Vec2) f32
pub fn distanceSquared(a: Vec2, b: Vec2) f32
```

#### Products
```zig
pub fn dot(lhs: Vec2, rhs: Vec2) f32
pub fn cross(lhs: Vec2, rhs: Vec2) f32  // 2D cross product (scalar)
```

#### Interpolation & Clamping
```zig
pub fn lerp(a: Vec2, b: Vec2, t: f32) Vec2
pub fn clamp(v: Vec2, min_v: Vec2, max_v: Vec2) Vec2
```

#### Angles
```zig
pub fn angle(v: Vec2) f32
pub fn angleBetween(a: Vec2, b: Vec2) f32
pub fn rotate(v: Vec2, radians: f32) Vec2
```

#### Utilities
```zig
pub fn equal(a: Vec2, b: Vec2) bool
pub fn approxEqual(a: Vec2, b: Vec2, epsilon: f32) bool
pub fn min(a: Vec2, b: Vec2) Vec2
pub fn max(a: Vec2, b: Vec2) Vec2
pub fn zero() Vec2
pub fn one() Vec2
pub fn unitX() Vec2
pub fn unitY() Vec2
```

### Vec3

Vec3 provides the same operations as Vec2, with these differences:

#### Construction & Accessors
```zig
pub fn from(x: f32, y: f32, z: f32) Vec3
pub fn X(v: Vec3) f32
pub fn Y(v: Vec3) f32
pub fn Z(v: Vec3) f32
```

#### Products
```zig
pub fn dot(lhs: Vec3, rhs: Vec3) f32
pub fn cross(lhs: Vec3, rhs: Vec3) Vec3  // 3D cross product (vector)
```

#### Rotation
```zig
pub fn rotate(v: Vec3, axis: Vec3, radians: f32) Vec3  // Rodrigues' rotation
```

#### Additional Constants
```zig
pub fn unitZ() Vec3
```

Note: Vec3 does not have a 2-argument `angle()` function (only `angleBetween()`).

## Building

```bash
# Run all tests
zig build test

# Build the module
zig build

# Get help
zig build --help
```

## Requirements

- Zig 0.15.1 or later

## Project Structure

```
vectors/
├── build.zig          # Build configuration
├── build.zig.zon      # Package manifest
├── src/
│   ├── root.zig       # Library entry point
│   └── vectors/
│       ├── vec2.zig   # 2D vector implementation
│       └── vec3.zig   # 3D vector implementation
└── README.md
```

## License

[Specify your license here]

## Contributing

Contributions are welcome! Please ensure all tests pass before submitting a pull request.

```bash
zig build test
```
