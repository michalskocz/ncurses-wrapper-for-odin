package ncurses

import "core:c"
// Description: https://invisible-island.net/ncurses/man/curs_addch.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    addchstr :: proc(chstr: [^]chtype) -> c.int ---
    waddchstr :: proc(win: WINDOW, chstr: [^]chtype) -> c.int ---
    mvaddchstr :: proc(y, x: c.int, chstr: [^]chtype) -> c.int ---
    mvwaddchstr :: proc(win: WINDOW, y, x: c.int, chstr: [^]chtype) -> c.int ---

    addchnstr :: proc(chstr: [^]chtype, n: c.int) -> c.int ---
    waddchnstr :: proc(win: WINDOW, chstr: [^]chtype, n: c.int) -> c.int ---
    mvaddchnstr :: proc(y, x: c.int, chstr: [^]chtype, n: c.int) -> c.int ---
    mvwaddchnstr :: proc(win: WINDOW, y, x: c.int, chstr: [^]chtype, n: c.int) -> c.int ---
}
