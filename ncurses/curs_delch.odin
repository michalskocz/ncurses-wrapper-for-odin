package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	delch :: proc() -> c.int ---
	wdelch :: proc(win: WINDOW) -> c.int ---
	mvdelch :: proc(y, x: c.int) -> c.int ---
	mvwdelch :: proc(win: WINDOW, y, x: c.int) -> c.int ---
}
