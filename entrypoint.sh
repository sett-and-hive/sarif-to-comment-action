#!/bin/bash

set -o pipefail
set -exu
set -C

echo "Convert SARIF file $1"
npx @security-alert/sarif-to-comment --dryRun --token "$2" --commentUrl "$3" --sarifContentOwner "$4" --sarifContentRepo "$5" --sarifContentBranch "$6" --title "ODC SARIF vulnerabilities report" --ruleDetails true --suppressedResult true "$1"
echo "::set-output name=output::$?"
