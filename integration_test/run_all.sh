#!/bin/bash
# Flutter Integration Test Orchestrator
# Runs all integration tests sequentially against production

set -e

API_BASE_URL="${API_BASE_URL:-https://kmipn-26-deno.careday17.workers.dev}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR=".sisyphus/evidence"
LOG_FILE="$LOG_DIR/integration-test-$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

echo "=========================================="
echo "Flutter Integration Test Runner"
echo "=========================================="
echo "API Base URL: $API_BASE_URL"
echo "Log file: $LOG_FILE"
echo "Start time: $(date)"
echo "=========================================="

# Track overall result
OVERALL_RESULT=0

# Function to run a test and capture result
run_test() {
    local test_path="$1"
    local test_name=$(basename "$test_path" .dart)
    local test_log="$LOG_DIR/integration-test-$test_name-$TIMESTAMP.log"

    echo ""
    echo ">>> Running: $test_path"
    echo ">>> Log: $test_log"

    if flutter test integration_test/"$test_path" \
        --dart-define=API_BASE_URL="$API_BASE_URL" \
        2>&1 | tee "$test_log"; then
        echo "✅ PASSED: $test_path"
    else
        echo "❌ FAILED: $test_path"
        OVERALL_RESULT=1
    fi
}

# Run all integration tests in order
# warga flow tests
run_test "warga/warga_full_flow_test.dart"
run_test "warga/warga_duplicates_test.dart"
run_test "warga/warga_stats_test.dart"

# surveyor flow tests
run_test "surveyor/surveyor_full_flow_test.dart"
run_test "surveyor/surveyor_checklist_test.dart"
run_test "surveyor/surveyor_clarification_test.dart"

# petugas flow tests
run_test "petugas/petugas_full_flow_test.dart"
run_test "petugas/petugas_reject_test.dart"

# verifikator flow tests
run_test "verifikator/verifikator_full_flow_test.dart"
run_test "verifikator/verifikator_combine_separate_test.dart"
run_test "verifikator/verifikator_sanggahan_test.dart"

# operator flow tests
run_test "operator/operator_full_flow_test.dart"
run_test "operator/operator_merge_test.dart"
run_test "operator/operator_stats_test.dart"

# admin_daerah flow tests
run_test "admin_daerah/admin_daerah_dashboard_test.dart"

# executive flow tests
run_test "executive/executive_dashboard_test.dart"

# agent flow tests
run_test "agent/agent_full_flow_test.dart"

echo ""
echo "=========================================="
echo "Integration Test Run Complete"
echo "End time: $(date)"
echo "=========================================="

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "✅ ALL TESTS PASSED"
else
    echo "❌ SOME TESTS FAILED"
fi

exit $OVERALL_RESULT
