package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
	curses_version :: proc() -> cstring ---
	use_extended_names :: proc(bf: c.bool) -> c.int ---
}
