#!/usr/bin/env bash

set -ex -o pipefail
find . -name Vagrantfile -exec rubocop -A {} \;
uvx ansible-lint
