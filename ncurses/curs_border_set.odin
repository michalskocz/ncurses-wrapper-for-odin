package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    border_set :: proc(ls, rs, ts, bs, tl, tr, bl, br: cchar_t_ptr) -> c.int ---
    wborder_set :: proc(win: WINDOW, ls, rs, ts, bs, tl, tr, bl, br: cchar_t_ptr) -> c.int ---

    box_set :: proc(win: WINDOW, verch, horch: cchar_t_ptr) -> c.int ---

    hline_set :: proc(wch: cchar_t_ptr, n: c.int) -> c.int ---
    whline_set :: proc(win: WINDOW, wch: cchar_t_ptr, n: c.int) -> c.int ---
    mvhline_set :: proc(y, x: c.int, wch: cchar_t_ptr, n: c.int) -> c.int ---
    mvwhline_set :: proc(win: WINDOW, y, x: c.int, wch: cchar_t_ptr, n: c.int) -> c.int ---

    vline_set :: proc(wch: cchar_t_ptr, n: c.int) -> c.int ---
    wvline_set :: proc(win: WINDOW, wch: cchar_t_ptr, n: c.int) -> c.int ---
    mvvline_set :: proc(y, x: c.int, wch: cchar_t_ptr, n: c.int) -> c.int ---
    mvwvline_set :: proc(win: WINDOW, y, x: c.int, wch: cchar_t_ptr, n: c.int) -> c.int ---
}
