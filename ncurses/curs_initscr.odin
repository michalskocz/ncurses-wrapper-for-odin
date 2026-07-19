package ncurses

import "core:c"

foreign import lib "system:ncurses"

// Description: https://invisible-island.net/ncurses/man/curs_initscr.3x.html
@(default_calling_convention="c")
foreign lib {
	initscr :: proc() -> WINDOW ---
	endwin :: proc() -> c.int ---


	newterm :: proc(type: cstring, outf: [^]c.FILE, inf: [^]c.FILE) -> SCREEN ---
	set_term :: proc(new: SCREEN) -> SCREEN ---
	delscreen :: proc(sp: SCREEN) ---
}
