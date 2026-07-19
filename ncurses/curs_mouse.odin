package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    has_mouse :: proc() -> c.bool ---

    mousemask :: proc(new_mask: mmask_t, old_mask: [^]mmask_t) -> mmask_t ---

    getmouse :: proc(event: [^]MEVENT) -> c.int ---
    ungetmouse :: proc(event: [^]MEVENT) -> c.int ---

    wenclose :: proc(win: WINDOW, y, x: c.int) -> c.bool ---

    mouse_trafo :: proc(pY, pX: [^]c.int, to_screen: c.bool) -> c.bool ---
    wmouse_trafo :: proc(win: WINDOW, pY, pX: [^]c.int, to_screen: c.bool) -> c.bool ---

    mouseinterval :: proc(erval: c.int) -> c.int ---
}
