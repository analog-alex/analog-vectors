# analog-vectors

A lightweight Zig math library for vectors, matrices, quaternions, geometry, and SIMD-friendly geometry helpers.

## Requirements

- Zig `0.15.1` or newer

## Features

- Vectors: `vec2`, `vec3`, `vec4`
- Matrices: `mat2`, `mat3`, `mat4`
- Complex: quaternion module (`quat`)
- Geometry: `ray`, `segment`, `plane`, `aabb`, `obb`, `sphere`, `capsule`, `frustum`, `intersect`
- SIMD geometry (`@Vector(4, f32)` based): `simd_ray`, `simd_plane`, `simd_aabb`, `simd_sphere`, `simd_intersect`, `simd_conversions`
- Utilities: `angle`, `color`, `random`, `constants`, `math_utils`, `easing`, `interpolation`

## Install (Zig package manager)

Add this to your `build.zig.zon` dependencies:

```zig
.dependencies = .{
    .vectors = .{
        .url = "https://github.com/analogAlex/analog-vectors/archive/refs/tags/v0.1.0.tar.gz",
        .hash = "<fill-with-zig-fetch-hash>",
    },
},
```

Then wire it in `build.zig`:

```zig
const vectors_dep = b.dependency("vectors", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("vectors", vectors_dep.module("vectors"));
```

## Usage

```zig
const std = @import("std");
const vectors = @import("vectors");

const vec3 = vectors.vec3;
const mat4 = vectors.mat4;
const ray = vectors.ray;
const sphere = vectors.sphere;
const intersect = vectors.intersect;

pub fn main() void {
    const v = vec3.init(1, 2, 3);
    const moved = mat4.transformVec3(mat4.translation(10, 0, 0), v);
    _ = moved;

    const r = ray.from(vec3.init(-10, 0, 0), vec3.init(1, 0, 0));
    const s = sphere.from(vec3.init(0, 0, 0), 3);
    const hit = intersect.raySphere(r, s);
    std.debug.print("hit? {any}\n", .{hit != null});
}
```

## Build and Test

```bash
zig fmt --check .
zig build test
zig build
```

## Public API Entry

Library exports are re-exported from `src/root.zig`.

## License

MIT (see `LICENSE`).
