# Blinky

An area to experiment with embedded rust development.

> [!NOTE]
> This project was initially derived from the
> [stm32f1xx-hal](https://github.com/stm32-rs/stm32f1xx-hal/) crate,
> to serve as a starting point for my embedded development.
>
> [probe-rs](https://crates.io/crates/probe-rs) looks like a promising tool
> for developing against a wide range of targets, however
> I couldn't get it working with my `ST-LINKV2`, so I've fallen back on
> other tooling for flashing/debugging my stm32 target
> (see the project `Dockerfile` for more information).

> [!WARNING]
> Even though the `Dockerfile` provides the development environment, and tooling
> to interface with the embedded target, you will still need to include the
> relevant toolchain on your host for `rust-analyzer` to work properly
> (e.g.`rustup target add thumbv7m-none-eabi`) if it's being run from the host.
> I haven't looked into running `rust-analyzer` from the development container itself
> and then somehow hooking that into the IDE on my host machine, though this is
> probaby not worthwhile.

# References
- [`probe-rs`](https://crates.io/crates/probe-rs)
- [`defmt`](https://github.com/knurling-rs/defmt)
- [`flip-link`](https://github.com/knurling-rs/flip-link)
- [Knurling](https://knurling.ferrous-systems.com)
- [Ferrous Systems](https://ferrous-systems.com/)
