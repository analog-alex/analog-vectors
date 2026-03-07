#!/bin/bash

# Check that version in src/version.zig matches build.zig.zon

set -e

# Extract version from build.zig.zon
version_zon=$(grep '\.version =' build.zig.zon | sed 's/.*\.version = "\([^"]*\)".*/\1/')

# Extract version from src/version.zig
version_zig=$(grep 'version =' src/version.zig | sed 's/.*version = "\([^"]*\)".*/\1/')

if [ "$version_zon" = "$version_zig" ]; then
    echo "Versions match: $version_zon"
    exit 0
else
    echo "Versions do not match: zon=$version_zon, zig=$version_zig"
    exit 1
fi