#!/usr/bin/env bash
#
# BATS runner

# set -x
set -euo pipefail

create_docker_image() {
  TEST_IMAGE=comment-test-image
  docker build . -t "$TEST_IMAGE" -q
}

# 0. If the environment is deficient, fail fast
if ! docker info >/dev/null 2>&1; then
  echo "⚠️  Error: Docker is not running. Skipping integration tests."
  exit 1
fi

command -v bats >/dev/null 2>&1 || {
  echo "⚠️  Error: bats is not installed or not on PATH. Skipping integration tests." >&2
  exit 1
}

# 1 build the docker image to test

#IMAGE=$(create_docker_image)
echo "Building docker image..."
_=$(create_docker_image)
echo "Built docker image"

# 2 Invoke bats

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || {
  echo "⚠️  Error: cannot find project root. Skipping integration tests." >&2
  exit 1
}
export PROJECT_ROOT
export PATH="$PROJECT_ROOT:$PATH"
cd "$PROJECT_ROOT" || {
  echo "⚠️  Error: cannot reach project root. Skipping integration tests." >&2
  exit 1
}
echo "Running in:"
pwd

bats --verbose-run --recursive test/unit
