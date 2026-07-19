package ncurses

import "core:c"

// Description: https://invisible-island.net/ncurses/man/curs_add_wchstr.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    add_wchstr :: proc(wchstr: cchar_t_ptr) -> c.int ---
    wadd_wchstr :: proc(win: WINDOW, wchstr: cchar_t_ptr) -> c.int ---
    mvadd_wchstr :: proc(y, x: c.int, wchstr: cchar_t_ptr) -> c.int ---
    mvwadd_wchstr :: proc(win: WINDOW, y, x: c.int, wchstr: cchar_t_ptr) -> c.int ---

    add_wchnstr :: proc(wchstr: cchar_t_ptr, n: c.int) -> c.int ---
    wadd_wchnstr :: proc(win: WINDOW, wchstr: cchar_t_ptr, n: c.int) -> c.int ---
    mvadd_wchnstr :: proc(y, x: c.int, wchstr: cchar_t_ptr, n: c.int) -> c.int ---
    mvwadd_wchnstr :: proc(win: WINDOW, y, x: c.int, wchstr: cchar_t_ptr, n: c.int) -> c.int ---
}
