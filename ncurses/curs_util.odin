package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	unctrl :: proc(ch: chtype) -> cstring ---
	wunctrl :: proc(wch: [^]cchar_t) -> [^]c.wchar_t ---

	keyname :: proc(c: c.int) -> cstring ---
	key_name :: proc(wc: c.wchar_t) -> cstring ---

	filter :: proc() ---
	nofilter :: proc() ---

	use_env :: proc(bf: bool) ---
	use_tioctl :: proc(bf: bool) ---

	putwin :: proc(win: WINDOW, filep: [^]c.FILE) -> c.int ---
	getwin :: proc(filep: [^]c.FILE) -> WINDOW ---

	delay_output :: proc(ms: c.int) -> c.int ---
	flushinp :: proc() -> c.int ---
}
