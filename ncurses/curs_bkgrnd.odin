package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    bkgrnd :: proc(wch: cchar_t_ptr) -> c.int ---
    wbkgrnd :: proc(win: WINDOW, wch: cchar_t_ptr) -> c.int ---

    bkgrndset :: proc(wch: cchar_t_ptr) ---
    wbkgrndset :: proc(win: WINDOW, wch: cchar_t_ptr) ---

    getbkgrnd :: proc(wch: cchar_t_ptr) -> c.int ---
    wgetbkgrnd :: proc(win: WINDOW, wch: cchar_t_ptr) -> c.int ---
}
