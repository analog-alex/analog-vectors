# Testing

## Purpose

Document the commands and expectations for validating `analog-vectors` changes, especially when examples or documentation reference concrete API behavior.

## Audience

Contributors, reviewers, and maintainers verifying code or docs against the current repository state.

## Related Links

- [Home](./Home.md)
- [Contribution guide](../../CONTRIBUTING.md)
- [README](../../README.md)
- [API entry point](../../src/root.zig)

## Core Checks

Run these commands from the repository root:

```bash
zig fmt --check .
zig build test
zig build
```

## Focused Test Runs

When a change affects one area, use direct `zig test` invocations with `--test-filter`, for example:

```bash
zig test src/vectors/vec2.zig --test-filter "sum - can sum"
```

## Documentation Accuracy

- Keep snippets aligned with the current API exactly.
- Re-check versioned install examples when a release changes.
- Link long-form explanations back to the canonical source file when precision matters.
