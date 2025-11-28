# Bash Testing Guide (Bats)

This document explains how we test Bash scripts in this repository using
[Bats – Bash Automated Testing System](https://github.com/bats-core/bats-core).

Our goals:

- Fast, reliable feedback on changes to Bash scripts.
- A consistent, simple pattern that interns and new engineers can follow.
- Scripts designed to be testable (clear separation of logic, minimal side effects).

---

## 1. Overview

We use:

- **Bats** as the test runner for Bash scripts.
- A simple, consistent **directory layout** for scripts and tests.
- A top-level **`./test.sh`** script to run all Bash tests.
- Optional helper libraries:
  - [`bats-support`](https://github.com/bats-core/bats-support)
  - [`bats-assert`](https://github.com/bats-core/bats-assert)

CI uses the official `bats-core/bats-action` GitHub Action to install and run Bats.

---

## 2. Directory layout

Our Bash-related structure looks like this:

```text
project/
  test/
    test_helper.bash      # Shared setup + helpers for all tests

    unit/                 # Tests for individual scripts / functions
      my_script.bats
      other_script.bats

    integration/          # End-to-end / multi-script workflows
      workflow_end_to_end.bats

  run_tests.sh                 # Test runner for all Bash tests
```
