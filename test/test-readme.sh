#!/bin/bash
#
# Make sure there are not probamatic typos in the README

#set -o pipefail

TEST_STRING="pr_number" # bug issue #95
README_FILE="../README.md"

echo "Scanning $README_FILE for unwanted value '$TEST_STRING'"
if grep -F "$TEST_STRING" "$README_FILE"; then
  echo "❌ Test result: fails"
  exit 1
else
  echo "✅ Test result: passes"
fi
