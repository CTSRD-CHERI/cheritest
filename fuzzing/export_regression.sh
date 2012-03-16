TEST_NAME=$1
if [ -z "$TEST_NAME" ]; then
    echo Please specify a test name.
    exit 1
fi
# Slightly change test name to avoid confusion.
NEW_NAME=${TEST_NAME/test_fuzz/test_regfuzz}

make gxemul_log/${TEST_NAME}_gxemul.log gxemul_log/${TEST_NAME}_gxemul_cached.log
cp tests/fuzz/${TEST_NAME}.s tests/fuzz_regressions/${NEW_NAME}.s || exit 1
PYTHONPATH=. ./fuzzing/export_regression.py --name ${NEW_NAME} ${TEST_NAME} > tests/fuzz_regressions/${NEW_NAME}.py
