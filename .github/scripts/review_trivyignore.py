#!/usr/bin/env python3
"""
Review .trivyignore entries and check for available patches.

This script:
1. Parses .trivyignore to extract CVE/GHSA IDs with acceptance dates
2. Queries GitHub Advisory Database for patch availability
3. Generates a report of vulnerabilities with available fixes
4. Creates or updates a tracking issue with findings
"""

import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional

import requests


@dataclass
class IgnoredVulnerability:
    """Represents a vulnerability in .trivyignore."""

    vuln_id: str
    acceptance_date: Optional[str]
    reason: str
    line_number: int


@dataclass
class AdvisoryInfo:
    """Information about a vulnerability advisory."""

    vuln_id: str
    severity: str
    summary: str
    published_at: str
    updated_at: str
    withdrawn_at: Optional[str]
    patched_versions: List[str]
    url: str


def parse_trivyignore(file_path: str) -> List[IgnoredVulnerability]:
    """
    Parse .trivyignore file and extract vulnerabilities with metadata.

    Args:
        file_path: Path to .trivyignore file

    Returns:
        List of IgnoredVulnerability objects
    """
    trivyignore_file = Path(file_path)
    if not trivyignore_file.exists():
        print(f"❌ .trivyignore file not found: {file_path}")
        sys.exit(1)

    vulnerabilities = []
    current_reason = ""
    current_date = None

    with trivyignore_file.open("r") as f:
        lines = f.readlines()

    for line_num, line in enumerate(lines, start=1):
        stripped = line.strip()

        # Skip empty lines
        if not stripped:
            continue

        # Parse comments for context
        if stripped.startswith("#"):
            # Look for acceptance date in comments
            date_match = re.search(
                r"Acceptance date:\s*(\d{4}-\d{2}-\d{2})", stripped, re.IGNORECASE
            )
            if date_match:
                current_date = date_match.group(1)

            # Accumulate reason text
            reason_text = stripped.lstrip("#").strip()
            if reason_text:
                if current_reason:
                    current_reason += " " + reason_text
                else:
                    current_reason = reason_text
            continue

        # Parse CVE/GHSA IDs
        cve_match = re.match(r"^(CVE-\d{4}-\d+)$", stripped)
        ghsa_match = re.match(r"^(GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4})$", stripped)

        if cve_match or ghsa_match:
            vuln_id = cve_match.group(1) if cve_match else ghsa_match.group(1)
            vuln = IgnoredVulnerability(
                vuln_id=vuln_id,
                acceptance_date=current_date,
                reason=current_reason if current_reason else "No reason provided",
                line_number=line_num,
            )
            vulnerabilities.append(vuln)

            # Reset context for next vulnerability
            current_reason = ""
            current_date = None

    return vulnerabilities


def get_cve_to_ghsa_mapping(cve_id: str) -> Optional[str]:
    """
    Attempt to find GHSA ID for a CVE using GitHub's search API.

    Args:
        cve_id: CVE identifier (e.g., "CVE-2024-12345")

    Returns:
        GHSA ID if found, None otherwise
    """
    try:
        # Search GitHub advisories for this CVE
        search_url = "https://api.github.com/advisories"
        params = {"cve_id": cve_id, "per_page": 1}

        response = requests.get(search_url, params=params, timeout=10)

        if response.status_code == 200:
            data = response.json()
            if data and len(data) > 0:
                return data[0].get("ghsa_id")

        return None
    except (requests.RequestException, ValueError, KeyError) as e:
        print(f"⚠️  Warning: Could not map {cve_id} to GHSA: {e}")
        return None


def get_advisory_info(vuln_id: str) -> Optional[AdvisoryInfo]:
    """
    Get vulnerability information from GitHub Advisory Database.

    Args:
        vuln_id: Vulnerability ID (CVE or GHSA format)

    Returns:
        AdvisoryInfo object if found, None otherwise
    """
    ghsa_id = vuln_id

    # If it's a CVE, try to map it to GHSA
    if vuln_id.startswith("CVE-"):
        mapped_ghsa = get_cve_to_ghsa_mapping(vuln_id)
        if mapped_ghsa:
            ghsa_id = mapped_ghsa
            print(f"  Mapped {vuln_id} → {ghsa_id}")
        else:
            print(f"  ⚠️  Could not map {vuln_id} to GHSA, using CVE lookup")
            # For CVEs without GHSA mapping, we can't get detailed info from GitHub API
            # Return basic info
            return AdvisoryInfo(
                vuln_id=vuln_id,
                severity="UNKNOWN",
                summary=f"CVE {vuln_id} (no GitHub Advisory found)",
                published_at="Unknown",
                updated_at="Unknown",
                withdrawn_at=None,
                patched_versions=[],
                url=f"https://nvd.nist.gov/vuln/detail/{vuln_id}",
            )

    # Query GitHub Advisory Database
    api_url = f"https://api.github.com/advisories/{ghsa_id}"

    try:
        response = requests.get(api_url, timeout=10)

        if response.status_code == 404:
            print(f"  ℹ️  Advisory {ghsa_id} not found in GitHub database")
            return None

        response.raise_for_status()
        data = response.json()

        # Extract patched versions from vulnerabilities array
        patched_versions = []
        for vuln in data.get("vulnerabilities", []):
            patched = vuln.get("patched_versions", "")
            if patched and patched not in patched_versions:
                patched_versions.append(patched)

        return AdvisoryInfo(
            vuln_id=vuln_id,
            severity=data.get("severity", "UNKNOWN"),
            summary=data.get("summary", "No summary available"),
            published_at=data.get("published_at", "Unknown"),
            updated_at=data.get("updated_at", "Unknown"),
            withdrawn_at=data.get("withdrawn_at"),
            patched_versions=patched_versions,
            url=data.get("html_url", f"https://github.com/advisories/{ghsa_id}"),
        )

    except (requests.RequestException, ValueError, KeyError) as e:
        print(f"  ❌ Error fetching advisory for {ghsa_id}: {e}")
        return None


def check_for_patches(vuln: IgnoredVulnerability) -> Dict:
    """
    Check if patches are available for an ignored vulnerability.

    Args:
        vuln: IgnoredVulnerability object

    Returns:
        Dictionary with vulnerability info and patch status
    """
    print(f"\n🔍 Checking {vuln.vuln_id}...")

    advisory = get_advisory_info(vuln.vuln_id)

    result = {
        "vuln_id": vuln.vuln_id,
        "acceptance_date": vuln.acceptance_date or "Unknown",
        "reason": vuln.reason,
        "has_advisory": advisory is not None,
        "patch_available": False,
        "advisory_info": None,
    }

    if advisory:
        result["advisory_info"] = advisory

        # Check if vulnerability is withdrawn (fixed)
        if advisory.withdrawn_at:
            result["patch_available"] = True
            result["status"] = "withdrawn"
            print(f"  ✅ Advisory withdrawn on {advisory.withdrawn_at}")

        # Check if patched versions exist
        elif advisory.patched_versions:
            result["patch_available"] = True
            result["status"] = "patched"
            print(f"  ✅ Patches available: {', '.join(advisory.patched_versions)}")

        else:
            result["status"] = "no_patch"
            print(f"  ⏳ No patches available yet")

    return result


def generate_issue_body(results: List[Dict]) -> str:
    """
    Generate markdown body for the tracking issue.

    Args:
        results: List of vulnerability check results

    Returns:
        Markdown formatted issue body
    """
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    body = f"""# 🔄 .trivyignore Review Report

**Last Updated**: {timestamp}

This automated report reviews vulnerabilities in `.trivyignore` to check if patches have become available.

---

## 📊 Summary

"""

    patched_count = sum(1 for r in results if r.get("patch_available"))
    no_patch_count = sum(1 for r in results if not r.get("patch_available"))
    total_count = len(results)

    body += f"- **Total Ignored Vulnerabilities**: {total_count}\n"
    body += f"- **🎉 Patches Available**: {patched_count}\n"
    body += f"- **⏳ Still Waiting for Patches**: {no_patch_count}\n"

    # Section: Vulnerabilities with Available Patches
    patched = [r for r in results if r.get("patch_available")]
    if patched:
        body += "\n---\n\n## 🎉 Patches Available\n\n"
        body += (
            "These vulnerabilities now have patches available. "
            "Consider updating dependencies or re-evaluating the risk.\n\n"
        )

        body += "| Vulnerability | Acceptance Date | Status | Patched Versions | Details |\n"
        body += "|---------------|-----------------|--------|------------------|----------|\n"

        for r in patched:
            vuln_id = r["vuln_id"]
            acceptance = r["acceptance_date"]
            advisory = r.get("advisory_info")

            if advisory:
                status = "Withdrawn" if r.get("status") == "withdrawn" else "Patched"
                patches = (
                    ", ".join(advisory.patched_versions[:3])
                    if advisory.patched_versions
                    else "See advisory"
                )
                if len(advisory.patched_versions) > 3:
                    patches += "..."
                url = advisory.url
                body += (
                    f"| [{vuln_id}]({url}) | {acceptance} | {status} | "
                    f"{patches} | {advisory.severity} |\n"
                )
            else:
                body += f"| {vuln_id} | {acceptance} | Unknown | - | - |\n"

    # Section: Still Waiting for Patches
    no_patch = [r for r in results if not r.get("patch_available")]
    if no_patch:
        body += "\n---\n\n## ⏳ Still Waiting for Patches\n\n"
        body += (
            "These vulnerabilities do not yet have patches available. "
            "Continue monitoring.\n\n"
        )

        body += "| Vulnerability | Acceptance Date | Reason | Last Updated |\n"
        body += "|---------------|-----------------|--------|---------------|\n"

        for r in no_patch:
            vuln_id = r["vuln_id"]
            acceptance = r["acceptance_date"]
            reason = r["reason"][:80] + "..." if len(r["reason"]) > 80 else r["reason"]
            advisory = r.get("advisory_info")

            if advisory:
                url = advisory.url
                updated = advisory.updated_at[:10] if advisory.updated_at and len(advisory.updated_at) >= 10 else advisory.updated_at or "Unknown"
                body += f"| [{vuln_id}]({url}) | {acceptance} | {reason} | {updated} |\n"
            else:
                body += f"| {vuln_id} | {acceptance} | {reason} | Unknown |\n"

    # Section: Detailed Information
    body += "\n---\n\n## 📋 Detailed Information\n\n"
    body += (
        "<details><summary>Click to expand detailed vulnerability information</summary>\n\n"
    )

    for r in results:
        vuln_id = r["vuln_id"]
        advisory = r.get("advisory_info")

        body += f"### {vuln_id}\n\n"
        body += f"- **Acceptance Date**: {r['acceptance_date']}\n"
        body += f"- **Reason for Ignoring**: {r['reason']}\n"

        if advisory:
            body += f"- **Severity**: {advisory.severity}\n"
            body += f"- **Summary**: {advisory.summary}\n"
            published = advisory.published_at[:10] if advisory.published_at and len(advisory.published_at) >= 10 else advisory.published_at or 'Unknown'
            updated = advisory.updated_at[:10] if advisory.updated_at and len(advisory.updated_at) >= 10 else advisory.updated_at or 'Unknown'
            body += f"- **Published**: {published}\n"
            body += f"- **Last Updated**: {updated}\n"

            if advisory.withdrawn_at:
                body += f"- **Withdrawn**: {advisory.withdrawn_at} ✅\n"

            if advisory.patched_versions:
                body += f"- **Patched Versions**: {', '.join(advisory.patched_versions)}\n"

            body += f"- **Reference**: {advisory.url}\n"
        else:
            body += "- **Status**: No GitHub Advisory found\n"

        body += "\n"

    body += "</details>\n\n"

    # Footer
    body += "---\n\n"
    body += "**Note**: This issue is automatically updated by the "
    body += "`review-trivyignore` workflow. Review the findings and take "
    body += "appropriate action (update dependencies, remove from .trivyignore, etc.).\n"

    return body


def find_or_create_tracking_issue(repo: str, token: str, body: str) -> bool:
    """
    Find existing tracking issue or create a new one.

    Args:
        repo: Repository in format 'owner/repo'
        token: GitHub token
        body: Issue body content

    Returns:
        True if issue was created/updated successfully
    """
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
    }

    issue_title = "🔄 .trivyignore Review Report"

    # Search for existing tracking issue
    search_query = f'repo:{repo} is:issue is:open "{issue_title}" in:title'
    search_url = "https://api.github.com/search/issues"

    try:
        response = requests.get(
            search_url,
            headers=headers,
            params={"q": search_query},
            timeout=10,
        )
        response.raise_for_status()
        data = response.json()

        existing_issues = data.get("items", [])

        if existing_issues:
            # Update existing issue
            issue_number = existing_issues[0]["number"]
            print(f"📝 Updating existing issue #{issue_number}...")

            update_url = f"https://api.github.com/repos/{repo}/issues/{issue_number}"
            update_data = {"body": body}

            response = requests.patch(
                update_url, headers=headers, json=update_data, timeout=10
            )
            response.raise_for_status()
            print(f"✅ Updated issue #{issue_number}")
            return True

        else:
            # Create new issue
            print("📝 Creating new tracking issue...")

            create_url = f"https://api.github.com/repos/{repo}/issues"
            issue_data = {
                "title": issue_title,
                "body": body,
                "labels": ["security", "trivyignore-review", "automated"],
            }

            response = requests.post(
                create_url, headers=headers, json=issue_data, timeout=10
            )
            response.raise_for_status()
            issue_number = response.json()["number"]
            print(f"✅ Created issue #{issue_number}")
            return True

    except (requests.RequestException, ValueError, KeyError) as e:
        print(f"❌ Failed to create/update tracking issue: {e}")
        if hasattr(e, "response") and hasattr(e.response, "text"):
            print(f"Response: {e.response.text}")
        return False


def main():
    """Main entry point."""
    print("🔄 .trivyignore Review Tool")
    print("=" * 50)

    # Get environment variables
    github_token = os.getenv("GITHUB_TOKEN")
    github_repository = os.getenv("GITHUB_REPOSITORY")
    trivyignore_path = os.getenv("TRIVYIGNORE_PATH", ".trivyignore")

    if not github_token:
        print("❌ GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not github_repository:
        print("❌ GITHUB_REPOSITORY environment variable not set")
        sys.exit(1)

    print(f"📁 Repository: {github_repository}")
    print(f"📄 Parsing: {trivyignore_path}")

    # Parse .trivyignore
    vulnerabilities = parse_trivyignore(trivyignore_path)

    if not vulnerabilities:
        print("\n✅ No vulnerabilities found in .trivyignore")
        print("Nothing to review!")
        sys.exit(0)

    print(f"\n📋 Found {len(vulnerabilities)} ignored vulnerabilities")

    # Check each vulnerability for patches
    results = []
    for vuln in vulnerabilities:
        result = check_for_patches(vuln)
        results.append(result)

    # Generate report
    print("\n📊 Generating report...")
    issue_body = generate_issue_body(results)

    # Create or update tracking issue
    print("\n📝 Creating/updating tracking issue...")
    success = find_or_create_tracking_issue(github_repository, github_token, issue_body)

    if success:
        patched_count = sum(1 for r in results if r.get("patch_available"))
        print(f"\n✅ Review complete!")
        print(f"   - Total vulnerabilities: {len(results)}")
        print(f"   - Patches available: {patched_count}")
        sys.exit(0)
    else:
        print("\n❌ Failed to complete review")
        sys.exit(1)


if __name__ == "__main__":
    main()
