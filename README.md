# sarif-to-comment-action

This GitHub action converts a SARIF file with seurity vulnerability for @security-alert/sarif-to-comment

To run sarif-to-comment-action

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

## Example usage

```yaml
- name: Post SARIF findings in the pull request
  if: github.event_name == 'pull_request'
  uses: tomwillis608/sarif-to-comment-action
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    url: ${{ steps.define-url.outputs.url }}
    repo: ${{ github.repository }}
    owner: ${{ github.repository_owner }}
    branch: ${{ github.head_ref }}
    sarif-file: 'test/fixtures/xss.sarif'
```

## Notes

### Support for OWASP dependency-check

To make an OWASP dependency-check SARIF file work for the converter,
you need to add an expected `defaultConfiguration` element to each `rules` object.

```console
jq '.runs[].tool.driver.rules[] |= . +
  {"defaultConfiguration": { "level": "error"}}' test/fixtures/odc.sarif >odc-mod.sarif
```
