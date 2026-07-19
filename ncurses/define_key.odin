package ncurses

import "core:c"

foreign import lib "system:ncurses"

@(default_calling_convention="c")
foreign lib {
   	define_key :: proc(definition: cstring, key_code: c.int) -> c.int ---
}
