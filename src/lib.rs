#![feature(lang_items)]
#![no_std]

extern crate rlibc;

#[no_mangle]
pub extern "C" fn rust_main() {
  // we have a small stack with no guard page
 
  let hello = b"Hello World!";
  let color_byte = 0x1f; // white fg, blue bg

  let mut hello_colored = [color_byte; 24];
  for (i, char_byte) in hello.into_iter().enumerate() {
    hello_colored[i*2] = *char_byte;
  }

  // write `Hello, World!` to the center of the VGA text buffer
  let buffer_ptr = (0xb8000 + 1988) as *mut _;
  unsafe { *buffer_ptr = hello_colored };

  loop {}
}

#[cfg(test)]
mod tests {
  #[test]
  fn it_works() {

  }
}

#[cfg(not(test))]
#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[cfg(not(test))]
#[lang = "panic_fmt"]
extern "C" fn panic_fmt() -> ! { loop{} }

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn _Unwind_Resume() -> ! {
  loop {}
}
