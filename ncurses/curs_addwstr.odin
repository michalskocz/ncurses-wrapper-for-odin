package ncurses

import "core:c"

// Description: https://invisible-island.net/ncurses/man/curs_addwstr.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    addwstr :: proc(wstr: [^]c.wchar_t) -> c.int ---
    waddwstr :: proc(win: WINDOW, wstr: [^]c.wchar_t) -> c.int ---
    mvaddwstr :: proc(y, x: c.int, wstr: [^]c.wchar_t) -> c.int ---
    mvwaddwstr :: proc(win: WINDOW, y, x: c.int, wstr: [^]c.wchar_t) -> c.int ---

    addnwstr :: proc(wstr: [^]c.wchar_t, n: c.int) -> c.int ---
    waddnwstr :: proc(win: WINDOW, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
    mvaddnwstr :: proc(y, x: c.int, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
    mvwaddnwstr :: proc(win: WINDOW, y, x: c.int, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
}
