package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    attr_get :: proc(attrs: [^]attr_t, pair: [^]c.short, opts: rawptr) -> c.int ---
    wattr_get :: proc(win: WINDOW, attrs: [^]attr_t, pair: [^]c.short, opts: rawptr) -> c.int ---
    attr_set :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---
    wattr_set :: proc(win: WINDOW, attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

    attr_off :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
    wattr_off :: proc(win: WINDOW, attrs: attr_t, opts: rawptr) -> c.int ---
    attr_on :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
    wattr_on :: proc(win: WINDOW, attrs: attr_t, opts: rawptr) -> c.int ---

    attroff :: proc(attrs: c.int) -> c.int ---
    wattroff :: proc(win: WINDOW, attrs: c.int) -> c.int ---
    attron :: proc(attrs: c.int) -> c.int ---
    wattron :: proc(win: WINDOW, attrs: c.int) -> c.int ---
    attrset :: proc(attrs: c.int) -> c.int ---
    wattrset :: proc(win: WINDOW, attrs: c.int) -> c.int ---

    chgat :: proc(n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
    wchgat :: proc(win: WINDOW, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
    mvchgat :: proc(y, x: c.int, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
    mvwchgat :: proc(win: WINDOW, y, x: c.int, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---

    color_set :: proc(pair: c.short, opts: rawptr) -> c.int ---
    wcolor_set :: proc(win: WINDOW, pair: c.short, opts: rawptr) -> c.int ---

    standend :: proc() -> c.int ---
    wstandend :: proc(win: WINDOW) -> c.int ---
    standout :: proc() -> c.int ---
    wstandout :: proc(win: WINDOW) -> c.int ---
}
