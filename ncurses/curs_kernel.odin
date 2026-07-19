package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    def_prog_mode :: proc() -> c.int ---
    def_shell_mode :: proc() -> c.int ---

    reset_prog_mode :: proc() -> c.int ---
    reset_shell_mode :: proc() -> c.int ---

    resetty :: proc() -> c.int ---
    savetty :: proc() -> c.int ---

    getsyx :: proc(y, x: c.int) ---
    setsyx :: proc(y, x: c.int) ---

    curs_set :: proc(visibility: c.int) -> c.int ---
    mvcur :: proc(oldrow, oldcol, newrow, newcol: c.int) -> c.int ---
    napms :: proc(ms: c.int) -> c.int ---
    ripoffline :: proc(line: c.int, init: proc "c" (win: WINDOW, ncols: c.int) -> c.int) -> c.int ---
}
