# ---------------------------------------------------------------------------- #
FROM rust:1.89.0-slim-trixie@sha256:f9ab60da9c7296b7b1d4c9bc89b56900ca86ee4994133d5431d08d3565f02bac AS base
# ---------------------------------------------------------------------------- #

SHELL ["/bin/bash", "-c"]

ARG USER
ARG USER_ID
ARG GROUP

# Cross-compile to Cortex-M3 (CPU architecture used by STM32F103)
ENV TOOLCHAIN=thumbv7m-none-eabi

# a dir harbouring local utilities
ENV HOME="/home/${USER}"
ENV UTILS_DIR=".utils"

# create a group and user that the host has granted access the stlink
RUN <<EOF
useradd -l -m -u ${USER_ID} ${USER}
groupadd ${GROUP}
usermod -aG ${GROUP} ${USER}
EOF

WORKDIR ${HOME}
RUN chown -R ${USER}:${GROUP} "${HOME}"

# ---------------------------------------------------------------------------- #
FROM base AS core
# ---------------------------------------------------------------------------- #

# install apt package deps
RUN <<EOF
CORE_GLIBC_BUILD_DEPS=(
  build-essential
)
# https://docs.rust-embedded.org/book/intro/install/linux.html#packages
HW_DEBUGGING_UTILS=(
  gdb-multiarch
  openocd
  qemu-system-arm
  usbutils
  acl
)
MCU_BUILD_FLASH_TOOLS=(
  binutils-arm-none-eabi
  stlink-tools # (tools for interacting with STLINK via CLI)[https://github.com/stlink-org/stlink]
)
apt-get update
apt-get install -y --no-install-recommends \
  "${CORE_GLIBC_BUILD_DEPS[@]}" \
  "${HW_DEBUGGING_UTILS[@]}" \
  "${MCU_BUILD_FLASH_TOOLS[@]}"
rm -rf /var/lib/apt/lists
EOF

USER ${USER}

RUN <<EOF
# install toolchain
rustup target add "${TOOLCHAIN}"
# install llvm tools for inspecting binaries
cargo install cargo-binutils && rustup component add llvm-tools
EOF

USER root

# ---------------------------------------------------------------------------- #
FROM core AS final
# ---------------------------------------------------------------------------- #

RUN <<EOF
BASE_UTILS=(stow git)
apt-get update
apt-get install -y --no-install-recommends "${BASE_UTILS[@]}"
rm -rf /var/lib/apt/lists
EOF

COPY --chown="${USER}:${GROUP}" "${UTILS_DIR}" "${UTILS_DIR}"
RUN cd "${UTILS_DIR}" && stow .

USER ${USER}

# ---------------------------------------------------------------------------- #
FROM final AS extras
# ---------------------------------------------------------------------------- #

RUN <<EOF
PROBE_RS_TOOLS_DEPS=(
  pkg-config
  libudev-dev
  cmake
  git
)
CARGO_GENERATE_DEPS=(
  libssl-dev
  pkg-config
)
apt-get update
apt-get install -y --no-install-recommends \
  "${PROBE_RS_TOOLS_DEPS[@]}" \
  "${CARGO_GENERATE_DEPS[@]}"
rm -rf /var/lib/apt/lists
EOF

USER ${USER}

RUN <<EOF
# install cargo-generate for project templating
cargo install cargo-generate
# (install probe-rs, cargo-flash, and cargo-embed)[https://probe.rs/docs/getting-started/installation/]
cargo install probe-rs-tools --locked
EOF
