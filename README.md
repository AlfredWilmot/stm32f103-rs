# Developing for the `STM32F103` using rust

> [!WARNING]
> WORK IN PROGRESS

Following along with [this](https://docs.rust-embedded.org/book/intro/install.html)
guide do see how far it'll take me.

## Preparing Development Host
```text
Debian GNU/Linux 12 (bookworm)
Linux debian 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64 GNU/Linux
```

- Installing toolchains:
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

- installing debugging utilities:
    ```bash
    sudo apt install -y gdb-arm-none-eabi openocd qemu-system-arm
    ```

## setup udev rules

This is to allows `OpenOCD` to be used by non-root users.

- connect and verify ST-LINK-V2 as a usb device:
    ```bash
    lsusb | grep ST-LINK
    # Bus 001 Device 111: ID 0483:3748 STMicroelectronics ST-LINK/V2
    #     ^          ^

    USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':')"
    #/dev/bus/usb/001/111

    getfacl "${USB_PATH}" | grep user
    # user::rw-
    ```
- update udev with new rules and reload:
    ```bash
    cat <<EOF | sudo tee /etc/udev/rules.d/70-st-link.rules
    # STM32F rev A/B - ST-LINK/V2
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", TAG+="uaccess"
    # STM32 rev C+ - ST-LINK/V2-1
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", TAG+="uaccess"
    EOF
    # reload udev rules
    sudo udevadm control --reload-rules
    ```

- _(disconnect and reconnect ST-LINK)_

- verify extended device access permissions:
    ```bash
    lsusb | grep ST-LINK
    # Bus 001 Device 112: ID 0483:3748 STMicroelectronics ST-LINK/V2
    #     ^           ^

    USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':')"
    #/dev/bus/usb/001/112

    getfacl "${USB_PATH}" | grep user
    # user::rw-
    # user:<THE_CURREN_USER>:rw-
    ```

## References
- [Cortex-M3 docs](https://developer.arm.com/Processors/Cortex-M3)

