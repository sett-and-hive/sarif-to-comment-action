#!/usr/bin/env bats

load '../test_helper.sh'

@test "hello world" {
  run echo "hello world"
  [ "$status" -eq 0 ]
  [ "$output" = "hello world" ]
}
