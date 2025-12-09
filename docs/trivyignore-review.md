# .trivyignore Review Workflow

## Overview

The `.trivyignore` review workflow is an automated system that periodically reviews vulnerabilities listed in `.trivyignore` and checks if patches have become available since the vulnerabilities were initially accepted as risks.

## Problem Statement

Currently, we add CVEs to `.trivyignore` when:

- Waiting for upstream dependencies to release fixes
- Mitigating false positives
- Accepting vulnerabilities in intermediate build layers

Without periodic review, we may continue ignoring vulnerabilities long after fixes become available, leaving the project unnecessarily exposed.

## Solution

The workflow consists of:

1. **Python Script** (`.github/scripts/review_trivyignore.py`): Parses `.trivyignore`, queries GitHub Advisory Database, and generates reports
2. **GitHub Actions Workflow** (`.github/workflows/review-trivyignore.yaml`): Runs monthly and creates/updates tracking issues

## Features

- **Automated Monthly Reviews**: Runs on the 1st of each month at 9:00 UTC
- **Manual Trigger Support**: Can be triggered manually via workflow_dispatch
- **Patch Detection**: Queries GitHub Advisory Database for available fixes
- **Issue Tracking**: Creates a single tracking issue that is updated with each review
- **Comprehensive Reporting**: Shows vulnerabilities with available patches and those still waiting
- **CVE to GHSA Mapping**: Automatically maps CVE IDs to GitHub Security Advisories when possible
- **Zero False Positives**: Only reports when patches are actually available

## Workflow Schedule

The workflow runs monthly by default:

```yaml
on:
  schedule:
    # Run monthly on the 1st at 9:00 UTC
    - cron: '0 9 1 * *'
  workflow_dispatch:
```

To change the schedule, modify the cron expression in `.github/workflows/review-trivyignore.yaml`.

## Manual Trigger

You can manually trigger the workflow from the GitHub Actions UI:

1. Go to the "Actions" tab in the repository
2. Select "Review .trivyignore" workflow
3. Click "Run workflow"
4. Optionally specify a custom path to the .trivyignore file (default: `.trivyignore`)

## How It Works

### 1. Parsing .trivyignore

The script parses `.trivyignore` to extract:

- CVE or GHSA IDs
- Acceptance dates (from comments like `# Acceptance date: YYYY-MM-DD`)
- Reason for ignoring (from preceding comments)

Example `.trivyignore` format:

```text
# Mitigated: npm-user-validate ReDoS vulnerability (< 1.0.1)
# The CVE was fixed in npm-user-validate 1.0.1.
# Acceptance date: 2025-12-05
CVE-2020-7754

# False Positive: Trivy misidentifies gh cli
CVE-2024-52308
```

### 2. Querying GitHub Advisory Database

For each vulnerability:

- CVE IDs are mapped to GitHub Security Advisories (GHSA)
- Advisory details are fetched from `https://api.github.com/advisories/{ghsa_id}`
- Patch availability is determined from:
  - Advisory withdrawal status
  - Patched version information

### 3. Generating Reports

The script generates a comprehensive markdown report containing:

- Summary of total vulnerabilities, patched, and still waiting
- Table of vulnerabilities with available patches
- Table of vulnerabilities still waiting for patches
- Detailed information for each vulnerability

### 4. Creating/Updating Tracking Issue

The workflow creates or updates a tracking issue titled "🔄 .trivyignore Review Report" with:

- Current status of all ignored vulnerabilities
- Links to advisories
- Patched versions when available
- Last update timestamps

## Report Format

The tracking issue contains:

### Summary Section

Shows counts of:

- Total ignored vulnerabilities
- Vulnerabilities with available patches
- Vulnerabilities still waiting for patches

### Patches Available Section

Table format with:

- Vulnerability ID (linked to advisory)
- Acceptance date
- Status (Withdrawn/Patched)
- Patched versions
- Severity level

### Still Waiting Section

Table format with:

- Vulnerability ID (linked to advisory)
- Acceptance date
- Reason for ignoring
- Last updated date

### Detailed Information

Expandable section with comprehensive details for each vulnerability:

- Severity
- Summary
- Published date
- Last updated date
- Patched versions
- Reference links

## Configuration

### Environment Variables

The script requires:

- `GITHUB_TOKEN`: GitHub token for API access (automatically provided by Actions)
- `GITHUB_REPOSITORY`: Repository in `owner/repo` format (automatically provided)
- `TRIVYIGNORE_PATH`: Path to .trivyignore file (optional, defaults to `.trivyignore`)

### Customization

To customize the workflow:

1. **Change Schedule**: Edit the cron expression in the workflow file
2. **Custom .trivyignore Path**: Use workflow_dispatch with custom path
3. **Different Labels**: Modify the `labels` array in `find_or_create_tracking_issue()`

## Permissions

The workflow requires:

```yaml
permissions:
  contents: read
  issues: write
```

## Testing

### Unit Tests

Unit tests are located in `test/unit/test_review_trivyignore.bats`:

```bash
# Run tests
bats --verbose-run test/unit/test_review_trivyignore.bats
```

Tests cover:

- Script existence and executability
- Error handling for missing environment variables
- Parsing functionality (integration tests)

### Manual Testing

Test the script locally:

```bash
# Set environment variables
export GITHUB_TOKEN="your-token"
export GITHUB_REPOSITORY="owner/repo"

# Run the script
python .github/scripts/review_trivyignore.py
```

## Troubleshooting

### Common Issues

**Issue**: Script fails with "GITHUB_TOKEN environment variable not set"

- **Solution**: Ensure the workflow has proper permissions and GITHUB_TOKEN is available

**Issue**: No advisory found for CVE

- **Solution**: Some CVEs don't have GitHub Security Advisories. The script handles this gracefully and provides basic information

**Issue**: API rate limiting

- **Solution**: The script uses unauthenticated requests for advisories. If rate limited, wait for reset or use authenticated requests

### Debugging

Enable verbose output by running the script directly:

```bash
python -u .github/scripts/review_trivyignore.py
```

The script provides detailed logging:

- `🔍 Checking {vuln_id}...` - Processing each vulnerability
- `✅ Patches available` - Found available patches
- `⏳ No patches available yet` - Still waiting for patches
- `❌ Error fetching advisory` - API or parsing errors

## Security Considerations

- The script uses only the GitHub API (no external dependencies)
- API calls are made over HTTPS
- No sensitive data is logged or stored
- Tracking issues are public (contains vulnerability information)

## Future Enhancements

Potential improvements:

- Support for other vulnerability databases (NVD, OSV)
- Slack/email notifications for critical patches
- Automatic PR creation to remove fixed vulnerabilities from .trivyignore
- Historical tracking of patch availability
- Integration with dependency update tools (Dependabot, Renovate)

## Related Workflows

- [trivy.yaml](./.github/workflows/trivy.yaml): Scans for new vulnerabilities
- [create_trivy_issues.py](./.github/scripts/create_trivy_issues.py): Creates issues for new findings

## References

- [GitHub Advisory Database API](https://docs.github.com/en/rest/security-advisories/global-advisories)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [.trivyignore Format](https://aquasecurity.github.io/trivy/latest/docs/configuration/filtering/#by-finding-ids)
