# sarif-to-comment-action

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/tomwillis608/sarif-to-comment-action/main.svg)](https://results.pre-commit.ci/latest/github/tomwillis608/sarif-to-comment-action/main)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6080/badge)](https://bestpractices.coreinfrastructure.org/projects/6080)

This GitHub action converts a SARIF file with security vulnerability findings
into a GitHub pull request comment using the `@security-alert/sarif-to-comment` NPM package.

These are the inputs to Docker image.

## Inputs

### `sarif-file`

Path to SARIF file to add to PR comment.
Required.

### `token`

Your GitHub Access Token.
For example, `${{ secrets.GITHUB_TOKEN }}`.
Required.

### `repository`

GitHub repository where this action will run, in owner/repo format.
For example, `${{ github.repository }}`.
Required.

### `branch`

Branch the PR is on.
For example, `${{ github.head_ref }}`.
Required.

### `title`

Title for the issue.
Default: `SARIF vulnerabilities report`.

### `show-rule-details`

Flag to show or hide rule details.
Default: true

### `dry-run`

If true, do not post the results to a PR. If false, do post the results to the PR.
Required.
Default: false

### `odc-sarif`

If true, the SARIF input is formatted in the
[OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
dialect and the input file will be modified so that the action can
correctly parse the SARIF. If false, as for CodeQL SARIF, do nothing extra.
Default: false

## Example usage

Add this action to your own GitHub action yaml file, replacing the value in
`sarif-file` with the path to the file you want to convert
and add to your pull request in this final step, likely the output of a
security scanning tool.  There are additional helper steps to determine
the expected values of `url`, `repo`, and `owner` in the
[comment-test.yaml workflow](./.github/workflow/comment-test.yaml).

```yaml
- name: Post SARIF findings in the pull request
  if: github.event_name == 'pull_request'
  uses: tomwillis608/sarif-to-comment-action@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    repository: ${{ github.repository }}
    branch: ${{ github.head_ref }}
    pr_number: ${{ github.event.number }}
    sarif-file: scan/results/xss.sarif
    title: My security issue
    dry-run: false
```

You will need to give you job write permissions for issues for this action to succeed.

If you want to test locally with [`nektos/act`](https://github.com/nektos/act),
you will need to add choose a VM runner with `docker` so the tests work locally with
`act`.  Make sure you use an [action VM runner](https://github.com/nektos/act#runners)
that contains the Docker client, like `ubuntu-latest=catthehacker`.

```console
act -P ubuntu-latest=catthehacker/ubuntu:act-20.04 -j test pull_request
```

With a section in your `test` job similar to this:

```yaml
- name: Post SARIF findings in the pull request
  if: github.event_name == 'pull_request'
  uses: tomwillis608/sarif-to-comment-action@main
  with:
    token: fake-secret
    # token: ${{ secrets.GITHUB_TOKEN }}
    branch: 'your-branch'
    pr_number: '1'
    repository: ${{ github.repository }}
    sarif-file: "./test/fixtures/codeql.sarif"
    title: My security issue
    dry-run: 'true' # will not post to PR
    odc-sarif: true
```

### Sample action file

```yaml
# A workflow that posts SARIF results to an issue

name: Your security scan workflow

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 3 * * *"
  workflow_dispatch:

permissions:
  issues: write

jobs:
  issue:
    runs-on: ubuntu-latest
    name: Run the scan that generates a SARIF file

    steps:

      - name: Checkout
        uses: actions/checkout@v3

      # Your actual scanning step here
      - name: Your security scanner that generates SARIF output
        uses: your-favorite/security-scanner@main
        with:
            format: SARIF
            report-path: ./report/scan-findings.sarif

      - name: Post SARIF findings in the issue
        uses: tomwillis608/sarif-to-issue-action@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          repository: ${{ github.repository }}
          branch: ${{ github.head_ref }}
          pr-number: ${{ github.event.number }}
          sarif-file: ./report/scan-findings.sarif
          title: "Security scanning results"
          odc-sarif: false
```

## Testing

There is a simple test that builds and runs the Dockerfile and does a dry run of
`@security-alert/sarif-to-comment` with a test fixture file with known vulnerabilities.

```console
test/test.sh
```

All new functionality must be covered by tests.

## CI

There are two files that perform different tests on the repository.
[comment-test.yaml workflow](./.github/workflow/comment-test.yaml) uses the
`tomwillis608/sarif-to-comment-actio` action as one would in their own action workflow.

[cit-test.yaml workflow](./.github/workflow/ci-test.yaml) runs the same test
script used to develop the action in this repository, ``test/test.sh`.

## Contributing

Pull requests and stars are always welcome.  All new functionality must be covered by tests.

For bugs and feature requests, [please create an issue](https://github.com/tomwillis608/sarif-to-comment-action/issues).

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :star:
