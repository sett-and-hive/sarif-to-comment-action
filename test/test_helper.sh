#!/usr/bin/env bash
# test/test_helper.bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT
export PATH="$PROJECT_ROOT/bin:$PATH"

setup() {
  TEST_TMPDIR="$BATS_TEST_TMPDIR"
  export TEST_TMPDIR
}
