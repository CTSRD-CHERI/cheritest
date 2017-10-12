cmake_minimum_required(VERSION 3.4)
project(cheritest LANGUAGES NONE)
# Unset all make variables that are added by the cmake build
set(REMOVE_MAKE_ENV_VARS -u MAKE -u MAKELEVEL -u MFLAGS -u MAKEFLAGS)
add_custom_target(run-make ALL VERBATIM USES_TERMINAL
        COMMAND env ${REMOVE_MAKE_ENV_VARS} make -j8 test_elfs
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-make-j1 VERBATIM USES_TERMINAL
        COMMAND env ${REMOVE_MAKE_ENV_VARS} make -j1 test_elfs
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-qemu-tests VERBATIM USES_TERMINAL
	COMMAND env ${REMOVE_MAKE_ENV_VARS} make -j4 qemu_test_logs
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(qemu-nosetests VERBATIM USES_TERMINAL
        COMMAND env ${REMOVE_MAKE_ENV_VARS} make -j1 nosetests_qemu
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(env VERBATIM USES_TERMINAL COMMAND env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(env-clean VERBATIM USES_TERMINAL COMMAND env ${REMOVE_MAKE_ENV_VARS} env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})