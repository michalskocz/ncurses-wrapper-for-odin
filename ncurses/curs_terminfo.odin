package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    setupterm :: proc(term: cstring, filedes: c.int, errret: [^]c.int) -> c.int ---
    set_curterm :: proc(nterm: TERMINAL) -> TERMINAL ---
    del_curterm :: proc(oterm: TERMINAL) -> c.int ---
    restartterm :: proc(term: cstring, filedes: c.int, errret: [^]c.int) -> c.int ---

    tparm :: proc(str: cstring, #c_vararg args: ..any) -> cstring ---

    tputs :: proc(str: cstring, affcnt: c.int, putc: proc "c" (c.int) -> c.int) -> c.int ---
    putp :: proc(str: cstring) -> c.int ---

    vidputs :: proc(attrs: chtype, putc: proc "c" (c.int) -> c.int) -> c.int ---
    vidattr :: proc(attrs: chtype) -> c.int ---
    vid_puts :: proc(attrs: attr_t, pair: c.short, opts: rawptr, putc: proc "c" (c.int) -> c.int) -> c.int ---
    vid_attr :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

    tigetflag :: proc(cap_code: cstring) -> c.int ---
    tigetnum :: proc(cap_code: cstring) -> c.int ---
    tigetstr :: proc(cap_code: cstring) -> cstring ---

    tiparm :: proc(str: cstring, #c_vararg args: ..any) -> cstring ---

    /* extensions */
    tiparm_s :: proc(expected: c.int, mask: c.int, str: cstring, #c_vararg args: ..any) -> cstring ---
    tiscan_s :: proc(expected: [^]c.int, mask: [^]c.int, str: cstring) -> c.int ---

    /* deprecated */
    setterm :: proc(term: cstring) -> c.int ---
}
