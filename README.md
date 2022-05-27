# sarif-to-comment-action

This GitHub action converts a SARIF file with security vulnerability findings
into a PR comment with the `@security-alert/sarif-to-comment` NPM package.

To run `sarif-to-comment-action` you must determine these values.

These are the inputs to Docker image.

## Inputs

### `sarif-file`

Path to SARIF file to add to PR comment.
Required.

### `token`

Your GitHub Access Token.
Required.

### `url`

The URL of the PR to comment.
Required.

### `repo`

GitHub repository with the PR.
Required.

### `owner`

Owner of the GitHub repository.
Required.

### `branch`

Branch the PR is on.
Required.

### `dry-run`

If true, do not post the results to a PR. If false, do post the results to the PR.
Required.
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
  uses: tomwillis608/sarif-to-comment-action@main
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    url: ${{ steps.define-url.outputs.url }}
    repo: ${{ github.repository }}
    owner: ${{ github.repository_owner }}
    branch: ${{ github.head_ref }}
    sarif-file: 'scan/results/xss.sarif'
    dry-run: 'false'
```

If you want to test locally with `nektos/act`, you will need to add
values that work locally with `act`.

```yaml
- name: Post SARIF findings in the pull request
  if: github.event_name == 'pull_request'
  uses: tomwillis608/sarif-to-comment-action@main
  with:
    token: fake-secret
    # token: ${{ secrets.GITHUB_TOKEN }}
    url: "https://github.com/owner/repo/pull/1"
    owner: ${{ steps.define-owner-repo.outputs.owner }}
    repo: ${{ steps.define-owner-repo.outputs.repo }}
    branch: 'your-branch'
    sarif-file: "./test/fixtures/codeql.sarif"
    dry-run: 'true' # will not post to PR
```

## Testing

There is a simple test that builds and runs the Dockerfile and does a dry run of
`@security-alert/sarif-to-comment` with a test fixture file with known vulnerabilities.

```console
test/test.sh
```

## Notes

### Support for OWASP dependency-check

To make an OWASP dependency-check SARIF file work for the converter,
you need to add an expected `defaultConfiguration` element to each `rules` object.

```console
jq '.runs[].tool.driver.rules[] |= . +
  {"defaultConfiguration": { "level": "error"}}' test/fixtures/odc.sarif >odc-mod.sarif
```
