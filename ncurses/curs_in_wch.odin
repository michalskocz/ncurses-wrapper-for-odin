package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	in_wch :: proc(wch: [^]cchar_t) -> c.int ---
	win_wch :: proc(win: WINDOW, wch: [^]cchar_t) -> c.int ---
	mvin_wch :: proc(win: WINDOW, y, x: c.int, wch: [^]cchar_t) -> c.int ---
}
