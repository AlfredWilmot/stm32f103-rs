#!/usr/bin/env bash

# print debug lines, exit on error, propagate non-zero pipeline exit codes
set -ex -o pipefail

# Preparing udev rules so non-root user can access st-link device
# [https://probe.rs/docs/getting-started/probe-setup/#linux-udev-rules]

PLUGDEV_GROUP="plugdev"
UDEV_RULES_NOM="69-probe-rs.rules"
UDEV_RULES_SRC="https://probe.rs/files/${UDEV_RULES_NOM}"
UDEV_RULES_SHA="ca3c6577979b9b68e97f2ce4c3ebe78017c7bb935f8768a82d4290403638298a"
UDEV_RULES_DST="/etc/udev/rules.d/${UDEV_RULES_NOM}"

if [ "$(sha256sum "${UDEV_RULES_DST}" | awk '{print $1}')" != "${UDEV_RULES_SHA}" ]; then
  echo "INFO: downloading ${UDEV_RULES_SRC} ..."
  sudo curl -s -o "${UDEV_RULES_DST}" "${UDEV_RULES_SRC}"
  # ensure new rules are used
  sudo udevadm control --reload
  # ensure new rules are applied to already connected devies
  sudo udevadm trigger
fi

# ensure the current user is added to the device-access group specified in the udev rules
PLUGDEV_GROUP="$(sed -ne 's/^.*GROUP="\([^"]*\)".*$/\1/p' "${UDEV_RULES_DST}" | sed -n '1p')"
if [ -z "${PLUGDEV_GROUP}" ]; then
  echo "ERROR: could not infer PLUGDEV_GROUP from ${UDEV_RULES_DST}"
  exit 1
fi

# create group if missing
if ! groups | grep -q "${PLUGDEV_GROUP}"; then
  sudo groupadd "${PLUGDEV_GROUP}" &> /dev/null || true
fi

# add user to group if not already a member
if ! id | grep -q "${PLUGDEV_GROUP}"; then
  sudo usermod -aG "${PLUGDEV_GROUP}" "${USER}"
fi
