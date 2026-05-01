# Getting Started

## Purpose

Help a first-time user install the package, wire it into `build.zig`, and verify that the first `Vec2` operations match the current API.

## Audience

Zig users who want to evaluate or adopt `analog-vectors` quickly.

## Related Links

- [Home](./Home.md)
- [Repository README](../../README.md)
- [API entry point](../../src/root.zig)
- [Examples/Cookbook](./Examples-Cookbook.md)

## Install The Package

Use the Zig package manager flow from [`README.md`](../../README.md#installation):

```bash
zig fetch --save https://github.com/analog-alex/analog-vectors/archive/refs/tags/v0.1.1.tar.gz
```

Then add the dependency to `build.zig.zon` and import the module from `build.zig`.

## Verify The Integration

Start with the small `Vec2` example from [`README.md`](../../README.md#quick-start) and confirm that:

- `vec2.init` constructs the vector you expect.
- `vec2.sum` returns component-wise addition.
- `vec2.length` reports the expected scalar length.

## Next Steps

- Move to [Vec2 Guide](./Vec2-Guide.md) for common 2D operations.
- Browse [Examples/Cookbook](./Examples-Cookbook.md) for task-focused snippets.
- Use [`src/root.zig`](../../src/root.zig) as the top-level API map.
