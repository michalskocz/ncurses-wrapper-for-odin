package ncurses

import "core:c"

// Description: https://invisible-island.net/ncurses/man/curs_addch.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    addch :: proc(ch: chtype) -> c.int ---
    waddch :: proc(win: WINDOW, ch: chtype) -> c.int ---
    mvaddch :: proc(y, x: c.int, ch: chtype) -> c.int ---
    mvwaddch :: proc(win: WINDOW, y, x: c.int, ch: chtype) -> c.int ---

    echochar :: proc(ch: chtype) -> c.int ---
    wechochar :: proc(win: WINDOW, ch: chtype) -> c.int ---
}
