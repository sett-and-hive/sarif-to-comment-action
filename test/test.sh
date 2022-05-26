#!/bin/bash

docker build . -t comment
docker run --rm -v "$(pwd)/test":/app/test comment test/fixtures/codeql.sarif xxx https://github.com/tomwillis608/sarif-to-comment-action/issues/3 qux quux branch | tee test/results.txt
TEST_STRING="DryRun results:"
if grep -Fxq "$TEST_STRING" test/results.txt; then
  echo
  echo "Test passes"

else
  echo
  echo "Test fails"
  exit 1
fi
