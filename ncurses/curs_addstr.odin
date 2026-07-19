package ncurses

import "core:c"

// Description: https://invisible-island.net/ncurses/man/curs_addstr.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    addstr :: proc(str: cstring) -> c.int ---
    waddstr :: proc(win: WINDOW, str: cstring) -> c.int ---
    mvaddstr :: proc(y, x: c.int, str: cstring) -> c.int ---
    mvwaddstr :: proc(win: WINDOW, y, x: c.int, str: cstring) -> c.int ---

    addnstr :: proc(str: cstring, n: c.int) -> c.int ---
    waddnstr :: proc(win: WINDOW, str: cstring, n: c.int) -> c.int ---
    mvaddnstr :: proc(y, x: c.int, str: cstring, n: c.int) -> c.int ---
    mvwaddnstr :: proc(win: WINDOW, y, x: c.int, str: cstring, n: c.int) -> c.int ---
}
