#!/bin/bash
#
# Flip the mode value to control the --dryRun flag

create_docker_image() {
  TEST_IMAGE=comment-test-image
  docker build . -t "$TEST_IMAGE" -q
}

run_docker() {
  image="$1"
  sarif_file="$2"
  odc_sarif="$3"
  docker run --rm -v "$(pwd)/test":/app/test "$image" "$sarif_file" "$TOKEN" "$REPOSITORY" "$BRANCH" "$PR_NUMBER" "$TITLE" "$SHOW_RULE_DETAILS" "$MODE" "$odc_sarif" 2>&1 | tee "$OUTPUTS_FILE"
  echo "$OUTPUTS_FILE"
}

test_string() {
  mode=$1
  if [ "$mode" = "$DRY_RUN" ]; then
    echo "## Results"
  else
    echo "HttpError: Bad credentials"
  fi
}

test_result() {
  if grep -Fxq "$TEST_STRING" "$OUTPUTS_FILE"; then
    echo
    echo "✅ Test result: passes"
  else
    echo
    echo "❌ Test result: fails"
    exit 1
  fi
}

run_test() {
  sarif_file="$1"
  odc_sarif="$2"
  run_docker "$IMAGE" "$sarif_file" "$odc_sarif"
  TEST_STRING=$(test_string "$MODE")
  test_result "$TEST_STRING"
}

###
# Script starts here
###
export DRY_RUN="true"
export LIVE_RUN="false"
MODE=$DRY_RUN
OUTPUTS_FILE=./test/test-outputs.txt
PR_NUMBER=1
REPOSITORY=tomwillis608/sarif-to-comment-action
BRANCH=fake-test-branch
TOKEN=fake_password
TITLE="Test security PR comment from build"
SHOW_RULE_DETAILS=true

rm -f $OUTPUTS_FILE
IMAGE=$(create_docker_image)
echo "$IMAGE"

CODEQL_FIXTURE="./test/fixtures/codeql.sarif"
ODC_FIXTURE="./test/fixtures/odc.sarif"

run_test "$CODEQL_FIXTURE" "false"
run_test "$ODC_FIXTURE" "true"
