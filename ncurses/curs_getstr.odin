package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	getstr :: proc(str: cstring) -> c.int ---
	wgetstr :: proc(win: WINDOW, str: cstring) -> c.int ---
	mvgetstr :: proc(y,x: c.int, str: cstring) -> c.int ---
	mvwgetstr :: proc(win: WINDOW, y,x: c.int, str: cstring) -> c.int ---

	getnstr :: proc(str: cstring, n: c.int) -> c.int ---
	wgetnstr :: proc(win: WINDOW, str: cstring, n: c.int) -> c.int ---
	mvgetnstr :: proc(y, x: c.int, str: cstring, n: c.int) -> c.int ---
	mvwgetnstr :: proc(win: WINDOW, y,x: c.int, str: cstring, n: c.int) -> c.int ---
}
