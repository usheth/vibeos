# AGENTS

This repo is built with the help of agents. Keep these rules so the work stays clean and educational.

## Principles
- Prefer small, reviewable changes.
- Each milestone should be bootable/testable.
- Document *why* decisions are made.
- Keep external dependencies minimal.
- Tests are required for each change unless impossible; accompany changes with a unit or integration test and document exceptions.
- Add comments above every line of code (unless a file explicitly opts out).

## Workflow
- For each milestone, maintain a checklist in `docs/ROADMAP.md`.
- Keep a short learning log in `docs/LEARNING.md`.
- When adding tooling, explain how it works and how to inspect/debug it.
- Add or update tests alongside every change; if not possible, document why.
- Keep `docs/DECISIONS.md` and `docs/LEARNING.md` updated as choices are made and lessons are learned.
- For every status recorded in `STATUS.md`, verify it and attach console output when possible.

## Test Exceptions
Use sparingly and document the reason:
- Boot-only steps before a test harness exists (validate via QEMU boot output).
- Hardware-dependent behavior not reliably emulated.
- Pure documentation or comment changes.
- Early-boot assembly paths where validation is limited to boot success.
- Tooling gaps where a test framework does not yet exist.

## Milestones (initial)
- M0: Toolchain + build skeleton
- M1: Boot into 64-bit kernel and print a message
- M2: Basic memory map + paging
- M3: Interrupts + timer
- M4: Keyboard input + simple shell loop
- M5: Minimal Unix-like syscall interface
