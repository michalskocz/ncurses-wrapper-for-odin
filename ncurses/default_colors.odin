package ncurses

import "core:c"
// Description: https://invisible-island.net/ncurses/man/default_colors.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    use_default_colors :: proc() -> c.int ---
    assume_default_colors :: proc(fg, bg: c.int) -> c.int ---
}
