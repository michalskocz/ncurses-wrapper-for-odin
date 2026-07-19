package ncurses

import "core:c"

foreign import lib "system:ncurses"

foreign lib {
    PC: c.char
    UP: cstring
    BC: cstring
    ospeed: c.short
}

@(default_calling_convention="c")
foreign lib {
    tgetent :: proc(bp: cstring, name: cstring) -> c.int ---
    tgetflag :: proc(id: cstring) -> c.int ---
    tgetnum :: proc(id: cstring) -> c.int ---
    tgetstr :: proc(id: cstring, sbuf: ^cstring) -> cstring ---
    tgoto :: proc(cap: cstring, col, row: c.int) -> cstring ---

}
