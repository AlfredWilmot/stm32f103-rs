#!/usr/bin/env bash

# fail-fast, propagate error-codes through pipelines
set -e -o pipefail

run_step() {
  green='\033[0;32m'
  reset='\033[0m\n'
  printf "${green}%s${reset}" "$*"
  eval "$*"
}

# check shell-scripts
run_step "find . -name '*.sh' -exec shellcheck {} \;"
