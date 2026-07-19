package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_getch.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
	getch :: proc() -> c.int ---
	wgetch :: proc(win: WINDOW) -> c.int ---
	mvgetch :: proc(y: c.int, x: c.int) -> c.int ---
	mvwgetch :: proc(win: WINDOW, y: c.int, x: c.int) ---


	ungetch :: proc(_c: c.int) -> c.int ---
	has_key :: proc(_c: c.int) -> c.int ---
}
