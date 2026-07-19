package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    curses_trace :: proc(trace_mask: c.uint) -> c.uint ---

    _tracef :: proc(format: cstring, #c_vararg args: ..any) ---

    _traceattr :: proc(attr: attr_t) -> cstring ---
    _traceattr2 :: proc(buffer: c.int, ch: chtype) -> cstring ---
    _tracecchar_t :: proc(string: cchar_t_ptr) -> cstring ---
    _tracecchar_t2 :: proc(buffer: c.int, string: cchar_t_ptr) -> cstring ---
    _tracechar :: proc(c: c.int) -> cstring ---
    _tracechtype :: proc(ch: chtype) -> cstring ---
    _tracechtype2 :: proc(buffer: c.int, ch: chtype) -> cstring ---

    _tracedump :: proc(label: cstring, win: WINDOW) ---
    _nc_tracebits :: proc() -> cstring ---
    _tracemouse :: proc(event: [^]MEVENT) -> cstring ---

    /* deprecated */
    trace :: proc(trace_mask: c.uint) ---
}
