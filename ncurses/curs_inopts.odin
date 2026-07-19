package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    cbreak :: proc() -> c.int ---
    nocbreak :: proc() -> c.int ---

    echo :: proc() -> c.int ---
    noecho :: proc() -> c.int ---

    intrflush :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    keypad :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    meta :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    nodelay :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    notimeout :: proc(win: WINDOW, bf: c.bool) -> c.int ---

    nl :: proc() -> c.int ---
    nonl :: proc() -> c.int ---

    qiflush :: proc() ---
    noqiflush :: proc() ---

    raw :: proc() -> c.int ---
    noraw :: proc() -> c.int ---

    halfdelay :: proc(tenths: c.int) -> c.int ---
    timeout :: proc(delay: c.int) ---
    wtimeout :: proc(win: WINDOW, delay: c.int) ---

    typeahead :: proc(fd: c.int) -> c.int ---

    is_cbreak :: proc() -> c.int ---
    is_echo :: proc() -> c.int ---
    is_nl :: proc() -> c.int ---
    is_raw :: proc() -> c.int ---
}
