FROM rust:1.89.0-slim-trixie@sha256:f9ab60da9c7296b7b1d4c9bc89b56900ca86ee4994133d5431d08d3565f02bac
SHELL ["/bin/bash", "-c"]

# Cross-compile to Cortex-M3 (CPU architecture used by STM32F103)
ENV TOOLCHAIN=thumbv7m-none-eabi

RUN apt update

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
apt install -y \
  "${CORE_GLIBC_BUILD_DEPS[@]}" \
  "${HW_DEBUGGING_UTILS[@]}" \
  "${PROBE_RS_TOOLS_DEPS[@]}" \
  "${CARGO_GENERATE_DEPS[@]}"
EOF

# install toolchain
RUN rustup target add "${TOOLCHAIN}"

# install llvm tools for inspecting binaries
RUN cargo install cargo-binutils && rustup component add llvm-tools

# install cargo-generate for project templating
RUN cargo install cargo-generate

# (install probe-rs, cargo-flash, and cargo-embed)[https://probe.rs/docs/getting-started/installation/]
RUN cargo install probe-rs-tools --locked

# (install stlink-tools)[https://github.com/stlink-org/stlink]
RUN apt install -y stlink-tools
