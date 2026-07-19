package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    border :: proc(ls, rs, ts, bs, tl, tr, bl, br: chtype) -> c.int ---
    wborder :: proc(win: WINDOW, ls, rs, ts, bs, tl, tr, bl, br: chtype) -> c.int ---

    box :: proc(win: WINDOW, verch, horch: chtype) -> c.int ---

    hline :: proc(ch: chtype, n: c.int) -> c.int ---
    whline :: proc(win: WINDOW, ch: chtype, n: c.int) -> c.int ---
    mvhline :: proc(y, x: c.int, ch: chtype, n: c.int) -> c.int ---
    mvwhline :: proc(win: WINDOW, y, x: c.int, ch: chtype, n: c.int) -> c.int ---

    vline :: proc(ch: chtype, n: c.int) -> c.int ---
    wvline :: proc(win: WINDOW, ch: chtype, n: c.int) -> c.int ---
    mvvline :: proc(y, x: c.int, ch: chtype, n: c.int) -> c.int ---
    mvwvline :: proc(win: WINDOW, y, x: c.int, ch: chtype, n: c.int) -> c.int ---
}
