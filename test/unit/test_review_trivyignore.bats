#!/usr/bin/env bats

setup() {
  load '../test_helper.sh'
  _test_helper
  
  # Create temporary test directory
  export TEST_DIR=$(mktemp -d)
  export SCRIPT_PATH="${PWD}/.github/scripts/review_trivyignore.py"
}

teardown() {
  # Cleanup temporary test directory
  rm -rf "$TEST_DIR"
}

@test "script exists and is executable" {
  [ -f "$SCRIPT_PATH" ]
  [ -x "$SCRIPT_PATH" ]
}

@test "script fails when GITHUB_TOKEN is not set" {
  cd "$TEST_DIR"
  
  # Create a simple .trivyignore
  cat > .trivyignore << 'EOF'
CVE-2020-7754
EOF
  
  # Run without GITHUB_TOKEN
  run python "$SCRIPT_PATH"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "GITHUB_TOKEN environment variable not set" ]]
}

@test "script fails when GITHUB_REPOSITORY is not set" {
  cd "$TEST_DIR"
  
  # Create a simple .trivyignore
  cat > .trivyignore << 'EOF'
CVE-2020-7754
EOF
  
  # Run with GITHUB_TOKEN but without GITHUB_REPOSITORY
  # Unset GITHUB_REPOSITORY in the subprocess
  run bash -c "unset GITHUB_REPOSITORY && export GITHUB_TOKEN='test-token' && python '$SCRIPT_PATH'"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "GITHUB_REPOSITORY environment variable not set" ]]
}

@test "script parses .trivyignore with CVE entries" {
  skip "Integration test - requires full environment"
}

@test "script parses .trivyignore with GHSA entries" {
  skip "Integration test - requires full environment"
}

@test "script handles empty .trivyignore" {
  skip "Integration test - requires full environment"
}

@test "script handles .trivyignore with only comments" {
  skip "Integration test - requires full environment"
}

@test "script extracts acceptance dates correctly" {
  skip "Integration test - requires full environment"
}

@test "script extracts reason/context correctly" {
  skip "Integration test - requires full environment"
}
