#!/bin/bash

set -o pipefail
set -exu
set -C

pwd
ls -latR test

echo "Convert SARIF file $1"
npx @security-alert/sarif-to-comment --dryRun "$7" --token "$2" --commentUrl "$3" --sarifContentOwner "$4" --sarifContentRepo "$5" --sarifContentBranch "$6" --title "ODC SARIF vulnerabilities report" --ruleDetails true --suppressedResult true "$1"
echo "::set-output name=output::$?"
