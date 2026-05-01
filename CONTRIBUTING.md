# Contributing

## Development Workflow

1. Branch from `main`.
2. Keep changes focused on a single concern.
3. Run the relevant checks before opening a pull request:

```bash
zig fmt --check .
zig build test
zig build
```

## Documentation Workflow

Documentation changes should ship with the code change that introduced them. If a pull request changes public behavior, public API, installation steps, or recommended usage, update the relevant documentation in the same pull request.

### Update The Right Surface

- Zig docs: update public API doc comments when behavior, assumptions, units, coordinate spaces, or edge cases change.
- `README.md`: update installation steps, package usage, and first-contact examples when they change.
- Wiki pages or longer guides: use them for tutorials, workflows, or explanations that would make the README too large. Link back to the canonical code or README section when relevant.

### Writing Standards

- Write in direct, concrete language.
- Prefer short examples that match the current API exactly.
- Name the exact module, type, or function being described.
- Call out constraints, defaults, edge cases, and version-specific behavior when they matter.
- Avoid aspirational wording for behavior that is not implemented yet.

### Zig Doc Expectations

- Document public APIs that are not immediately obvious from the name and signature.
- Explain important invariants, assumptions, and failure behavior.
- Keep examples minimal and aligned with the current minimum supported Zig version.
- When a formula or behavior is subtle, explain the "why", not just the "what".

### README Snippet Expectations

- Snippets should be copy-pasteable with the imports they need.
- Keep examples small enough to scan quickly.
- Verify names, module paths, and package setup instructions against the current repository state.
- Update version notes when installation or compatibility guidance changes.

### Review And Ownership

- The author of a code change owns the first-pass documentation update for that change.
- Reviewers should treat docs accuracy as part of the definition of done, not a follow-up task.
- If code and docs disagree, fix the docs before merge unless the code itself is wrong.
- Docs-only pull requests should still be reviewed by someone familiar with the affected area.

## Docs PR Checklist

Before opening or merging a pull request that touches documentation, confirm the following:

- The content matches the current code and behavior.
- Links point to the correct files, sections, or external references.
- Code snippets use the current API and were checked for accuracy.
- Version notes were added or updated when behavior depends on Zig or package version.
- New or moved documentation is linked from an existing discoverable place such as `README.md` or this file.
- Documentation changes needed for the pull request were included in the same branch.
- Wiki page changes were updated in `docs/wiki/` so they can be reviewed before being synced to GitHub.
