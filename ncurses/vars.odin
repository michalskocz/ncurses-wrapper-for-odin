package ncurses

foreign import lib "system:ncurses"

foreign lib {
	stdscr: WINDOW
}
