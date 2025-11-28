#!/usr/bin/env bash
# test/test_helper.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT
export PATH="$PROJECT_ROOT/bin:$PATH"

_test_helper() {
  export BATS_LIB_PATH="${BATS_LIB_PATH:-"/usr/lib"}"
  echo "$BATS_LIB_PATH"
  #    bats_load_library bats-support
  #    bats_load_library bats-assert
  #    bats_load_library bats-file
  #    bats_load_library bats-detik/detik.bash
  export TEST_TMPDIR="$BATS_TEST_TMPDIR"
}
