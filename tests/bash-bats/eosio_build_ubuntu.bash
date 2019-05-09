#!/usr/bin/env bats
load helpers/general

export SCRIPT_LOCATION="scripts/eosio_build.bash"
export TEST_LABEL="[eosio_build_ubuntu]"

[[ $ARCH == "Linux" ]] || exit 0 # Exit 0 is required for pipeline
[[ $NAME == "Ubuntu" ]] || exit 0 # Exit 0 is required for pipeline
( [[ $VERSION_ID == "18.04" ]] || [[ $VERSION_ID == "16.04" ]] ) || exit 0 # Exit 0 is required for pipeline

# A helper function is available to show output and status: `debug`

# Testing Root user
./tests/bash-bats/modules/root-user.bash
# Testing Options
./tests/bash-bats/modules/dep_script_options.bash
# Testing CMAKE
./tests/bash-bats/modules/cmake.bash
# Testing Clang
./tests/bash-bats/modules/clang.bash
# Testing Prompts
./tests/bash-bats/modules/dep_script_prompts.bash

## Needed to load eosio_build_ files properly; it can be empty
@test "${TEST_LABEL} > General" {
    set_system_vars # Obtain current machine's resources and set the necessary variables (like JOBS, etc)

    run bash -c "printf \"y\n%.0s\" {1..100} | ./$SCRIPT_LOCATION"
    [[ ! -z $(echo "${output}" | grep "Executing: make -j${JOBS}") ]] || exit

    [[ ! -z $(echo "${output}" | grep "Starting EOSIO Dependency Install") ]] || exit
    [[ ! -z $(echo "${output}" | grep "Executing: /usr/bin/apt-get update") ]] || exit
    [[ ! -z $(echo "${output}" | grep "python.*found!") ]] || exit
    [[ ! -z $(echo "${output}" | grep "make.*NOT.*found.") ]] || exit
    [[ ! -z $(echo "${output}" | grep ${HOME}.*/src/boost) ]] || exit
    [[ ! -z $(echo "${output}" | grep "make -j${CPU_CORES}") ]] || exit
    [[ ! -z $(echo "${output}" | grep " -G 'Unix Makefiles'") ]] || exit # CMAKE
    [[ ! -z $(echo "${output}" | grep " --with-iostreams --with-date_time") ]] || exit # BOOST
    [[ -z $(echo "${output}" | grep llvm-4.0.*found.) ]] || exit
    [[ -z $(echo "${output}" | grep lcov.*found.) ]] || exit
    [[ ! -z $(echo "${output}" | grep "EOSIO has been successfully built") ]] || exit

}