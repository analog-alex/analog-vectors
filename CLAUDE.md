# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zig library package for vector operations. The package is named "vectors" and provides vector types and operations primarily focused on 2D vectors (Vec2).

## Build Commands

**Run all tests:**
```bash
zig build test
```

**Build the module:**
```bash
zig build
```

**Get build help:**
```bash
zig build --help
```

## Project Structure

- **src/root.zig**: Library entry point. This is the root source file that consumers of the module can access. All public declarations intended for external use must be exported from here.
- **src/vectors/**: Contains vector type implementations
  - **vec2.zig**: 2D vector implementation with operations (from, X, Y, sum, etc.)
- **build.zig**: Build configuration defining the "vectors" module
- **build.zig.zon**: Package manifest (minimum Zig version: 0.15.1)

## Architecture

This is a **library module**, not an executable. The build system creates a reusable module named "vectors" that can be imported by other Zig projects.

**Module Export Pattern:**
- Public declarations in `src/vectors/*.zig` are implementation files
- To expose these to consumers, they must be re-exported from `src/root.zig`
- Currently, `root.zig` only contains placeholder functions and needs to export the vector types

**Vector Implementation:**
- Vec2 is implemented as `[2]f32` (array-based)
- Functions are namespaced (e.g., `vec2.from()`, `vec2.X()`, `vec2.sum()`)
- Coordinate accessors (X, Y) are inline functions for performance

## Testing

Tests are colocated with implementation code using Zig's `test` blocks. The build system runs all tests from the module via `zig build test`.
