package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
    overlay :: proc(srcwin, dstwin: WINDOW) -> c.int ---
    overwrite :: proc(srcwin, dstwin: WINDOW) -> c.int ---
    copywin :: proc(srcwin, dstwin: WINDOW, sminrow, smincol, dminrow, dmincol, dmaxrow, dmaxcol, overlay: c.int) -> c.int ---
}
