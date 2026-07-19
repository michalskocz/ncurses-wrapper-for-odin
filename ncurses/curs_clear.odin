package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_clear.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
	erase :: proc() -> c.int ---
	werase :: proc(win: WINDOW) -> c.int ---

	clear :: proc() -> c.int ---
	wclear :: proc(win: WINDOW) -> c.int ---

	clrtoeol :: proc() -> c.int ---
	wclrtoeol :: proc(win: WINDOW) -> c.int ---
}
