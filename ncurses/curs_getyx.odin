package ncurses

import "core:c"


foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    getyx :: proc(win: WINDOW, y: c.int, x: c.int) ---
    getbegyx :: proc(win: WINDOW, y: c.int, x: c.int) ---
    getmaxyx :: proc(win: WINDOW, y: c.int, x: c.int) ---

    getparyx :: proc(win: WINDOW, y: c.int, x: c.int) ---
}
