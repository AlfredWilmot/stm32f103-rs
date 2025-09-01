#!/usr/bin/env bash

# Preparing udev rules so non-root user can access st-link device
# [https://probe.rs/docs/getting-started/probe-setup/#linux-udev-rules]

UDEV_RULES_NOM="69-probe-rs.rules"
UDEV_RULES_SRC="https://probe.rs/files/${UDEV_RULES_NOM}"
UDEV_RULES_DST="/etc/udev/rules.d/${UDEV_RULES_NOM}"
sudo curl -s -o "${UDEV_RULES_DST}" "${UDEV_RULES_SRC}"

# ensure new rules are used
sudo udevadm control --reload

# ensure new rules are applied to already connected devies
sudo udevadm trigger
