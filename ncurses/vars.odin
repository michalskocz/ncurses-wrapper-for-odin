package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
	stdscr: WINDOW

	cur_term: TERMINAL

	@(link_name="acs_map")
    acs_map_base: chtype

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

acs_map: [^]chtype = ([^]chtype)(&acs_map_base)
