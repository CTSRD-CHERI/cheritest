cmake_minimum_required(VERSION 3.4)
project(cheritest LANGUAGES NONE)
# Unset all make variables that are added by the cmake build
set(SET_MAKE_ENV_VARS -u MAKE -u MAKELEVEL -u MFLAGS -u MAKEFLAGS
	COP1=1 CLANG=1)
add_custom_target(run-make ALL VERBATIM USES_TERMINAL
	COMMAND env ${SET_MAKE_ENV_VARS} make -j8 -k elfs
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-make-gnu-as ALL VERBATIM USES_TERMINAL
	COMMAND env ${SET_MAKE_ENV_VARS} CHERI_SDK_USE_GNU_AS=1 make -j8 -k elfs
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-make-j1 VERBATIM USES_TERMINAL
        COMMAND env ${SET_MAKE_ENV_VARS} make -j1 elfs
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-qemu-tests VERBATIM USES_TERMINAL
        COMMAND env ${SET_MAKE_ENV_VARS} CAP_SIZE=128 make -j4 pytest_qemu
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(run-qemu-tests-256 VERBATIM USES_TERMINAL
	COMMAND env ${SET_MAKE_ENV_VARS} CAP_SIZE=256 make -j4 pytest_qemu
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(qemu-nosetests VERBATIM USES_TERMINAL
	COMMAND env ${SET_MAKE_ENV_VARS} make -j1 nosetests_qemu
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(purecap-qemu VERBATIM USES_TERMINAL
	COMMAND env ${SET_MAKE_ENV_VARS} make -j1 qemu_purecap_tests
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(env VERBATIM USES_TERMINAL COMMAND env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(env-clean VERBATIM USES_TERMINAL COMMAND env ${SET_MAKE_ENV_VARS} env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
