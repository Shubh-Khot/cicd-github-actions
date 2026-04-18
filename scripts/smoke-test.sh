#!/bin/bash
set -e

BASE_URL="${STAGING_URL:-http://localhost:8000}"
MAX_RETRIES=5
RETRY_DELAY=10

echo "Running smoke tests against: $BASE_URL"

check_endpoint() {
  local endpoint=$1
  local expected_status=$2
  local retries=0

  while [ $retries -lt $MAX_RETRIES ]; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    if [ "$status" -eq "$expected_status" ]; then
      echo "PASS: $endpoint returned $status"
      return 0
    fi
    echo "RETRY ($((retries+1))/$MAX_RETRIES): $endpoint returned $status, expected $expected_status"
    sleep $RETRY_DELAY
    retries=$((retries + 1))
  done

  echo "FAIL: $endpoint did not return $expected_status after $MAX_RETRIES retries"
  return 1
}

check_endpoint "/health" 200
check_endpoint "/" 200

echo "All smoke tests passed!"
