package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_printw.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
	printw :: proc(fmt: cstring, #c_vararg args: ..any) -> c.int ---
	wprintw :: proc(win: WINDOW, fmt: cstring, #c_vararg args: ..any) -> c.int ---
	mvprintw :: proc(y: c.int, x: c.int, fmt: cstring, #c_vararg args: ..any) -> c.int ---
	mvwprintw :: proc(win: WINDOW, y: c.int, x: c.int, fmt: cstring, #c_vararg args: ..any) -> c.int ---

	vw_printw :: proc(win: WINDOW, fmt: cstring, args: c.va_list) -> c.int ---
	vwprintw :: proc(win: WINDOW, fmt: cstring, args: c.va_list) -> c.int ---
}
