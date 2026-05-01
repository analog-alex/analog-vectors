# Examples/Cookbook

## Purpose

Collect short, task-focused examples that are easier to scan than a long narrative guide.

## Audience

Users who know the library exists and want to copy a small pattern into their own code.

## Related Links

- [Home](./Home.md)
- [Getting Started](./Getting-Started.md)
- [Vec2 Guide](./Vec2-Guide.md)
- [API entry point](../../src/root.zig)

## Recipes

### Offset A Position

Use `vec2.sum` when you want component-wise translation.

### Normalize Before Directional Work

Use `vec2.normalize` before angle or alignment calculations when the math assumes unit-length inputs.

### Prefer Code For Exact Behavior

If you are documenting edge cases such as zero-length normalization or intersection misses, link to the exact implementation file instead of paraphrasing subtle behavior from memory.

## Contribution Rule

Keep cookbook entries short, concrete, and aligned with the current API names.
