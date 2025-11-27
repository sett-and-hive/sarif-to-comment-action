#!/usr/bin/env python3
"""
Create GitHub issues for Trivy vulnerability findings.

This script:
1. Parses Trivy scan reports (text format)
2. Extracts unique CVE IDs with their details
3. Checks for existing open issues to avoid duplicates
4. Creates new issues for vulnerabilities not already tracked
"""

import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Set

import requests


@dataclass
class Vulnerability:
    """Represents a vulnerability found by Trivy."""

    cve_id: str
    severity: str
    package_name: str
    installed_version: str
    fixed_version: str
    title: str
    component: str  # 'ollama' or 'app'


def parse_trivy_report(report_path: str, component: str) -> List[Vulnerability]:
    """
    Parse a Trivy report file and extract vulnerabilities.

    Args:
        report_path: Path to the Trivy report text file
        component: Component name ('ollama' or 'app')

    Returns:
        List of Vulnerability objects
    """
    report_file = Path(report_path)
    if not report_file.exists():
        print(f"Report file not found: {report_path}")
        return []

    with report_file.open("r") as f:
        content = f.read()

    # Check if there are any vulnerabilities
    if "Total: 0" in content or not content.strip():
        print(f"No vulnerabilities found in {report_path}")
        return []

    vulnerabilities = []

    # Parse the table format from Trivy output
    # The format is a table with columns separated by │ characters:
    # │ Library│ Vulnerability  │ Severity │ Installed Version │ Fixed Version │ Title │
    # ├────────┼────────────────┼──────────┼───────────────────┼───────────────┼───────┤
    # │ stdlib │ CVE-2025-12345 │ HIGH     │ 1.24.0            │ 1.24.8        │ Title │

    lines = content.split("\n")

    for line in lines:
        # Look for CVE or GHSA IDs in table rows (lines with │)
        if ("CVE-" in line or "GHSA-" in line) and "│" in line:
            # Split by the table separator and strip whitespace
            cols = [c.strip() for c in line.split("│")]

            # Don't filter empty columns - we need to preserve position
            # Expected format after split (includes leading/trailing empty):
            # ['', Library, CVE/GHSA, Severity, Installed, Fixed, Title, '']

            if len(cols) >= 7:
                # Skip the leading and trailing empty strings from split
                package_name = cols[1] if len(cols) > 1 and cols[1] else "unknown"
                vuln_id_raw = cols[2] if len(cols) > 2 else "unknown"
                severity = cols[3] if len(cols) > 3 and cols[3] else "UNKNOWN"
                installed_version = cols[4] if len(cols) > 4 and cols[4] else "unknown"
                fixed_version = cols[5] if len(cols) > 5 and cols[5] else ""
                title = (
                    cols[6]
                    if len(cols) > 6 and cols[6]
                    else f"Vulnerability in {package_name}"
                )

                # Extract CVE or GHSA ID if there's extra text
                cve_match = re.search(r"(CVE-\d{4}-\d+)", vuln_id_raw)
                ghsa_match = re.search(
                    r"(GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4})", vuln_id_raw
                )

                if cve_match:
                    cve_id = cve_match.group(1)
                elif ghsa_match:
                    cve_id = ghsa_match.group(1)
                else:
                    continue  # Skip if we can't find a valid CVE or GHSA ID

                vuln = Vulnerability(
                    cve_id=cve_id,
                    severity=severity,
                    package_name=package_name,
                    installed_version=installed_version,
                    fixed_version=fixed_version if fixed_version else "Not available",
                    title=title,
                    component=component,
                )
                vulnerabilities.append(vuln)

    # Deduplicate by CVE ID (keep first occurrence)
    seen = set()
    unique_vulns = []
    for v in vulnerabilities:
        if v.cve_id not in seen:
            seen.add(v.cve_id)
            unique_vulns.append(v)

    return unique_vulns


def get_existing_issue_numbers(repo: str, token: str, cve_id: str) -> Set[int]:
    """
    Check if an issue already exists for this CVE.

    Args:
        repo: Repository in format 'owner/repo'
        token: GitHub token
        cve_id: CVE ID to search for

    Returns:
        Set of issue numbers that mention this CVE
    """
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
    }

    # Search for open issues containing the CVE ID
    search_query = f"repo:{repo} is:issue is:open {cve_id} in:title,body"
    search_url = "https://api.github.com/search/issues"

    try:
        response = requests.get(
            search_url,
            headers=headers,
            params={"q": search_query, "per_page": 100},
            timeout=10,
        )
        response.raise_for_status()
        data = response.json()

        return {item["number"] for item in data.get("items", [])}
    except (requests.RequestException, ValueError) as e:
        print(f"Error searching for existing issues: {e}")
        return set()


def create_github_issue(repo: str, token: str, vuln: Vulnerability) -> bool:
    """
    Create a GitHub issue for a vulnerability.

    Args:
        repo: Repository in format 'owner/repo'
        token: GitHub token
        vuln: Vulnerability object

    Returns:
        True if issue was created successfully
    """
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
    }

    # Create issue title
    title = f"[Trivy] {vuln.cve_id}: {vuln.component} - {vuln.package_name}"

    # Determine the reference URL based on vulnerability ID format
    if vuln.cve_id.startswith("CVE-"):
        ref_url = f"https://nvd.nist.gov/vuln/detail/{vuln.cve_id}"
        vuln_type = "CVE"
    elif vuln.cve_id.startswith("GHSA-"):
        ref_url = f"https://github.com/advisories/{vuln.cve_id}"
        vuln_type = "GHSA"
    else:
        ref_url = "N/A"
        vuln_type = "Vulnerability"

    # Create issue body
    body = f"""## Security Vulnerability: {vuln.cve_id}

**Component**: {vuln.component}
**Package**: {vuln.package_name}
**Installed Version**: {vuln.installed_version}
**Fixed Version**: {vuln.fixed_version}
**Severity**: {vuln.severity}

### Description

{vuln.title if vuln.title else f"Vulnerability found in {vuln.package_name}"}

### {vuln_type} Information

- **{vuln_type} ID**: {vuln.cve_id}
- **Severity**: {vuln.severity}
- **Reference**: {ref_url}

### Resolution Steps

1. **Assess Impact**: Review the vulnerability details and determine if it affects our use case
2. **Apply Fix**: If a fixed version is available ({vuln.fixed_version}), update the dependency
3. **Update .trivyignore**: If the vulnerability cannot be fixed immediately, add it to `.trivyignore` with justification
4. **Update Threat Model**: Document this vulnerability in `docs/threat_model.md` under the "Risk Mitigation" section
5. **Update uv.lock**: Update `uv.lock` with the latest version of all packages, as needed

### Acceptance Criteria

- [ ] Threat model document (`docs/threat_model.md`) has been updated with this vulnerability
- [ ] Either:
  - [ ] Package has been updated to fixed version ({vuln.fixed_version}) and vulnerability no longer appears in Trivy scans, OR
  - [ ] Vulnerability has been added to `.trivyignore` with appropriate justification and acceptance date
- [ ] Trivy scans pass (or only show accepted/ignored vulnerabilities)
- [ ] `uv.lock` is updated with the latest version of all packages, as needed

### Additional Context

This issue was automatically created by the Trivy security scanning workflow.
The vulnerability was detected in the {vuln.component} container image during automated security scanning.

**Generated by**: GitHub Actions Trivy Scan
**Detection Date**: {os.getenv("GITHUB_RUN_ID", "N/A")}
"""

    # Create the issue
    issue_data = {
        "title": title,
        "body": body,
        "labels": ["security", "trivy", "needs refinement"],
    }

    try:
        response = requests.post(
            f"https://api.github.com/repos/{repo}/issues",
            headers=headers,
            json=issue_data,
            timeout=10,
        )
        response.raise_for_status()
        issue_number = response.json()["number"]
        print(f"✅ Created issue #{issue_number} for {vuln.cve_id}")
        return True
    except (requests.RequestException, ValueError, KeyError) as e:
        print(f"❌ Failed to create issue for {vuln.cve_id}: {e}")
        if hasattr(e, "response") and hasattr(e.response, "text"):
            print(f"Response: {e.response.text}")
        return False


def main():
    """Main entry point."""
    # Get environment variables
    github_token = os.getenv("GITHUB_TOKEN")
    github_repository = os.getenv("GITHUB_REPOSITORY")

    if not github_token:
        print("❌ GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not github_repository:
        print("❌ GITHUB_REPOSITORY environment variable not set")
        sys.exit(1)

    print(f"🔍 Checking for vulnerabilities in repository: {github_repository}")

    # Parse app image report
    app_vulns = parse_trivy_report("trivy-app-image.txt", "app")

    all_vulns = app_vulns

    if not all_vulns:
        print("✅ No vulnerabilities found in any reports")
        sys.exit(0)

    print(f"📋 Found {len(all_vulns)} unique vulnerabilities across all scans")

    # Process each vulnerability
    created_count = 0
    skipped_count = 0

    for vuln in all_vulns:
        print(
            f"\n🔎 Processing {vuln.cve_id} ({vuln.component}/{vuln.package_name})..."
        )

        # Check if issue already exists
        existing_issues = get_existing_issue_numbers(
            github_repository, github_token, vuln.cve_id
        )

        if existing_issues:
            print(
                f"⏭️  Skipping {vuln.cve_id} - already tracked in issue(s): {existing_issues}"
            )
            skipped_count += 1
            continue

        # Create new issue
        if create_github_issue(github_repository, github_token, vuln):
            created_count += 1

    print("\n📊 Summary:")
    print(f"  - Vulnerabilities found: {len(all_vulns)}")
    print(f"  - Issues created: {created_count}")
    print(f"  - Issues skipped (already exist): {skipped_count}")


if __name__ == "__main__":
    main()
