#!/bin/bash
#
# Flip the mode value to control the --dryRun flag

# set -x
set -o pipefail

create_docker_image() {
  TEST_IMAGE=comment-test-image
  docker build . -t "$TEST_IMAGE" -q
}

run_docker() {
  image="$1"
  sarif_file="$2"
  odc_sarif="$3"
  docker run --rm -v "$(pwd)/test":/app/test "$image" "$sarif_file" "$TOKEN" "$REPOSITORY" "$BRANCH" "$PR_NUMBER" "$TITLE" "$SHOW_RULE_DETAILS" "$MODE" "$odc_sarif" "$SIMPLE" 2>&1 | tee "$OUTPUTS_FILE"
  RC=$?
  echo "$OUTPUTS_FILE"
  cat "$OUTPUTS_FILE" >>"$ALL_OUTPUTS_FILE"
  return "$RC"
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
  docker_result=$2
  expect_zero_docker_return=$3
  echo "docker result $docker_result"
  if [ "$docker_result" -gt 0 ]; then
    if [ "$expect_zero_docker_return" = "false" ]; then
      echo "✅ Test result: passes"
    else
      echo "❌ Test result: fails"
      exit 2
    fi
  else
    if grep -Fxq "$TEST_STRING" "$OUTPUTS_FILE"; then
      echo "✅ Test result: passes"
    else
      echo "❌ Test result: fails"
      exit 1
    fi
  fi
}

run_test() {
  sarif_file="$1"
  is_odc_sarif="$2"
  expect_zero_docker_return="$3"
  run_docker "$IMAGE" "$sarif_file" "$is_odc_sarif"
  RC=$?
  TEST_STRING=$(test_string "$MODE")
  test_result "$TEST_STRING" "$RC" "$expect_zero_docker_return"
}

###
# Script starts here
###
export DRY_RUN="true"
export LIVE_RUN="false"
MODE=$DRY_RUN
OUTPUTS_FILE=./test/test-outputs.txt
ALL_OUTPUTS_FILE=./test/all-test-outputs.txt
PR_NUMBER=1
REPOSITORY=sett-and-hive/sarif-to-comment-action
BRANCH=fake-test-branch
TOKEN=fake_password
TITLE="Test security PR comment from build"
SHOW_RULE_DETAILS=true
SIMPLE=false

rm -f $OUTPUTS_FILE
rm -f "$ALL_OUTPUTS_FILE"
touch "$ALL_OUTPUTS_FILE"

IMAGE=$(create_docker_image)

CODEQL_FIXTURE="./test/fixtures/codeql.sarif"
ODC_FIXTURE="./test/fixtures/odc.sarif"
ZERO_BYTE_FIXTURE="./test/fixtures/zero-byte.sarif"
MISSING_FIXTURE="./test/fixtures/sir-not-appearing-in-thisfilm.sarif"
BAD_FIXTURE="./test/fixtures/bad-json.sarif"
SHORT_FIXTURE="./test/fixtures/short.sarif"

results_array=()

pass=$(run_test "$CODEQL_FIXTURE" "false" "true")
value="$(grep "Test result:" <<<"$pass")"
results_array+=("$value")

pass=$(run_test "$ODC_FIXTURE" "true" "true")
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

pass=$(run_test "$ZERO_BYTE_FIXTURE" "false" "false")
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

pass=$(run_test "$MISSING_FIXTURE" "false" "false")
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

pass=$(run_test "$BAD_FIXTURE" "false" "false")
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

pass=$(run_test "$SHORT_FIXTURE" "false" "false")
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

# Run readme test
pass=$(bash ./test/test-readme.sh)
value=$(grep "Test result:" <<<"$pass")
results_array+=("$value")

# Test Summary
content=$(printf '%s\n' "${results_array[@]}")
content="${content//$'\n'/'%0A'}" # make action runner happy
echo "$content"
