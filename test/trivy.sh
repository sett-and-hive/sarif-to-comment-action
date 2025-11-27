#!/bin/bash
#
# Run Trivy locally to detect security flaws in the Docker image

# set -x
set -o pipefail

create_docker_image() {
  TEST_IMAGE=comment-test-image
  docker build . -t "$TEST_IMAGE" -q
}

run_trivy() {
  image="$1"
  echo "image: $image"
  trivy image "$image" --ignorefile .trivyignore --scanners vuln --format table --timeout 15m --ignore-unfixed --severity HIGH,CRITICAL
}

# Fail if trivy is not found
if [ ! "$(which trivy)" ]; then
  echo "Exiting test because trivy not found in the path"
  exit 1
fi

IMAGE=$(create_docker_image)
run_trivy "$IMAGE"
RC=$?

if [[ $RC -eq "0" ]]; then
  echo "✅ Test result: passes"
else
  echo "❌ Test result: fails"
  exit 2
fi
