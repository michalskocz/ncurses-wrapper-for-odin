package ncurses

import "core:c"

// Description: https://invisible-island.net/ncurses/man/curs_addwstr.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    alloc_pair :: proc(fg, bg: c.int) -> c.int ---
    find_pair :: proc(fg, bg: c.int) -> c.int ---
    free_pair :: proc(pair: c.int) -> c.int ---
}
