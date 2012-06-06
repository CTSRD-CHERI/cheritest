# Test to regenerate expected register values for fuzz regression tests.
# This is useful when the test framework changes causes addresses stored in registers to change value.

for TEST_S in tests/fuzz_regressions/*.s; do
    TEST_NAME=$(basename ${TEST_S/.s/})
    make gxemul_log/${TEST_NAME}_gxemul.log gxemul_log/${TEST_NAME}_gxemul_cached.log
    PYTHONPATH=. ./fuzzing/export_regression.py --name ${TEST_NAME} ${TEST_NAME} > tests/fuzz_regressions/${TEST_NAME}.py
done