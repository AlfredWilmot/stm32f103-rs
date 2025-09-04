#!/usr/bin/env bash

set -ex -o pipefail

find . -name "*.sh" -exec shellcheck {} \;
