# Select a Markdown Linter

Date: 2025-11-28

## Status

Accepted

## Decision

We have selected **rumdl** as our markdown linter.

## Context

Our repository contains several markdown files, including documentation, ADRs, and contributor guides. To ensure
consistency and adherence to best practices, a markdown linter is necessary.

Key considerations for selecting a markdown linter include:

1. **Ease of setup and integration**: The tool should integrate smoothly into our workflows and CI/CD pipelines.
1. **Flexibility**: Customizable rules are important to align with team preferences.
1. **Community support**: The linter should have active maintenance and strong adoption.
1. **Scalability**: The solution should work well with our repository size and markdown usage.

The following options were evaluated:

1. **Markdownlint**
1. **Vale**
1. **Prettier**
1. **remark-lint**
1. **markdown-it-linter**
1. **rumdl**

### Rationale

- **Ease of Use**: `rumdl` offers a straightforward setup process and integrates easily with CI/CD workflows via GitHub Actions.
- **Customizability**: It provides a rich set of 54+ rules, which can be enabled, disabled, or configured to match our repository's needs, compatible with `markdownlint`.
- **Community Support**: rumdl is actively maintained and well-documented.
- **IDE Support**: rumdl integrates seamlessly with popular IDEs like VS Code, making it easier for developers to identify and fix issues locally.
- **Speed**: rudml is faster than other linters.

**rumdl** supersedes **markdownlint**, with the same important linting checks with much more speed. Other options like **Vale** and **remark-lint** were considered but were deemed more complex than necessary for our current use case. **Prettier** is better suited as a formatter rather than a strict linter, and **markdown-it-linter** lacks the robust community support of Markdownlint.

## Impact

### Positive

- Consistent markdown formatting across the repository.
- Reduced manual effort during code reviews as linting catches common issues early.
- Clear and enforceable standards for contributors.
- Ease of integration into our CI/CD pipeline.

### Negative

- Requires initial setup and configuration time.
- Developers need to install the linter virtually and adhere to the new rules.
