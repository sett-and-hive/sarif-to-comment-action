# Architecture Decision Record Template

Date: 2025-11-28

## Status

Accepted

## Decision

We will adopt [**Bats (Bash Automated Testing System)**](https://github.com/bats-core/bats-core) as the standard
framework for testing Bash scripts in this repository, with the following conventions and tooling:

### 1. Testing Framework

- Use **Bats** as the primary test framework for all Bash scripts.
- Use Bats’ `run` command and assertions to check:
  - Exit status (`$status`)
  - Combined output (`$output`)
  - Side effects (files, directories, environment)

### 2. Directory Layout

Adopt a consistent layout like:

```text
project/
  test/
    test_helper.sh
    run_tests.sh
    unit/
      my_script.bats
      other_script.bats
    integration/
      workflow_end_to_end.bats
```

Conventions:

- Every script in the root should have a corresponding test file in `test/unit`.
- Every multi-script workflow should have a corresponding test file in `test/integration`.
- Test files should be named `*.bats`.
- Test helper functions should be defined in `test/test_helper.sh`.
  - Sets `PROJECT_ROOT` to the root of the project.
  - Set `PATH`
  - Tests for running Docker
  - Tests for presence of `bats`
  - All bats tests source `test_helper.sh`.
- Test files should be executable: `chmod +x`
- Tests use `$BATS_TEST_TMPDIR` and mocks instead of real global state or production endpoints.

### 3. Local Execution

- Use locally-installed `bats` to run tests locally.
- Start tests from a top-level runner.

### 4. CI Integration

- Use the official GitHub Action for Bats.

## Context

We rely on Bash scripts for our GitHub action. Historically, these scripts have been tested using a mix of:

- Ad-hoc shell scripts that `grep` output and check exit codes
- Manual verification
- Inconsistent or non-existent test coverage across scripts

The current situation has several problems:

- **Fragility**: Tests are brittle and often environment-dependent (paths, temp directories, network, etc.).
- **Inconsistency**: Different test styles for different scripts; no standard layout or conventions.
- **Onboarding overhead**: Interns and new engineers struggle to understand how to add or update tests.
- **Lack of CI confidence**: Failures are hard to interpret, and green builds do not strongly indicate bash script correctness.

We want:

- A **standard, readable test framework** for Bash.
- A **repeatable layout and conventions** (especially important for interns).
- Easy **local execution** and **CI integration**.
- Support for **unit-style testing of functions** and **integration-style testing of full scripts**.

### Alternatives

#### Ad-hoc Bash test scripts (status quo)

Pros: No new tools, very simple to start.

Cons: Inconsistent, fragile, duplicated logic, poor readability and failure messages. Not suitable for intern onboarding or long-term maintainability.

#### Testing Bash scripts with another language (e.g., Python + pytest)

Pros: Powerful assertion libraries, rich ecosystem, easier complex mocking.

Cons: Extra language dependency for simple shell tooling; increases cognitive overhead and setup cost for interns; mismatch between test language and implementation language.

#### Other shell test frameworks (e.g., shunit2, shellspec)

Pros: Capable and mature alternatives.

Cons: Bats has simpler syntax for test descriptions and is widely used; we prefer its “test is just a function” model and the ecosystem (bats-support, bats-assert) for readability.

#### No dedicated framework (rely only on integration tests in CI)

Pros: Less tooling.

Cons: Same fragility as status quo, no improvement in design-for-testability, and limited confidence in script changes.

Given these tradeoffs, Bats offers the best balance of simplicity, readability, and alignment with how we already write Bash.

## Impact

The outcomes of the decision, both positive and negative.

### Positive

- Standard, readable, and discoverable approach to Bash testing across the repo.
- Easier onboarding for interns and new team members: one way to write tests, clear examples.
- More robust scripts by nudging design toward testability (functions, clear boundaries, mocks).
- Easy integration into CI via the official GitHub Action.
- Better confidence when changing or refactoring scripts.

### Negative

- Requires developers to install bats locally (documented in README.md).
- Small learning curve for Bats syntax and helper libraries (especially for interns new to bash).
- Requires occasionally updating Bats and its helper libraries and keeping versions aligned between local and CI.

### Risks

#### Framework lock-in

Bats tests are written in Bash using Bats-specific conventions (`@test`, `run`, etc.). If we decide to switch to another framework or language for shell testing, test code will not be directly reusable.

**Mitigations**

- Keep most domain logic in functions that are also exercised by higher-level tests (e.g., Python/Go integration tests, application-level tests), so Bats is not the *only* safety net.
- Keep test helpers (`test_helper.sh`, custom assertions) small and well-factored to reduce migration cost if we ever move away from Bats.

#### Bash-specific behavior vs. POSIX portability

Bats runs tests under `bash`. Scripts that are intended to be POSIX `/bin/sh` compatible might behave differently in other shells, and Bats will not catch those differences.

**Mitigations**

- For scripts that must be POSIX-compliant, keep features to the POSIX subset and use `shellcheck` with appropriate flags (e.g., `shellcheck -s sh`).
- Add targeted integration tests that invoke scripts explicitly via `/bin/sh` where POSIX compatibility is important.
- Clearly document which scripts are “bash-only” vs. “POSIX shell” in their headers.

#### Version drift between local and CI

If developers and CI use different versions of Bats (or `bats-assert` / `bats-support`), subtle behavior differences can cause tests to pass locally and fail in CI, or vice versa.

**Mitigations**

- Pin a minimum Bats version in documentation (e.g., “Bats ≥ 1.x”) and in the GitHub Action configuration.
- Optionally use a shared tool version manager (e.g., `.tool-versions` for `asdf`, devcontainer, or similar) to standardize local environments.
- Document installation instructions in `TESTING.md` that match what CI uses.

#### Slow or flaky tests

There is a risk that engineers write Bats tests that call real external services, use `sleep`, depend on network or timing, or share global state (e.g., `/tmp`), leading to slow or flaky tests.

**Mitigations**

- Establish guidelines that Bats tests:
  - Use `$BATS_TEST_TMPDIR` instead of global filesystem locations.
  - Use PATH-based mocks or environment variables instead of real network calls.
  - Avoid arbitrary `sleep` where possible.
- During code review, treat flakiness patterns (timing, network, global state) as a smell to refactor.

#### Over-reliance on integration-style tests

It is easy to only write “call the script and assert output” tests and ignore more focused, function-level tests. This can make debugging failures harder and encourage large, monolithic scripts.

**Mitigations**

- Encourage a pattern where:
  - Core logic lives in functions (`parse_args`, `do_work`, etc.).
  - Unit-ish tests source the script and call functions directly.
  - Integration tests are kept smaller and focused on key workflows.
- Include in “Definition of Done” that complex scripts should have both happy-path and failure-path tests, and that logic-heavy parts are tested at the function level where practical.

#### False sense of coverage

Because Bats makes it easy to assert “exit code is 0” and “output contains string X”, there is a risk that we end up with shallow tests that do not meaningfully cover edge cases or failure modes.

**Mitigations**

- Encourage scenario-based tests: for each script, identify key behaviors and edge cases (invalid input, missing files, environment misconfiguration, etc.) and ensure each is represented in tests.
- Use code review to push for meaningful assertions (e.g., validate file contents, not just file existence; assert specific error messages, not just non-zero status).

#### Cross-platform differences (macOS vs Linux)

Bash scripts (and therefore Bats tests) often rely on utilities like `sed`, `grep`, `mktemp`, etc. These can behave differently across platforms, particularly macOS vs. GNU/Linux. Tests that pass on Linux CI may fail on macOS developer machines or vice versa.

**Mitigations**

- Prefer portable flags and usage patterns for common tools.
- Where platform differences are unavoidable, document them and consider:
  - Normalizing tools in dev environments (e.g., using GNU coreutils on macOS).
  - Marking certain tests as Linux-only if needed (and documenting why).

#### Knowledge concentration and onboarding

If only a few people understand Bats well, the team may be hesitant to modify tests or add new ones, leading to bitrot or accidental breakage.

**Mitigations**

- Provide a short `TESTING.md` with:
  - How to install Bats.
  - How to run `./test.sh`.
  - A “reference” script + Bats test pair as a model.
- Do at least one short walkthrough / pairing session with interns and teammates to build comfort with Bats.
- Keep tests simple and idiomatic; avoid unnecessary “cleverness” in shell logic.

#### External dependency lifecycle

Bats and its helper libraries are external dependencies. If they become unsupported or change in incompatible ways, we may need to spend time upgrading or replacing them.

**Mitigations**

- Pin versions in CI and upgrade on a deliberate schedule, not ad hoc.
- Keep the abstraction layer thin: most test logic should be simple Bash with a few helper functions, so that migrating to another shell test tool would be feasible if ever required.
