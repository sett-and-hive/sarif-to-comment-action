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

## Outputs

## `time`

The time we greeted you.

## Example usage

```yaml
- name: Post SARIF findings in the pull request
  if: github.event_name == 'pull_request'
  uses: tomwillis608/sarif-to-comment-action
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    url:   ${{ steps.define-url.outputs.url }}
    repo:  ${{ github.repository }}
    owner: ${{ github.repository_owner }}
```
