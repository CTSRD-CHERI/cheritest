cmake_minimum_required(VERSION 3.4)
project(cheritest LANGUAGES NONE)

function(add_targets _suffix _flags _objdir)
	# Unset all make variables that are added by the cmake build
	set(SET_MAKE_ENV_VARS -u MAKE -u MAKELEVEL -u MFLAGS -u MAKEFLAGS ${_flags})
	set(_objdir_flags OBJDIR=${_objdir} QEMU_LOGDIR=${_objdir}/qemu_log)
	file(MAKE_DIRECTORY ${_objdir})
	add_custom_target(run-make${_suffix} ALL VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j8 -k elfs ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	add_custom_target(run-make${_suffix}-j1 VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j1 elfs ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	add_custom_target(run-qemu-tests${_suffix} VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j4 pytest_qemu ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	add_custom_target(qemu-nosetests${_suffix} VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j1 nosetests_qemu ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	add_custom_target(qemu-pytest${_suffix} VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j1 nosetests_qemu ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
	add_custom_target(purecap-qemu${_suffix} VERBATIM USES_TERMINAL
		COMMAND env ${SET_MAKE_ENV_VARS} make -j1 qemu_purecap_tests ${_objdir_flags}
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
endfunction()

foreach(_capsize 128 256)
	set(_target_suffix "-${_capsize}")
	set(_cheri_flag "CAP_SIZE=${_capsize}")
	add_targets("${_target_suffix}" "TEST_FPU=0 CLANG=1 ${_cheri_flag}"
		"${CMAKE_CURRENT_BINARY_DIR}/llvm-${_capsize}")
	add_targets("${_target_suffix}-with-fpu" "TEST_FPU=1 CLANG=1 ${_cheri_flag}"
		"${CMAKE_CURRENT_BINARY_DIR}/llvm-${_capsize}")

	# Use a different builddir for binutils:
	add_targets("${_target_suffix}-binutils" "CHERI_SDK_USE_GNU_AS=1 TEST_FPU=0 CLANG=0 ${_cheri_flag}"
		"${CMAKE_CURRENT_BINARY_DIR}/binutils-${_capsize}")
	add_targets("${_target_suffix}-binutils-with-fpu" "CHERI_SDK_USE_GNU_AS=1 TEST_FPU=1 CLANG=0 ${_cheri_flag}"
		"${CMAKE_CURRENT_BINARY_DIR}/binutils-${_capsize}")

	# Add clean targets for the build directories
	add_custom_target(clean-llvm${_target_suffix} VERBATIM USES_TERMINAL
		COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/llvm-${_capsize}" &&
			${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/llvm-${_capsize}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
	add_custom_target(clean-binutils${_target_suffix} VERBATIM USES_TERMINAL
		COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_BINARY_DIR}/binutils-${_capsize}" &&
			${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/binutils-${_capsize}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endforeach()

add_custom_target(env VERBATIM USES_TERMINAL COMMAND env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(env-clean VERBATIM USES_TERMINAL COMMAND env ${SET_MAKE_ENV_VARS} env | sort WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
