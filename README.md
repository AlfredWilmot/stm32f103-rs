# Developing for the `STM32F103` using rust

> [!WARNING]
> WORK IN PROGRESS
Following along with [this](https://docs.rust-embedded.org/book/intro/install.html)
guide do see how far it'll take me.

## Notes

Info regarding `STM32F103C8`:
```text
Manufacturer:
 - STMicroelectronics

Family:
 - STM32F1 Series

Variant
 - STM32F103C8

Cores
 - armv7m

Memory Regions:
 - [BANK_1 0x8000000 - 0x8010000]
 - [SRAM 0x20000000 - 0x20005000]
```

- https://github.com/stm32-rs/stm32-rs
- https://codezup.com/programming-stm32-microcontrollers-with-rust-embedded-guide/
- https://github.com/knurling-rs/app-template


## Preparing Development Host (deprecated in favor of setup scripts/ `Dockerfile`)
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
    sudo apt install -y gdb-arm-none-eabi openocd qemu-system-arm usbutils
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

- check the file-access control list for the device to verify extended device access permissions:
    ```bash
    lsusb | grep ST-LINK
    # Bus 001 Device 112: ID 0483:3748 STMicroelectronics ST-LINK/V2
    #     ^           ^

    USB_PATH="$(lsusb | grep ST-LINK | awk '{print "/dev/bus/usb/"$2"/"$4}' | tr -d ':')"
    #/dev/bus/usb/001/112

    getfacl "${USB_PATH}" | grep user
    # user::rw-
    # user:<YOUR_USER>:rw-
    #           ^indicates YOUR_USER is able to access the device directly
    ```

## References
- [Cortex-M3 docs](https://developer.arm.com/Processors/Cortex-M3)

