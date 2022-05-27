#!/bin/bash
#
# Flip the mode value to control the --dryRun flag

docker build . -t comment
export DRY_RUN="true"
export LIVE_RUN="false"
MODE=$DRY_RUN
OUTPUTS_FILE=test/test-outputs.txt
FIXTURE_FILE=test/fixtures/codeql.sarif
PR_URL=https://github.com/tomwillis608/sarif-to-comment-action/pull/1
OWNER=tomwillis608
REPO=sarif-to-comment-action
BRANCH=fake-test-branch
docker run --rm -v "$(pwd)/test":/app/test comment $FIXTURE_FILE fake-password $PR_URL $OWNER $REPO $BRANCH $MODE 2>&1 | tee $OUTPUTS_FILE
if [ "$MODE" = "$DRY_RUN" ]; then
  TEST_STRING="DryRun results:"
else
  TEST_STRING="HttpError: Bad credentials"
fi
if grep -Fxq "$TEST_STRING" "$OUTPUTS_FILE"; then
  echo
  echo "✅ Test result: passes"

else
  echo
  echo "❌ Test result: fails"
  exit 1
fi
