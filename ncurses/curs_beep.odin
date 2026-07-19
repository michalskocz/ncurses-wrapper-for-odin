package ncurses

import "base:intrinsics"
import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    beep :: proc() -> c.int ---
    flash :: proc() -> c.int ---
}
