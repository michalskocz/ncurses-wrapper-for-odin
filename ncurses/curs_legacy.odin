package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	getattrs :: proc(win: WINDOW) -> c.int ---

	getbegx :: proc(win: WINDOW) -> c.int ---
	getbegy :: proc(win: WINDOW) -> c.int ---

	getcurx :: proc(win: WINDOW) -> c.int ---
	getcury :: proc(win: WINDOW) -> c.int ---

	getmaxx :: proc(win: WINDOW) -> c.int ---
	getmaxy :: proc(win: WINDOW) -> c.int ---

	getparx :: proc(win: WINDOW) -> c.int ---
	getpary :: proc(win: WINDOW) -> c.int ---
}
