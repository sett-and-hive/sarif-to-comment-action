#!/usr/bin/env bats

setup() {
  load '../test_helper.sh'
  _test_helper
}

@test "hello world" {
  run echo "hello world"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}
