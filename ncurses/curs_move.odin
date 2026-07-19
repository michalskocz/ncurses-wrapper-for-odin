package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_move.3x.html
foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
	move :: proc(x: c.int, y: c.int) -> c.int ---
	wmove :: proc(win: WINDOW, y: c.int, x: c.int) -> c.int ---
}
