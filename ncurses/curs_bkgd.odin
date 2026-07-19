package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    bkgd :: proc(ch: chtype) -> c.int ---
    wbkgd :: proc(win: WINDOW, ch: chtype) -> c.int ---

    bkgdset :: proc(ch: chtype) ---
    wbkgdset :: proc(win: WINDOW, ch: chtype) ---

    getbkgd :: proc(win: WINDOW) -> chtype ---
}
