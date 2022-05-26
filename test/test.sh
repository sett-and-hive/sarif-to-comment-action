#!/bin/bash
#
# Flip the mode value to control the --dryRun flag

docker build . -t comment
export DRY_RUN="true"
export LIVE_RUN="false"
MODE=$LIVE_RUN
docker run --rm -v "$(pwd)/test":/app/test comment test/fixtures/codeql.sarif fake-password https://github.com/tomwillis608/sarif-to-comment-action/pull/1 tomwillis608 sarif-to-comment-action fake-test-branch $MODE 2>&1 | tee test/results.txt
if [ "$MODE" = "$DRY_RUN" ]; then
  TEST_STRING="DryRun results:"
else
  TEST_STRING="HttpError: Bad credentials"
fi
if grep -Fxq "$TEST_STRING" test/results.txt; then
  echo
  echo "Test passes"

else
  echo
  echo "Test fails"
  exit 1
fi
