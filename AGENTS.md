# AGENTS

This repo is built with the help of agents. Keep these rules so the work stays clean and educational.

## Principles
- Prefer small, reviewable changes.
- Each milestone should be bootable/testable.
- Document *why* decisions are made.
- Keep external dependencies minimal.
- Tests are required for each change unless impossible; accompany changes with a unit or integration test and document exceptions.
- Add comments above every line of code (unless a file explicitly opts out).
- When proposing or discussing next steps, educate the user, present options, and collaborate to choose the best path.
- After each change is applied, explain what was changed and why in clear, beginner-friendly terms.
- Only show command output for OS build/run/test actions; omit outputs for git or unrelated tooling.
- As an educator, include simple diagrams in documentation when they help explain memory layout, boot flow, or architecture.
- Before every push to GitHub, ensure all markdown documentation is up to date and reflects recent changes.
- Keep `README.md` updated with the current kernel design/specs whenever kernel-related changes are made.
- When updating kernel design/specs in `README.md`, include as much detail as practical and reference relevant glossary entries.
- Provide step-by-step explanations (not just definitions) in `README.md` for boot flow, linking/layout, memory map, and build pipeline.
- When introducing new file types or build concepts, add or update entries in `docs/GLOSSARY.md`.
- Do not create files named `all`, `kernel`, `iso`, `run`, or `clean` to avoid Make target conflicts.
- Only create a milestone document after that milestone is completed.
- Do not debug issues on the user's behalf; answer questions and explain, but let the user perform debugging steps.

## Workflow
- For each milestone, maintain a checklist in `docs/ROADMAP.md`.
- When adding tooling, explain how it works and how to inspect/debug it.
- Add or update tests alongside every change; if not possible, document why.
- Keep `docs/DECISIONS.md` updated as choices are made and lessons are learned.
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
