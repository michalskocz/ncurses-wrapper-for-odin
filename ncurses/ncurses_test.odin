package ncurses

import "core:testing"

T :: ^testing.T

@(test)
init_test :: proc(t: T) {
	win := initscr()
	testing.expect(t, win == stdscr)
	testing.expect(t, win !=nil)

	err: int

	err = printw("test: %d", 4)
	testing.expect(t, err == OK)
	err = mvprintw(1, 0 ,"test: %d", 4)

	win2 := newwin(1, 10, 2, 0)
	testing.expect(t, win2 != nil)
	testing.expect(t, win2 != stdscr)

	err = wprintw(win2, "t")
	testing.expect(t, err == OK)
	err = mvwprintw(win, 0, 0, "t")
	testing.expect(t, err == OK)

	err = delwin(win2)
	testing.expect(t, err == OK)

	err = endwin()
	testing.expect(t, err == OK)
}
