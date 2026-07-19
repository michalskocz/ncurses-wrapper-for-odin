package ncurses

import "core:c"

NCURSES_CAST :: proc "contextless" ($T: typeid, val: $U) -> T  {
	// Original: #define NCURSES_CAST(type,value) (type)(value)
	return T(val)
}


NCURSES_BITS :: proc "contextless" (mask: $U, shift: c.uint32_t) -> chtype  {
	return NCURSES_CAST(chtype, mask) << (shift + NCURSES_ATTR_SHIFT)
}


foreign import lib "system:ncurses"

foreign lib {
	@(link_name="acs_map")
    acs_map_base: chtype
}

acs_map: [^]chtype = ([^]chtype)(&acs_map_base)

NCURSES_ACS :: proc "contextless" (c: u8) -> chtype {
    return acs_map[c]
}

/* VT100 symbols begin here */
ACS_ULCORNER :: proc "contextless" () -> chtype { return NCURSES_ACS('l') } /* upper left corner */
ACS_LLCORNER :: proc "contextless" () -> chtype { return NCURSES_ACS('m') } /* lower left corner */
ACS_URCORNER :: proc "contextless" () -> chtype { return NCURSES_ACS('k') } /* upper right corner */
ACS_LRCORNER :: proc "contextless" () -> chtype { return NCURSES_ACS('j') } /* lower right corner */
ACS_LTEE     :: proc "contextless" () -> chtype { return NCURSES_ACS('t') } /* tee pointing right */
ACS_RTEE     :: proc "contextless" () -> chtype { return NCURSES_ACS('u') } /* tee pointing left */
ACS_BTEE     :: proc "contextless" () -> chtype { return NCURSES_ACS('v') } /* tee pointing up */
ACS_TTEE     :: proc "contextless" () -> chtype { return NCURSES_ACS('w') } /* tee pointing down */
ACS_HLINE    :: proc "contextless" () -> chtype { return NCURSES_ACS('q') } /* horizontal line */
ACS_VLINE    :: proc "contextless" () -> chtype { return NCURSES_ACS('x') } /* vertical line */
ACS_PLUS     :: proc "contextless" () -> chtype { return NCURSES_ACS('n') } /* large plus or crossover */
ACS_S1       :: proc "contextless" () -> chtype { return NCURSES_ACS('o') } /* scan line 1 */
ACS_S9       :: proc "contextless" () -> chtype { return NCURSES_ACS('s') } /* scan line 9 */
ACS_DIAMOND  :: proc "contextless" () -> chtype { return NCURSES_ACS('`') } /* diamond */
ACS_CKBOARD  :: proc "contextless" () -> chtype { return NCURSES_ACS('a') } /* checker board (stipple) */
ACS_DEGREE   :: proc "contextless" () -> chtype { return NCURSES_ACS('f') } /* degree symbol */
ACS_PLMINUS  :: proc "contextless" () -> chtype { return NCURSES_ACS('g') } /* plus/minus */
ACS_BULLET   :: proc "contextless" () -> chtype { return NCURSES_ACS('~') } /* bullet */

/* Teletype 5410v1 symbols begin here */
ACS_LARROW   :: proc "contextless" () -> chtype { return NCURSES_ACS(',') } /* arrow pointing left */
ACS_RARROW   :: proc "contextless" () -> chtype { return NCURSES_ACS('+') } /* arrow pointing right */
ACS_DARROW   :: proc "contextless" () -> chtype { return NCURSES_ACS('.') } /* arrow pointing down */
ACS_UARROW   :: proc "contextless" () -> chtype { return NCURSES_ACS('-') } /* arrow pointing up */
ACS_BOARD    :: proc "contextless" () -> chtype { return NCURSES_ACS('h') } /* board of squares */
ACS_LANTERN  :: proc "contextless" () -> chtype { return NCURSES_ACS('i') } /* lantern symbol */
ACS_BLOCK    :: proc "contextless" () -> chtype { return NCURSES_ACS('0') } /* solid square block */

/* These aren't documented, but a lot of System Vs have them anyway */
ACS_S3       :: proc "contextless" () -> chtype { return NCURSES_ACS('p') } /* scan line 3 */
ACS_S7       :: proc "contextless" () -> chtype { return NCURSES_ACS('r') } /* scan line 7 */
ACS_LEQUAL   :: proc "contextless" () -> chtype { return NCURSES_ACS('y') } /* less/equal */
ACS_GEQUAL   :: proc "contextless" () -> chtype { return NCURSES_ACS('z') } /* greater/equal */
ACS_PI       :: proc "contextless" () -> chtype { return NCURSES_ACS('{') } /* Pi */
ACS_NEQUAL   :: proc "contextless" () -> chtype { return NCURSES_ACS('|') } /* not equal */
ACS_STERLING :: proc "contextless" () -> chtype { return NCURSES_ACS('}') } /* UK pound sign */

ACS_BSSB     :: proc "contextless" () -> chtype { return ACS_ULCORNER() }
ACS_SSBB     :: proc "contextless" () -> chtype { return ACS_LLCORNER() }
ACS_BBSS     :: proc "contextless" () -> chtype { return ACS_URCORNER() }
ACS_SBBS     :: proc "contextless" () -> chtype { return ACS_LRCORNER() }
ACS_SBSS     :: proc "contextless" () -> chtype { return ACS_RTEE() }
ACS_SSSB     :: proc "contextless" () -> chtype { return ACS_LTEE() }
ACS_SSBS     :: proc "contextless" () -> chtype { return ACS_BTEE() }
ACS_BSSS     :: proc "contextless" () -> chtype { return ACS_TTEE() }
ACS_BSBS     :: proc "contextless" () -> chtype { return ACS_HLINE() }
ACS_SBSB     :: proc "contextless" () -> chtype { return ACS_VLINE() }
ACS_SSSS     :: proc "contextless" () -> chtype { return ACS_PLUS() }
