package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    slk_init :: proc(fmt: c.int) -> c.int ---

    slk_set :: proc(labnum: c.int, label: cstring, align: c.int) -> c.int ---
    slk_wset :: proc(labnum: c.int, label: [^]c.wchar_t, align: c.int) -> c.int ---

    slk_label :: proc(labnum: c.int) -> cstring ---

    slk_refresh :: proc() -> c.int ---
    slk_noutrefresh :: proc() -> c.int ---
    slk_clear :: proc() -> c.int ---
    slk_restore :: proc() -> c.int ---
    slk_touch :: proc() -> c.int ---

    slk_attron :: proc(attrs: chtype) -> c.int ---
    slk_attroff :: proc(attrs: chtype) -> c.int ---
    slk_attrset :: proc(attrs: chtype) -> c.int ---
    slk_attr_on :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
    slk_attr_off :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
    slk_attr_set :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

    /* extension */
    slk_attr :: proc() -> attr_t ---

    slk_color :: proc(pair: c.short) -> c.int ---
    /* extension */
    extended_slk_color :: proc(pair: c.int) -> c.int ---
}
