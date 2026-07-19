package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    newwin :: proc(nlines, ncols, begin_y, begin_x: c.int) -> WINDOW ---
    delwin :: proc(win: WINDOW) -> c.int ---
    mvwin :: proc(win: WINDOW, y, x: c.int) -> c.int ---
    subwin :: proc(orig: WINDOW, nlines, ncols, begin_y, begin_x: c.int) -> WINDOW ---
    derwin :: proc(orig: WINDOW, nlines, ncols, begin_y, begin_x: c.int) -> WINDOW ---
    mvderwin :: proc(win: WINDOW, par_y, par_x: c.int) -> c.int ---
    dupwin :: proc(win: WINDOW) -> WINDOW ---
    wsyncup :: proc(win: WINDOW) ---
    syncok :: proc(win: WINDOW, bf: c.bool) -> c.int ---
    wcursyncup :: proc(win: WINDOW) ---
    wsyncdown :: proc(win: WINDOW) ---
}
