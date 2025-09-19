//! DISCLAIMER: THIS CODE-SNIPPET IS DERIVED FROM https://github.com/stm32-rs/stm32f1xx-hal/blob/master/examples/blinky.rs
//!
//! Blinks an LED
//!
//! This assumes that a LED is connected to pc13 as is the case on the blue pill board.
//!
//! Note: Without additional hardware, PC13 should not be used to drive an LED, see page 5.1.2 of
//! the reference manual for an explanation. This is not an issue on the blue pill.
//!
//!
//! TODO:
//! incorporate serial over USB; expose a basic CLI for controlling the rate
//! at which the on-board LED blinks
//!
//! the CLI tool should have the following commands:
//! -> help (displays a help menu; this is the default option for invalid input)
//! -> set x (set the flash rate)
//! -> get (return the current flash rate)
//! -> off (deactivate the LED)
//! -> on (activate the LED)

#![deny(unsafe_code)]
#![no_std]
#![no_main]

use cortex_m::asm::delay;
use panic_halt as _;

use nb::block;

use cortex_m_rt::entry;
use stm32f1xx_hal::usb::{Peripheral};
use stm32f1xx_hal::{pac, prelude::*, timer::Timer};
use usb_device::prelude::*;
use stm32_usbd::{UsbBus};
use usbd_serial::{SerialPort, USB_CLASS_CDC};

#[entry]
fn main() -> ! {
    // Get access to the core peripherals from the cortex-m crate
    let cp = cortex_m::Peripherals::take().unwrap();

    // Get access to the device specific peripherals from the peripheral access crate
    let dp = pac::Peripherals::take().unwrap();
    let mut flash = dp.FLASH.constrain();
    let rcclk = dp.RCC.constrain();
    let clks = rcclk.cfgr.freeze(&mut flash.acr);

    // Acquire the GPIOC peripheral, and configure GPIOC pin 13 as a push-pull output.
    let mut gpioc = dp.GPIOC.split();
    let mut led = gpioc.pc13.into_push_pull_output(&mut gpioc.crh);
    led.set_high(); // turn off LED

    let mut gpioa = dp.GPIOA.split();
    let mut usb_dp = gpioa.pa12.into_push_pull_output(&mut gpioa.crh);
    usb_dp.set_low();  // send RESET to USB bus by turning D+ pin on
                       // (needed to reset device when new firmware is flashed)
    delay(clks.sysclk().raw() / 100);

    let usb = Peripheral {
        usb: dp.USB,
        pin_dm: gpioa.pa11,
        pin_dp: usb_dp.into_floating_input(&mut gpioa.crh),
    };

    let usb_bus = UsbBus::new(usb);

    let serial = usbd_serial::SerialPort::new(&usb_bus);

    let mut timer = Timer::syst(cp.SYST, &clks).counter_hz();
    timer.start(10.Hz()).unwrap();

    // Wait for the timer to trigger an update and change the state of the LED
    loop {
        block!(timer.wait()).unwrap();
        led.set_high();
        block!(timer.wait()).unwrap();
        led.set_low();
    }
}
