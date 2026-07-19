package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	stdscr: WINDOW

	cur_term: TERMINAL

    boolnames:  [^]cstring
    boolcodes:  [^]cstring
    boolfnames: [^]cstring
    numnames:   [^]cstring
    numcodes:   [^]cstring
    numfnames:  [^]cstring
    strnames:   [^]cstring
    strcodes:   [^]cstring
    strfnames:  [^]cstring

    PC: c.char
    UP: cstring
    BC: cstring
    ospeed: c.short
}
