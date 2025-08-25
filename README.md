# Developing for the `STM32F103` using rust

> [!WARNING]
> WORK IN PROGRESS

Following along with [this](https://docs.rust-embedded.org/book/intro/install.html)
guide do see how far it'll take me.

## Development host
```text
Debian GNU/Linux 12 (bookworm)
Linux debian 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64 GNU/Linux
```

## Installing toolchains
```bash
# adde the Cortex-M3 toolchain for cross-compiling
rustup target add thumbv7m-none-eabi

# LLVM tools for inspecting binaries (objdump, nm, size)
cargo install cargo-binutils
rustup component add llvm-tools

# project generation from templates
sudo apt install -y libssl-dev pkg-config
cargo install cargo-generate
```

## References
- [Cortex-M3 docs](https://developer.arm.com/Processors/Cortex-M3)

