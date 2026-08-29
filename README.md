# repo

Public package shelf for preserved installers, packages, runtimes, and other files we deliberately want to keep available even if an upstream source changes or disappears.

## Layout

```text
packages/
└── <package>/
    └── <version>/
        ├── original package file
        ├── SHA256SUMS.txt
        └── README.md
```

Each archived package should keep its original filename whenever practical, include a SHA-256 checksum, and include a short note explaining why that version was preserved.

## Current packages

- `packages/cubic/2026.08.108/` — known-good Cubic build for Ubuntu 24.04 preserved after 2026.08.109 failed during original-image file copying in our workflow.

This repository is a convenience archive, not an official upstream mirror.
