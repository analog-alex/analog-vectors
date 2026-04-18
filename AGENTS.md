# AGENTS.md

Operational guide for coding agents working in this repository.

## Scope and Rule Sources
- Repository: `analog-vectors` (Zig library package)
- Minimum Zig: `0.16.0` (`build.zig.zon`)
- CI Zig: `0.16.0` (format + test + build)

Cursor/Copilot rules status (currently):
- `.cursor/rules/`: not present
- `.cursorrules`: not present
- `.github/copilot-instructions.md`: not present

If any of these files are added later, treat them as higher-priority guidance and update this document.

## Repository Layout
- `build.zig`: build graph and top-level steps (`test`, `install`)
- `build.zig.zon`: package metadata and minimum Zig version
- `src/root.zig`: public API exports and smoke tests
- `src/vectors/`: `vec2`, `vec3`, `vec4`
- `src/matrices/`: `mat2`, `mat3`, `mat4`
- `src/complex/`: quaternion module
- `src/geometry/`: scalar geometry + intersections
- `src/geometry_simd/`: SIMD geometry + intersections
- `src/utils/`: angle, color, random, constants, math, easing, interpolation

## Build, Lint, and Test Commands
Run all commands from repository root.

### Core commands
```bash
zig build
zig build test
zig build --help
```

### Lint/format commands
No separate linter is configured; formatting is the lint gate.
```bash
zig fmt --check .
zig fmt .
zig fmt --check --ast-check .
```

### Run a single test (preferred)
Use `zig test` directly on the file plus `--test-filter`.
```bash
zig test src/vectors/vec2.zig --test-filter "sum - can sum"
zig test src/matrices/mat4.zig --test-filter "inverse - calculates inverse matrix"
zig test src/geometry/intersect.zig --test-filter "raySphere - hit from outside"
zig test src/root.zig --test-filter "vec2 module is accessible"
```

Notes:
- `zig build test` runs the full suite; there is no per-test build step in `build.zig`.
- `--test-filter` is substring-based and may still run unnamed/generated tests in the same file.
- Keep test names specific and stable to make filtering reliable.

### Useful debug variants
```bash
zig build test --summary all
zig build test --verbose
zig test src/vectors/vec3.zig --test-filter "slerp" --summary all
```

## Coding Style Guidelines
These conventions are inferred from current source files and CI behavior.

### Formatting and organization
- Always keep files `zig fmt` clean.
- Use standard Zig formatting (4-space indentation via formatter).
- Keep implementation and tests in the same `.zig` file.
- Group functions with section headers used in this codebase (for example `Construction & Accessors`, `Essential Arithmetic`, `Utility`).
- Prefer trailing commas in multiline literals/args and let `zig fmt` finalize layout.

### Imports and module boundaries
- Put `const std = @import("std");` first when used.
- Use relative imports for sibling modules (for example `@import("../vectors/vec3.zig")`).
- Use concise aliases: `vec2`, `vec3`, `vec4`, and collision-avoiding forms like `ray_mod`, `sphere_mod`.
- Re-export aliases for readability when appropriate, for example `pub const Vec3 = vec3.Vec3;`.
- Any new public module should be exported from `src/root.zig`.

### Types and numeric conventions
- Use fixed-size containers for core math primitives:
  - `Vec2`: `[2]f32`
  - `Vec3`: `[3]f32`
  - `Vec4`: `@Vector(4, f32)`
  - Matrices: flat fixed arrays in column-major order
- Use `f32` as the default scalar across APIs.
- Use explicit casts in assertions where needed (`@as(f32, ...)`).
- Keep component accessors inline (`X`, `Y`, `Z`, `W`) for hot paths.

### Naming conventions
- Types: `PascalCase` (`Vec3`, `Mat4`, `Quat`, `HitRecord`).
- Functions: `lowerCamelCase` (`fromVec3`, `angleBetween`, `componentMul`).
- Module constants: `snake_case` (`vec3_unit_x`, `vec2_zero`).
- Parameter names commonly used here:
  - `lhs` / `rhs` for binary operations
  - `min_v` / `max_v` for bounds
  - `radians` for angle inputs
- Test names are descriptive and commonly follow `"function - behavior"`.

### Error handling and defensive math
- Favor simple return types for math operations (no heavy error unions).
- Use optionals (`?T`) for natural failure cases, e.g. singular matrix inverse or missed intersections.
- Guard degenerate inputs explicitly:
  - zero-length normalization inputs
  - near-zero determinants/denominators via epsilon checks
- Use small epsilons (`1e-6`, `1e-4`, etc.) to avoid floating-point instability.
- Prefer approximate float checks (`approxEqual`, `expectApproxEqAbs`) over exact equality.

### API design patterns
- Prefer pure, stateless functions.
- Constructor naming patterns used in this repo:
  - `init(...)`: direct component construction
  - `from...(...)`: conversions/alternate construction
  - `identity()`, `zero()`, `one()`, axis-unit constructors for canonical values
- Normalize inputs only where the API contract requires it (for example `ray.from`).
- Add short doc comments for non-obvious formulas or assumptions.

### Testing guidelines
- Keep tests colocated with implementation.
- Include nominal and edge-case coverage:
  - zero vectors
  - parallel/perpendicular vectors
  - singular matrices
  - tangent / inside / outside intersection cases
- For random/stochastic helpers, use bounded loops with repeated checks.
- Use `try std.testing.expect(...)` consistently.
- If a file already uses `given/when/then` comments, preserve that style.

## Agent Workflow Checklist
Before finishing changes:
1. Run `zig fmt .` (or `zig fmt --check .` for verification).
2. Run focused tests with `zig test <file> --test-filter "..."` for touched behavior.
3. Run `zig build test` for full-suite confidence.
4. Run `zig build` to confirm package buildability.
5. Ensure new public APIs are exported via `src/root.zig`.

When adding modules:
- Follow existing directory conventions (`vectors`, `matrices`, `geometry`, `geometry_simd`, `utils`).
- Reuse naming and return-type patterns from neighboring modules.
- Add colocated tests immediately; do not leave new public APIs untested.
