package ncurses

import "core:c"


// Description: https://invisible-island.net/ncurses/man/curs_color.3x.html
foreign import lib "system:ncurses"



COLOR_BLACK :: 0
COLOR_RED :: 1
COLOR_GREEN :: 2
COLOR_YELLOW :: 3
COLOR_BLUE :: 4
COLOR_MAGENTA :: 5

@(private="file")
const_a_color := NCURSES_BITS((u32(1) <<8) - u32(1), 0)

A_COLOR :: proc() -> chtype {
	return const_a_color
}
// NCURSES_BITS(u32((u32(1)<<8) - u32(1)), 0)
/*
A_COLOR - NCURSES_BITS( ((1U) << 8) - 1U , 0 )
NCURSES_BITS(mask,shift) - ( NCURSES_CAST(chtype,(mask)) << ((shift) + NCURSES_ATTR_SHIFT) )
*/


@(default_calling_convention="c")
foreign lib {
	start_color :: proc() -> c.int ---

	has_colors :: proc() -> c.bool ---
	can_change_color :: proc() -> c.bool ---

	init_pair :: proc(pair: c.short, f: c.short, b: c.short) -> c.int ---
	init_color :: proc(color: c.short, r: c.short, g: c.short, b: c.short) -> c.int ---
	init_extended_pair :: proc(pair: c.int, f: c.int, b: c.int) -> c.int ---
	init_extended_color :: proc(color: c.int, r: c.int, g: c.int, b: c.int) -> c.int ---

	color_content :: proc(color: c.short, f: [^]c.short, g: [^]c.short, b: [^]c.short) -> c.int ---
	pair_content :: proc(pair: c.short, f: [^]c.short, b: [^]c.short) -> c.int ---

	// f, g, b - pointer to c int
	extended_color_content :: proc(color: c.short, f: [^]c.int, g: [^]c.int, b: [^]c.int) -> c.int ---
	extended_pair_content :: proc(pair: c.short, f: [^]c.int, b: [^]c.int) -> c.int ---

	reset_color_pairs :: proc() ---

	COLOR_PAIR :: proc(n: c.int) -> c.int ---
	PAIR_NUMBER :: proc(attr: c.int) -> c.int ---
}
