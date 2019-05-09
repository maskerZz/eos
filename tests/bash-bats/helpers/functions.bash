. ./scripts/helpers/eosio.bash # Obtain dependency versions and paths


function debug() {
  printf " ---------\\n STATUS: ${status}\\n${output}\\n ---------\\n\\n" >&3
}

function setup-bats-dirs () {
    if [[ ! $HOME =~ "/$(whoami)" ]]; then 
        mkdir -p $HOME
    fi
    if [[ $TEMP_DIR =~ "${HOME}" ]]; then # Protection
        mkdir -p $TEMP_DIR
        rm -rf $TEMP_DIR/*
    fi
}

function teardown() { # teardown is run once after each test, even if it fails
  [[ -d "$HOME" ]] && rm -rf "$HOME"
}

function install-package() {
  if [[ $ARCH == "Linux" ]]; then
    ( [[ $NAME =~ "Amazon Linux" ]] || [[ $NAME == "CentOS Linux" ]] ) && yum install -y $1 || true
    [[ $NAME =~ "Ubuntu" ]] && apt-get update && ( apt-get install -y $1 || true )
  fi
  true # Required; Weird behavior without it
}

[[ $NAME =~ "Ubuntu" ]] && install-package clang &>/dev/null
( [[ $NAME == "CentOS Linux" ]] || [[ $NAME =~ "Amazon" ]] ) && install-package which &>/dev/null && install-package gcc-c++ &>/dev/null

function uninstall-package() {
  if [[ $ARCH == "Linux" ]]; then
    ( [[ $NAME =~ "Amazon Linux" ]] || [[ $NAME == "CentOS Linux" ]] ) && ( yum remove -y $1 || true )
    [[ $NAME =~ "Ubuntu" ]] && ( apt-get remove -y $1 || true )
  fi
  true
}

trap teardown EXIT
setup-bats-dirs