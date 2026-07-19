package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_color.3x.html
foreign import lib "system:ncurses"


@(default_calling_convention="c")
foreign lib {

	refresh :: proc() -> c.int ---
	wrefresh :: proc(win: WINDOW) -> c.int ---
	wnoutrefresh :: proc(win: WINDOW) -> c.int ---
	doupdate :: proc() -> c.int ---

	redrawwin :: proc(win: WINDOW) -> c.int ---
	wredrawln :: proc(win: WINDOW, beg_line: c.int, num_lines: c.int) -> c.int ---
}
