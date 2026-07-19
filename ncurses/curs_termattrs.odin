package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    baudrate :: proc() -> c.int ---
    erasechar :: proc() -> c.char ---
    erasewchar :: proc(wc: [^]c.wchar_t) -> c.int ---
    has_ic :: proc() -> c.bool ---
    has_il :: proc() -> c.bool ---
    killchar :: proc() -> c.char ---
    killwchar :: proc(wc: [^]c.wchar_t) -> c.int ---
    longname :: proc() -> cstring ---
    term_attrs :: proc() -> attr_t ---
    termattrs :: proc() -> chtype ---
    termname :: proc() -> cstring ---
}
