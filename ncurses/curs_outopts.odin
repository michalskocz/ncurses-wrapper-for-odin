package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    clearok :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    idcok :: proc(win: WINDOW, bf: c.bool) ---
    idlok :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    immedok :: proc(win: WINDOW, bf: c.bool) ---
    leaveok :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    scrollok :: proc(win: WINDOW, bf: c.bool) -> c.int ---

    setscrreg :: proc(top, bot: c.int) -> c.int ---
    wsetscrreg :: proc(win: WINDOW, top, bot: c.int) -> c.int ---
}
