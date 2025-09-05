#!/usr/bin/env bash

set -ex

# Setup and enter a docker container that has access to a connected STLINK

STM32_IMG="stm32:main"
USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':'| sed -n '1p')"
USER="stm32"
SHARE_DIR="./share"
declare -a RUN_ARGS BUILD_ARGS

USER_ID="$(id -u)"
GROUP="plugdev"
PLUGDEV_GID="$(id | sed -n 's/.*[,=]\([0-9][0-9]*\)(plugdev).*/\1/p')"

if [ -z "${PLUGDEV_GID}" ]; then
  echo "Err: 'plugdev' group is missing from host." >&2
  exit 1
fi

# rebuild the dev image (finishes quickly when cached)
BUILD_PREFIX="docker build --debug -t ${STM32_IMG}"
BUILD_ARGS+=(
  "--build-arg=USER=${USER}"
  "--build-arg=GROUP=${GROUP}"
  "--build-arg=USER_ID=${USER_ID}"
)
BUILD_CMD="${BUILD_PREFIX} ${BUILD_ARGS[*]} ."
eval "${BUILD_CMD}"

# ensure the share directory is present and has the correct owner/group used by the dev container
mkdir -p "${SHARE_DIR}"
chown -R "${USER_ID}:${USER_ID}" "${SHARE_DIR}"

if [ -n "${USB_PATH}" ]; then
  RUN_ARGS+=(
    "--device=${USB_PATH}"
    "--env USB_PATH=${USB_PATH}"
  )
fi

RUN_PREFIX="docker run --rm -it --privileged --cap-add SYS_ADMIN"
RUN_ARGS+=(
  "-v $(pwd)/share:/home/${USER}/share"
  "--user=${USER}:${PLUGDEV_GID}"
)
RUN_EXTRA="${*}"
RUN_CMD="${RUN_PREFIX} ${RUN_ARGS[*]} ${RUN_EXTRA} ${STM32_IMG} /bin/bash"

echo "${RUN_CMD}"
eval "${RUN_CMD}"
