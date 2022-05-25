#!/bin/bash

set -o pipefail
set -exu
set -C

echo "Convert SARIF file $1"
echo "For url $3"
echo "For owner $4"
echo "For repo $5"

time=$(date)
echo "::set-output name=time::$time"
