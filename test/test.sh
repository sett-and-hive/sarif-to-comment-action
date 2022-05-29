#!/bin/bash
#
# Flip the mode value to control the --dryRun flag

docker build . -t comment
export DRY_RUN="true"
export LIVE_RUN="false"
MODE=$DRY_RUN
OUTPUTS_FILE=./test/test-outputs.txt
FIXTURE_FILE=./test/fixtures/codeql.sarif
PR_NUMBER=1
REPOSITORY=tomwillis608/sarif-to-comment-action
BRANCH=fake-test-branch
TOKEN=fake_password
TITLE="Test title for comment"
SHOW_RULE_DETAILS=true

docker run --rm -v "$(pwd)/test":/app/test comment $FIXTURE_FILE $TOKEN $REPOSITORY $BRANCH $PR_NUMBER "$TITLE" $SHOW_RULE_DETAILS $MODE 2>&1 | tee $OUTPUTS_FILE
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
