package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    is_cleared :: proc(win: WINDOW) -> c.bool ---
    is_idcok :: proc(win: WINDOW) -> c.bool ---
    is_idlok :: proc(win: WINDOW) -> c.bool ---
    is_immedok :: proc(win: WINDOW) -> c.bool ---
    is_keypad :: proc(win: WINDOW) -> c.bool ---
    is_leaveok :: proc(win: WINDOW) -> c.bool ---
    is_nodelay :: proc(win: WINDOW) -> c.bool ---
    is_notimeout :: proc(win: WINDOW) -> c.bool ---
    is_pad :: proc(win: WINDOW) -> c.bool ---
    is_scrollok :: proc(win: WINDOW) -> c.bool ---
    is_subwin :: proc(win: WINDOW) -> c.bool ---
    is_syncok :: proc(win: WINDOW) -> c.bool ---

    wgetparent :: proc(win: WINDOW) -> WINDOW ---
    wgetdelay :: proc(win: WINDOW) -> c.int ---
    wgetscrreg :: proc(win: WINDOW, top, bottom: [^]c.int) -> c.int ---
}
