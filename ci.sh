#!/usr/bin/env bash

set -ex -o pipefail

find . -name Vagrantfile -exec rubocop -A {} \;
find . -name "*.sh" -exec shellcheck {} \;
uvx ansible-lint
