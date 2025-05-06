#!/bin/bash

# entrypoint.sh API
# $1 - sarif-file
# $2 - token
# $3 - repository
# $4 - branch
# $5 - pr-number
# $6 - title
# $7 - show-rule-details
# $8 - dry-run
# $9 - odc-sarif
# $10 - hide-suppressed

set -o pipefail
set -eu

fix_odc_sarif() {
  ord_sarif="$SARIF_FILE"
  mod_sarif=$(mktemp "/tmp/SARIF_FILE.XXXXXX.mod") || exit 5
  jq '.runs[].tool.driver.rules[] |= . + {"defaultConfiguration": { "level": "error"}}' "$ord_sarif" >"$mod_sarif"
  SARIF_FILE="$mod_sarif"
}

SARIF_FILE=$1
TOKEN=$2
REPOSITORY=$3
BRANCH=$4
PR_NUMBER=$5
TITLE=$6
SHOW_RULE_DETAILS=$7
DRY_RUN=$8
ODC_SARIF=$9
HIDE_SUPPRESSED=${10}

OWNER=$(echo "$REPOSITORY" | awk -F[/] '{print $1}')
REPO=$(echo "$REPOSITORY" | awk -F[/] '{print $2}')
URL="https://github.com/$REPOSITORY/pull/$PR_NUMBER"

test_if_file_exists() {
  if ! test -f "$SARIF_FILE"; then
    echo "ERROR: No SARIF file found at $SARIF_FILE"
    exit 2
  fi
}

test_if_json_is_valid() {
  if ! jq -e . "$SARIF_FILE" >/dev/null; then
    echo "ERROR: Bad JSON in $SARIF_FILE"
    exit 3
  fi
}

test_if_sarif_has_runs() {
  str=$(jq -e '.runs[].tool.driver.rules[]' "$SARIF_FILE")
  if [ ${#str} = 0 ]; then
    echo "ERROR: Bad SARIF format in $SARIF_FILE"
    exit 4
  fi
}

# Test for bad JSON here
test_if_file_exists "$SARIF_FILE"
test_if_json_is_valid "$SARIF_FILE"
test_if_sarif_has_runs "$SARIF_FILE"

if [ "$ODC_SARIF" == "true" ]; then
  fix_odc_sarif
fi

echo "Convert SARIF file $1"
# sarif-to-issue API
# --token
# --title
# --sarifContentOwner
# --sarifContentRepo
# --sarifContentBranch
# --dryRun
# --ruleDetails
# --no-suppressedResults
# sarif-file-path

if [ "$HIDE_SUPPRESSED" == "true" ]; then
  HIDE_SUPPRESSED_STRING="--no-suppressedResults"
else
  HIDE_SUPPRESSED_STRING=""
fi

npx @security-alert/sarif-to-comment --dryRun "$DRY_RUN" --token "$TOKEN" --commentUrl "$URL" --sarifContentOwner "$OWNER" --sarifContentRepo "$REPO" --sarifContentBranch "$BRANCH" --title "$TITLE" --ruleDetails "$SHOW_RULE_DETAILS" "$HIDE_SUPPRESSED_STRING" "$SARIF_FILE"
RC=$?
#echo "output={$RC}" >>"$GITHUB_OUTPUT"
echo "RC = $RC"
exit "$RC"
