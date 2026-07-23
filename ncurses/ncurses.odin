package ncurses

import "base:runtime"

import "core:c"
import "core:strings"
import "core:unicode/utf8"
import "core:fmt"
import "core:unicode/utf16"
import "core:os"
foreign import lib "system:ncurses"


_WINDOW :: [^]_win_st
WINDOW :: ^_win_st
SCREEN :: rawptr
TERMINAL :: rawptr

pdat :: struct {
    _pad_y, _pad_x:           ncurses_size_t,
    _pad_top, _pad_left:      ncurses_size_t,
    _pad_bottom, _pad_right:  ncurses_size_t,
}

_win_st :: struct {
    _cury, _curx: ncurses_size_t, /* current cursor position */
    _maxy, _maxx: ncurses_size_t, /* maximums of x and y, NOT window size */
    _begy, _begx: ncurses_size_t, /* screen coords of upper-left-hand corner */

    _flags:       c.short,        /* window state flags */

    _attrs:       attr_t,         /* current attribute for non-space character */
    _bkgd:        chtype,         /* current background char/attribute pair */

    _notimeout:   c.bool,         /* no time out on function-key entry? */
    _clear:       c.bool,         /* consider all data in the window invalid? */
    _leaveok:     c.bool,         /* OK to not reset cursor on exit? */
    _scroll:      c.bool,         /* OK to scroll this window? */
    _idlok:       c.bool,         /* OK to use insert/delete line? */
    _idcok:       c.bool,         /* OK to use insert/delete char? */
    _immed:       c.bool,         /* window in immed mode? (not yet used) */
    _sync:        c.bool,         /* window in sync mode? */
    _use_keypad:  c.bool,         /* process function keys into KEY_ symbols? */
    _delay:       c.int,          /* 0 = nodelay, <0 = blocking, >0 = delay */

    _line:        rawptr,         /* the actual line data (struct ldat *) */

    _regtop:      ncurses_size_t, /* top line of scrolling region */
    _regbottom:   ncurses_size_t, /* bottom line of scrolling region */

    _parx:        c.int,          /* x coordinate of this window in parent */
    _pary:        c.int,          /* y coordinate of this window in parent */
    _parent:      _WINDOW,         /* pointer to parent if a sub-window */

    _pad:         pdat,           /* used only if this is a pad */

    _yoffset:     ncurses_size_t, /* real begy is _begy + _yoffset */

    // Assuming NCURSES_WIDECHAR is enabled
    _bkgrnd:      cchar_t,        /* current background char/attribute pair */
    _color:       c.int,          /* current color-pair for non-space character */
}

chtype :: distinct c.uint32_t
mmask_t :: distinct c.uint32_t
attr_t :: distinct chtype
ncurses_size_t :: distinct c.short

CCHARW_MAX :: 5
NCURSES_EXT_COLORS :: 0250216

cchar_t :: struct {
    attr:      attr_t,
    chars:     [CCHARW_MAX]c.wchar_t,
    ext_color: c.int,
}

MEVENT :: struct {
    id:     c.short,
    x:      c.int,
    y:      c.int,
    z:      c.int,
    bstate: mmask_t,
}

@(default_calling_convention="c")
foreign lib {
	stdscr: _WINDOW

	cur_term: TERMINAL

	@(link_name="acs_map")
    acs_map_base: chtype

    boolnames:  [^]cstring
    boolcodes:  [^]cstring
    boolfnames: [^]cstring
    numnames:   [^]cstring
    numcodes:   [^]cstring
    numfnames:  [^]cstring
    strnames:   [^]cstring
    strcodes:   [^]cstring
    strfnames:  [^]cstring

    PC: c.char
    UP: cstring
    BC: cstring
    ospeed: c.short
}

acs_map: [^]chtype = ([^]chtype)(&acs_map_base)



NCURSES_CAST :: proc "contextless" ($T: typeid, val: $U) -> T  {
	// Original: #define NCURSES_CAST(type,value) (type)(value)
	return T(val)
}


NCURSES_BITS :: proc "contextless" (mask: $U, shift: c.uint32_t) -> chtype  {
	return NCURSES_CAST(chtype, mask) << (shift + NCURSES_ATTR_SHIFT)
}



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

A_NORMAL :: proc "contextless" () -> chtype { return chtype(1) - chtype(1) }



A_ATTRIBUTES :: proc "contextless" () -> chtype { return NCURSES_BITS(~(chtype(1) - chtype(1)), 0) }
A_CHARTEXT :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 0) - 1 }
A_STANDOUT :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 8) }
A_UNDERLINE :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 9) }
A_REVERSE :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 10) }
A_BLINK :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 11) }
A_DIM :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 12) }
A_BOLD :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 13) }
A_ALTCHARSET :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 14) }
A_INVIS :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 15) }
A_PROTECT :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 16) }
A_HORIZONTAL :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 17) }
A_LEFT :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 18) }
A_LOW :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 19) }
A_RIGHT :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 20) }
A_TOP :: proc "contextless" () -> chtype {return NCURSES_BITS(1, 21) }
A_VERTICAL :: proc "contextless" () -> chtype { return NCURSES_BITS(1, 22) }


KEY_CODE_YES :: 0o400
KEY_MIN :: 0o401
KEY_BREAK :: 0o401
KEY_SRESET :: 0o530
KEY_RESET :: 0o531
KEY_DOWN :: 0o402
KEY_UP :: 0o403
KEY_LEFT :: 0o404
KEY_RIGHT :: 0o405
KEY_HOME :: 0o406
KEY_BACKSPACE :: 0o407
KEY_F0 :: 0o410
KEY_F :: proc(n: int) -> int { return KEY_F0 + n }
KEY_DL :: 0o510
KEY_IL :: 0o511
KEY_DC :: 0o512
KEY_IC :: 0o513
KEY_EIC :: 0o514
KEY_CLEAR :: 0o515
KEY_EOS :: 0o516
KEY_EOL :: 0o517
KEY_SF :: 0o520
KEY_SR :: 0o521
KEY_NPAGE :: 0o522
KEY_PPAGE :: 0o523
KEY_STAB :: 0o524
KEY_CTAB :: 0o525
KEY_CATAB :: 0o526
KEY_ENTER :: 0o527
KEY_PRINT :: 0o532
KEY_LL :: 0o533
KEY_A1 :: 0o534
KEY_A3 :: 0o535
KEY_B2 :: 0o536
KEY_C1 :: 0o537
KEY_C3 :: 0o540
KEY_BTAB :: 0o541
KEY_BEG :: 0o542
KEY_CANCEL :: 0o543
KEY_CLOSE :: 0o544
KEY_COMMAND :: 0o545
KEY_COPY :: 0o546
KEY_CREATE :: 0o547
KEY_END :: 0o550
KEY_EXIT :: 0o551
KEY_FIND :: 0o552
KEY_HELP :: 0o553
KEY_MARK :: 0o554
KEY_MESSAGE :: 0o555
KEY_MOVE :: 0o556
KEY_NEXT :: 0o557
KEY_OPEN :: 0o560
KEY_OPTIONS :: 0o561
KEY_PREVIOUS :: 0o562
KEY_REDO :: 0o563
KEY_REFERENCE :: 0o564
KEY_REFRESH :: 0o565
KEY_REPLACE :: 0o566
KEY_RESTART :: 0o567
KEY_RESUME :: 0o570
KEY_SAVE :: 0o571
KEY_SBEG :: 0o572
KEY_SCANCEL :: 0o573
KEY_SCOMMAND :: 0o574
KEY_SCOPY :: 0o575
KEY_SCREATE :: 0o576
KEY_SDC :: 0o577
KEY_SDL :: 0o600
KEY_SELECT :: 0o601
KEY_SEND :: 0o602
KEY_SEOL :: 0o603
KEY_SEXIT :: 0o604
KEY_SFIND :: 0o605
KEY_SHELP :: 0o606
KEY_SHOME :: 0o607
KEY_SIC :: 0o610
KEY_SLEFT :: 0o611
KEY_SMESSAGE :: 0o612
KEY_SMOVE :: 0o613
KEY_SNEXT :: 0o614
KEY_SOPTIONS :: 0o615
KEY_SPREVIOUS :: 0o616
KEY_SPRINT :: 0o617
KEY_SREDO :: 0o620
KEY_SREPLACE :: 0o621
KEY_SRIGHT :: 0o622
KEY_SRSUME :: 0o623
KEY_SSAVE :: 0o624
KEY_SSUSPEND :: 0o625
KEY_SUNDO :: 0o626
KEY_SUSPEND :: 0o627
KEY_UNDO :: 0o630
KEY_MOUSE :: 0o631
KEY_RESIZE :: 0o632
KEY_MAX :: 0o777

NCURSES_VERSION_MAJOR :: 6
NCURSES_VERSION_MINOR :: 5
NCURSES_VERSION_PATCH :: 20250216
NCURSES_VERSION :: "6.5"

NCURSES_MOUSE_VERSION :: 2


NCURSES_ATTR_SHIFT :: 8

COLOR_BLACK :: 0
COLOR_RED :: 1
COLOR_GREEN :: 2
COLOR_YELLOW :: 3
COLOR_BLUE :: 4
COLOR_MAGENTA :: 5
COLOR_CYAN :: 6
COLOR_WHITE :: 7

@(private="file")
const_a_color := NCURSES_BITS((u32(1) <<8) - u32(1), 0)

A_COLOR :: proc() -> chtype {
	return const_a_color
}


ERR :: -1
OK :: 0

_SUBWIN  :: 0x01
_ENDLINE :: 0x02
_FULLWIN :: 0x04
_SCROLLWIN :: 0x8
_ISPAD :: 0x10
_HASMOVED :: 0x20
_WRAPPED :: 0x40


 _NOCHANGE :: -1
_NEWINDEX :: -1


getmaxyx :: proc(win: WINDOW) -> (y: int, x: int) {
	if win != nil {
		y = getmaxy(win)
		x = getmaxx(win)
	}
	return y, x
}

getyx :: proc(win: WINDOW) -> (y: int, x: int)  {
	if win != nil {
		y = getcury(win)
		x = getcurx(win)
	}

	return y, x
}


getbegyx :: proc(win: WINDOW) -> (y: int, x: int) {
	// if y != nil && x != nil {
	// 	y^ = getbegy(win)
	// 	x^ = getbegx(win)
	// }

	if win != nil {
		y = getbegy(win)
		x = getbegx(win)
	}

	return y, x
}


getparyx :: proc(win: WINDOW) -> (y: int, x: int)  {
	if win != nil {
		y = getpary(win)
		x = getparx(win)
	}

	return y, x
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="alloc_pair")
	_alloc_pair :: proc(fg, bg: c.int) -> c.int ---
	@(link_name="find_pair")
    _find_pair :: proc(fg, bg: c.int) -> c.int ---
    @(link_name="free_pair")
    _free_pair :: proc(pair: c.int) -> c.int ---
}

alloc_pair :: proc(fg, bg: int) -> int {
	return int(_alloc_pair(c.int(fg), c.int(bg)))
}

find_pair :: proc(fg, bg: int) -> int {
	return int(_find_pair(c.int(fg), c.int(bg)))
}

free_pair :: proc(pair: int) -> int {
	return int(_free_pair(c.int(pair)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="add_wchstr")
    _add_wchstr :: proc(wchstr: [^]cchar_t) -> c.int ---
    @(link_name="wadd_wchstr")
    _wadd_wchstr :: proc(win: _WINDOW, wchstr: [^]cchar_t) -> c.int ---
    @(link_name="mvadd_wchstr")
    _mvadd_wchstr :: proc(y, x: c.int, wchstr: [^]cchar_t) -> c.int ---
    @(link_name="mvwadd_wchstr")
    _mvwadd_wchstr :: proc(win: _WINDOW, y, x: c.int, wchstr: [^]cchar_t) -> c.int ---

    @(link_name="add_wchnstr")
    _add_wchnstr :: proc(wchstr: [^]cchar_t, n: c.int) -> c.int ---
    @(link_name="wadd_wchnstr")
    _wadd_wchnstr :: proc(win: _WINDOW, wchstr: [^]cchar_t, n: c.int) -> c.int ---
    @(link_name="mvadd_wchnstr")
    _mvadd_wchnstr :: proc(y, x: c.int, wchstr: [^]cchar_t, n: c.int) -> c.int ---
    @(link_name="mvwadd_wchnstr")
    _mvwadd_wchnstr :: proc(win: _WINDOW, y, x: c.int, wchstr: [^]cchar_t, n: c.int) -> c.int ---
}

add_wchstr :: proc(wchstr: [^]cchar_t) -> int {
	return int(_add_wchstr(wchstr))
}

wadd_wchstr :: proc(win: WINDOW, wchstr: [^]cchar_t) -> int {
	return int(_wadd_wchstr(win, wchstr))
}

mvadd_wchstr :: proc(y, x: int, wchstr: [^]cchar_t) -> int {
	return int(_mvadd_wchstr(c.int(y), c.int(x), wchstr))
}

mvwadd_wchstr :: proc(win: WINDOW, y, x: int, wchstr: [^]cchar_t) -> int {
	return int(_mvwadd_wchstr(win, c.int(y), c.int(x), wchstr))
}

add_wchnstr :: proc(wchstr: [^]cchar_t, n: int) -> int {
	return int(_add_wchnstr(wchstr, c.int(n)))
}

wadd_wchnstr :: proc(win: WINDOW, wchstr: [^]cchar_t, n: int) -> int {
	return int(_wadd_wchnstr(win, wchstr, c.int(n)))
}

mvadd_wchnstr :: proc(y, x: int, wchstr: [^]cchar_t, n: int) -> int {
	return int(_mvadd_wchnstr(c.int(y), c.int(x), wchstr, c.int(n)))
}

mvwadd_wchnstr :: proc(win: WINDOW, y, x: int, wchstr: [^]cchar_t, n: int) -> int {
	return int(_mvwadd_wchnstr(win, c.int(y), c.int(x), wchstr, c.int(n)))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="addch")
	_addch :: proc(ch: chtype) -> c.int ---
	@(link_name="waddch")
	_waddch :: proc(win: _WINDOW, ch: chtype) -> c.int ---
	@(link_name="mvaddch")
	_mvaddch :: proc(y, x: c.int, ch: chtype) -> c.int ---
	@(link_name="mvwaddch")
	_mvwaddch :: proc(win: _WINDOW, y, x: c.int, ch: chtype) -> c.int ---

	@(link_name="echochar")
	_echochar :: proc(ch: chtype) -> c.int ---
	@(link_name="wechochar")
	_wechochar :: proc(win: _WINDOW, ch: chtype) -> c.int ---
}

addch :: proc(ch: chtype) -> int {
	return int(_addch(ch))
}

waddch :: proc(win: _WINDOW, ch: chtype) -> int {
	return int(_waddch(win, ch))
}

mvaddch :: proc(y, x: int, ch: chtype) -> int {
	return int(_mvaddch(c.int(y), c.int(x), ch))
}

mvwaddch :: proc(win: _WINDOW, y, x: int, ch: chtype) -> int {
	return int(_mvwaddch(win, c.int(y), c.int(x), ch))
}

echochar :: proc(ch: chtype) -> int {
	return int(_echochar(ch))
}

wechochar :: proc(win: _WINDOW, ch: chtype) -> int {
	return int(_wechochar(win, ch))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="addchstr")
	_addchstr :: proc(chstr: [^]chtype) -> c.int ---
	@(link_name="waddchstr")
	_waddchstr :: proc(win: _WINDOW, chstr: [^]chtype) -> c.int ---
	@(link_name="mvaddchstr")
	_mvaddchstr :: proc(y, x: c.int, chstr: [^]chtype) -> c.int ---
	@(link_name="mvwaddchstr")
	_mvwaddchstr :: proc(win: _WINDOW, y, x: c.int, chstr: [^]chtype) -> c.int ---

	@(link_name="addchnstr")
	_addchnstr :: proc(chstr: [^]chtype, n: c.int) -> c.int ---
	@(link_name="waddchnstr")
	_waddchnstr :: proc(win: _WINDOW, chstr: [^]chtype, n: c.int) -> c.int ---
	@(link_name="mvaddchnstr")
	_mvaddchnstr :: proc(y, x: c.int, chstr: [^]chtype, n: c.int) -> c.int ---
	@(link_name="mvwaddchnstr")
	_mvwaddchnstr :: proc(win: _WINDOW, y, x: c.int, chstr: [^]chtype, n: c.int) -> c.int ---
}

addchstr :: proc(chstr: [^]chtype) -> int {
	return int(_addchstr(chstr))
}

waddchstr :: proc(win: _WINDOW, chstr: [^]chtype) -> int {
	return int(_waddchstr(win, chstr))
}

mvaddchstr :: proc(y, x: int, chstr: [^]chtype) -> int {
	return int(_mvaddchstr(c.int(y), c.int(x), chstr))
}

mvwaddchstr :: proc(win: _WINDOW, y, x: int, chstr: [^]chtype) -> int {
	return int(_mvwaddchstr(win, c.int(y), c.int(x), chstr))
}

addchnstr :: proc(chstr: [^]chtype, n: int) -> int {
	return int(_addchnstr(chstr, c.int(n)))
}

waddchnstr :: proc(win: _WINDOW, chstr: [^]chtype, n: int) -> int {
	return int(_waddchnstr(win, chstr, c.int(n)))
}

mvaddchnstr :: proc(y, x: int, chstr: [^]chtype, n: int) -> int {
	return int(_mvaddchnstr(c.int(y), c.int(x), chstr, c.int(n)))
}

mvwaddchnstr :: proc(win: _WINDOW, y, x: int, chstr: [^]chtype, n: int) -> int {
	return int(_mvwaddchnstr(win, c.int(y), c.int(x), chstr, c.int(n)))
}




@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="addstr")
	_addstr :: proc(str: cstring) -> c.int ---
	@(link_name="waddstr")
	_waddstr :: proc(win: _WINDOW, str: cstring) -> c.int ---
	@(link_name="mvaddstr")
	_mvaddstr :: proc(y, x: c.int, str: cstring) -> c.int ---
	@(link_name="mvwaddstr")
	_mvwaddstr :: proc(win: _WINDOW, y, x: c.int, str: cstring) -> c.int ---

	@(link_name="addnstr")
	_addnstr :: proc(str: cstring, n: c.int) -> c.int ---
	@(link_name="waddnstr")
	_waddnstr :: proc(win: _WINDOW, str: cstring, n: c.int) -> c.int ---
	@(link_name="mvaddnstr")
	_mvaddnstr :: proc(y, x: c.int, str: cstring, n: c.int) -> c.int ---
	@(link_name="mvwaddnstr")
	_mvwaddnstr :: proc(win: _WINDOW, y, x: c.int, str: cstring, n: c.int) -> c.int ---
}

addstr :: proc(str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_addstr(c_str))
}

waddstr :: proc(win: WINDOW, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_waddstr(win, c_str))
}

mvaddstr :: proc(y, x: int, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvaddstr(c.int(y), c.int(x), c_str))
}

mvwaddstr :: proc(win: WINDOW, y, x: int, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvwaddstr(win, c.int(y), c.int(x), c_str))
}

addnstr :: proc(str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_addnstr(c_str, c.int(n)))
}

waddnstr :: proc(win: WINDOW, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_waddnstr(win, c_str, c.int(n)))
}

mvaddnstr :: proc(y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvaddnstr(c.int(y), c.int(x), c_str, c.int(n)))
}

mvwaddnstr :: proc(win: WINDOW, y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvwaddnstr(win, c.int(y), c.int(x), c_str, c.int(n)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="addwstr")
	_addwstr :: proc(wstr: [^]c.wchar_t) -> c.int ---
	@(link_name="waddwstr")
	_waddwstr :: proc(win: _WINDOW, wstr: [^]c.wchar_t) -> c.int ---
	@(link_name="mvaddwstr")
	_mvaddwstr :: proc(y, x: c.int, wstr: [^]c.wchar_t) -> c.int ---
	@(link_name="mvwaddwstr")
	_mvwaddwstr :: proc(win: _WINDOW, y, x: c.int, wstr: [^]c.wchar_t) -> c.int ---

	@(link_name="addnwstr")
	_addnwstr :: proc(wstr: [^]c.wchar_t, n: c.int) -> c.int ---
	@(link_name="waddnwstr")
	_waddnwstr :: proc(win: _WINDOW, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
	@(link_name="mvaddnwstr")
	_mvaddnwstr :: proc(y, x: c.int, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
	@(link_name="mvwaddnwstr")
	_mvwaddnwstr :: proc(win: _WINDOW, y, x: c.int, wstr: [^]c.wchar_t, n: c.int) -> c.int ---
}



addwstr :: proc(str: string, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_addwstr(wstr))
}

waddwstr :: proc(win: WINDOW, str: string, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_waddwstr(win, wstr))
}

mvaddwstr :: proc(y, x: int, str: string, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_mvaddwstr(c.int(y), c.int(x), wstr))
}

mvwaddwstr :: proc(win: WINDOW, y, x: int, str: string, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_mvwaddwstr(win, c.int(y), c.int(x), wstr))
}

addnwstr :: proc(str: string, n: int, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_addnwstr(wstr, c.int(n)))
}

waddnwstr :: proc(win: WINDOW, str: string, n: int, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_waddnwstr(win, wstr, c.int(n)))
}

mvaddnwstr :: proc(y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_mvaddnwstr(c.int(y), c.int(x), wstr, c.int(n)))
}

mvwaddnwstr :: proc(win: WINDOW, y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(str, allocator)
	defer free(ptr, allocator)
	return int(_mvwaddnwstr(win, c.int(y), c.int(x), wstr, c.int(n)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="attr_get")
	_attr_get :: proc(attrs: [^]attr_t, pair: [^]c.short, opts: rawptr) -> c.int ---
	@(link_name="wattr_get")
	_wattr_get :: proc(win: _WINDOW, attrs: [^]attr_t, pair: [^]c.short, opts: rawptr) -> c.int ---
	@(link_name="attr_set")
	_attr_set :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---
	@(link_name="wattr_set")
	_wattr_set :: proc(win: _WINDOW, attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

	@(link_name="attr_off")
	_attr_off :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
	@(link_name="wattr_off")
	_wattr_off :: proc(win: _WINDOW, attrs: attr_t, opts: rawptr) -> c.int ---
	@(link_name="attr_on")
	_attr_on :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
	@(link_name="wattr_on")
	_wattr_on :: proc(win: _WINDOW, attrs: attr_t, opts: rawptr) -> c.int ---

	@(link_name="attroff")
	_attroff :: proc(attrs: c.int) -> c.int ---
	@(link_name="wattroff")
	_wattroff :: proc(win: _WINDOW, attrs: c.int) -> c.int ---
	@(link_name="attron")
	_attron :: proc(attrs: c.int) -> c.int ---
	@(link_name="wattron")
	_wattron :: proc(win: _WINDOW, attrs: c.int) -> c.int ---
	@(link_name="attrset")
	_attrset :: proc(attrs: c.int) -> c.int ---
	@(link_name="wattrset")
	_wattrset :: proc(win: _WINDOW, attrs: c.int) -> c.int ---

	@(link_name="chgat")
	_chgat :: proc(n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
	@(link_name="wchgat")
	_wchgat :: proc(win: _WINDOW, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
	@(link_name="mvchgat")
	_mvchgat :: proc(y, x: c.int, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---
	@(link_name="mvwchgat")
	_mvwchgat :: proc(win: _WINDOW, y, x: c.int, n: c.int, attr: attr_t, pair: c.short, opts: rawptr) -> c.int ---

	@(link_name="color_set")
	_color_set :: proc(pair: c.short, opts: rawptr) -> c.int ---
	@(link_name="wcolor_set")
	_wcolor_set :: proc(win: _WINDOW, pair: c.short, opts: rawptr) -> c.int ---

	@(link_name="standend")
	_standend :: proc() -> c.int ---
	@(link_name="wstandend")
	_wstandend :: proc(win: _WINDOW) -> c.int ---
	@(link_name="standout")
	_standout :: proc() -> c.int ---
	@(link_name="wstandout")
	_wstandout :: proc(win: _WINDOW) -> c.int ---
}

attr_get :: proc(attrs: [^]attr_t, pair: [^]i16, opts: rawptr) -> int {
	return int(_attr_get(attrs, convert_ptr(pair, c.short), opts))
}

wattr_get :: proc(win: WINDOW, attrs: [^]attr_t, pair: [^]i16, opts: rawptr) -> int {
	return int(_wattr_get(win, attrs, convert_ptr(pair, c.short), opts))
}

attr_set :: proc(attrs: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_attr_set(attrs, c.short(pair), opts))
}

wattr_set :: proc(win: WINDOW, attrs: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_wattr_set(win, attrs, c.short(pair), opts))
}

attr_off :: proc(attrs: attr_t, opts: rawptr) -> int {
	return int(_attr_off(attrs, opts))
}

wattr_off :: proc(win: WINDOW, attrs: attr_t, opts: rawptr) -> int {
	return int(_wattr_off(win, attrs, opts))
}

attr_on :: proc(attrs: attr_t, opts: rawptr) -> int {
	return int(_attr_on(attrs, opts))
}

wattr_on :: proc(win: WINDOW, attrs: attr_t, opts: rawptr) -> int {
	return int(_wattr_on(win, attrs, opts))
}

attroff :: proc(attrs: int) -> int {
	return int(_attroff(c.int(attrs)))
}

wattroff :: proc(win: WINDOW, attrs: int) -> int {
	return int(_wattroff(win, c.int(attrs)))
}

attron :: proc(attrs: int) -> int {
	return int(_attron(c.int(attrs)))
}

wattron :: proc(win: WINDOW, attrs: int) -> int {
	return int(_wattron(win, c.int(attrs)))
}

attrset :: proc(attrs: int) -> int {
	return int(_attrset(c.int(attrs)))
}

wattrset :: proc(win: WINDOW, attrs: int) -> int {
	return int(_wattrset(win, c.int(attrs)))
}

chgat :: proc(n: int, attr: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_chgat(c.int(n), attr, c.short(pair), opts))
}

wchgat :: proc(win: WINDOW, n: int, attr: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_wchgat(win, c.int(n), attr, c.short(pair), opts))
}

mvchgat :: proc(y, x, n: int, attr: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_mvchgat(c.int(y), c.int(x), c.int(n), attr, c.short(pair), opts))
}

mvwchgat :: proc(win: WINDOW, y, x, n: int, attr: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_mvwchgat(win, c.int(y), c.int(x), c.int(n), attr, c.short(pair), opts))
}

color_set :: proc(pair: i16, opts: rawptr) -> int {
	return int(_color_set(c.short(pair), opts))
}

wcolor_set :: proc(win: WINDOW, pair: i16, opts: rawptr) -> int {
	return int(_wcolor_set(win, c.short(pair), opts))
}

standend :: proc() -> int {
	return int(_standend())
}

wstandend :: proc(win: WINDOW) -> int {
	return int(_wstandend(win))
}

standout :: proc() -> int {
	return int(_standout())
}

wstandout :: proc(win: WINDOW) -> int {
	return int(_wstandout(win))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="beep")
	_beep :: proc() -> c.int ---
	@(link_name="flash")
	_flash :: proc() -> c.int ---
}

beep :: proc() -> int {
	return int(_beep())
}

flash :: proc() -> int {
	return int(_flash())
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="bkgd")
	_bkgd :: proc(ch: chtype) -> c.int ---
	@(link_name="wbkgd")
	_wbkgd :: proc(win: _WINDOW, ch: chtype) -> c.int ---

	@(link_name="bkgdset")
	_bkgdset :: proc(ch: chtype) ---
	@(link_name="wbkgdset")
	_wbkgdset :: proc(win: _WINDOW, ch: chtype) ---

	@(link_name="getbkgd")
	_getbkgd :: proc(win: _WINDOW) -> chtype ---
}

bkgd :: proc(ch: u32) -> int {
	return int(_bkgd(chtype(ch)))
}

wbkgd :: proc(win: WINDOW, ch: u32) -> int {
	return int(_wbkgd(win, chtype(ch)))
}

bkgdset :: proc(ch: u32) {
	_bkgdset(chtype(ch))
}

wbkgdset :: proc(win: WINDOW, ch: u32) {
	_wbkgdset(win, chtype(ch))
}

getbkgd :: proc(win: WINDOW) -> u32 {
	return u32(_getbkgd(win))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="bkgrnd")
	_bkgrnd :: proc(wch: [^]cchar_t) -> c.int ---
	@(link_name="wbkgrnd")
	_wbkgrnd :: proc(win: _WINDOW, wch: [^]cchar_t) -> c.int ---

	@(link_name="bkgrndset")
	_bkgrndset :: proc(wch: [^]cchar_t) ---
	@(link_name="wbkgrndset")
	_wbkgrndset :: proc(win: _WINDOW, wch: [^]cchar_t) ---

	@(link_name="getbkgrnd")
	_getbkgrnd :: proc(wch: [^]cchar_t) -> c.int ---
	@(link_name="wgetbkgrnd")
	_wgetbkgrnd :: proc(win: _WINDOW, wch: [^]cchar_t) -> c.int ---
}

bkgrnd :: proc(wch: [^]cchar_t) -> int {
	return int(_bkgrnd(wch))
}

wbkgrnd :: proc(win: WINDOW, wch: [^]cchar_t) -> int {
	return int(_wbkgrnd(win, wch))
}

bkgrndset :: proc(wch: [^]cchar_t) {
	_bkgrndset(wch)
}

wbkgrndset :: proc(win: WINDOW, wch: [^]cchar_t) {
	_wbkgrndset(win, wch)
}

getbkgrnd :: proc(wch: [^]cchar_t) -> int {
	return int(_getbkgrnd(wch))
}

wgetbkgrnd :: proc(win: WINDOW, wch: [^]cchar_t) -> int {
	return int(_wgetbkgrnd(win, wch))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="border")
	_border :: proc(ls, rs, ts, bs, tl, tr, bl, br: chtype) -> c.int ---
	@(link_name="wborder")
	_wborder :: proc(win: _WINDOW, ls, rs, ts, bs, tl, tr, bl, br: chtype) -> c.int ---

	@(link_name="box")
	_box :: proc(win: _WINDOW, verch, horch: chtype) -> c.int ---

	@(link_name="hline")
	_hline :: proc(ch: chtype, n: c.int) -> c.int ---
	@(link_name="whline")
	_whline :: proc(win: _WINDOW, ch: chtype, n: c.int) -> c.int ---
	@(link_name="mvhline")
	_mvhline :: proc(y, x: c.int, ch: chtype, n: c.int) -> c.int ---
	@(link_name="mvwhline")
	_mvwhline :: proc(win: _WINDOW, y, x: c.int, ch: chtype, n: c.int) -> c.int ---

	@(link_name="vline")
	_vline :: proc(ch: chtype, n: c.int) -> c.int ---
	@(link_name="wvline")
	_wvline :: proc(win: _WINDOW, ch: chtype, n: c.int) -> c.int ---
	@(link_name="mvvline")
	_mvvline :: proc(y, x: c.int, ch: chtype, n: c.int) -> c.int ---
	@(link_name="mvwvline")
	_mvwvline :: proc(win: _WINDOW, y, x: c.int, ch: chtype, n: c.int) -> c.int ---
}

border :: proc(ls, rs, ts, bs, tl, tr, bl, br: u32) -> int {
	return int(_border(
		chtype(ls), chtype(rs), chtype(ts), chtype(bs),
		chtype(tl), chtype(tr), chtype(bl), chtype(br),
	))
}

wborder :: proc(win: WINDOW, ls, rs, ts, bs, tl, tr, bl, br: u32) -> int {
	return int(_wborder(
		win,
		chtype(ls), chtype(rs), chtype(ts), chtype(bs),
		chtype(tl), chtype(tr), chtype(bl), chtype(br),
	))
}

box :: proc(win: WINDOW, verch, horch: u32) -> int {
	return int(_box(win, chtype(verch), chtype(horch)))
}

hline :: proc(ch: u32, n: int) -> int {
	return int(_hline(chtype(ch), c.int(n)))
}

whline :: proc(win: WINDOW, ch: u32, n: int) -> int {
	return int(_whline(win, chtype(ch), c.int(n)))
}

mvhline :: proc(y, x: int, ch: u32, n: int) -> int {
	return int(_mvhline(c.int(y), c.int(x), chtype(ch), c.int(n)))
}

mvwhline :: proc(win: WINDOW, y, x: int, ch: u32, n: int) -> int {
	return int(_mvwhline(win, c.int(y), c.int(x), chtype(ch), c.int(n)))
}

vline :: proc(ch: u32, n: int) -> int {
	return int(_vline(chtype(ch), c.int(n)))
}

wvline :: proc(win: WINDOW, ch: u32, n: int) -> int {
	return int(_wvline(win, chtype(ch), c.int(n)))
}

mvvline :: proc(y, x: int, ch: u32, n: int) -> int {
	return int(_mvvline(c.int(y), c.int(x), chtype(ch), c.int(n)))
}

mvwvline :: proc(win: WINDOW, y, x: int, ch: u32, n: int) -> int {
	return int(_mvwvline(win, c.int(y), c.int(x), chtype(ch), c.int(n)))
}



@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="border_set")
	_border_set :: proc(ls, rs, ts, bs, tl, tr, bl, br: [^]cchar_t) -> c.int ---
	@(link_name="wborder_set")
	_wborder_set :: proc(win: _WINDOW, ls, rs, ts, bs, tl, tr, bl, br: [^]cchar_t) -> c.int ---

	@(link_name="box_set")
	_box_set :: proc(win: _WINDOW, verch, horch: [^]cchar_t) -> c.int ---

	@(link_name="hline_set")
	_hline_set :: proc(wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="whline_set")
	_whline_set :: proc(win: _WINDOW, wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="mvhline_set")
	_mvhline_set :: proc(y, x: c.int, wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="mvwhline_set")
	_mvwhline_set :: proc(win: _WINDOW, y, x: c.int, wch: [^]cchar_t, n: c.int) -> c.int ---

	@(link_name="vline_set")
	_vline_set :: proc(wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="wvline_set")
	_wvline_set :: proc(win: _WINDOW, wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="mvvline_set")
	_mvvline_set :: proc(y, x: c.int, wch: [^]cchar_t, n: c.int) -> c.int ---
	@(link_name="mvwvline_set")
	_mvwvline_set :: proc(win: _WINDOW, y, x: c.int, wch: [^]cchar_t, n: c.int) -> c.int ---
}

border_set :: proc(ls, rs, ts, bs, tl, tr, bl, br: [^]cchar_t) -> int {
	return int(_border_set(ls, rs, ts, bs, tl, tr, bl, br))
}

wborder_set :: proc(win: WINDOW, ls, rs, ts, bs, tl, tr, bl, br: [^]cchar_t) -> int {
	return int(_wborder_set(win, ls, rs, ts, bs, tl, tr, bl, br))
}

box_set :: proc(win: WINDOW, verch, horch: [^]cchar_t) -> int {
	return int(_box_set(win, verch, horch))
}

hline_set :: proc(wch: [^]cchar_t, n: int) -> int {
	return int(_hline_set(wch, c.int(n)))
}

whline_set :: proc(win: WINDOW, wch: [^]cchar_t, n: int) -> int {
	return int(_whline_set(win, wch, c.int(n)))
}

mvhline_set :: proc(y, x: int, wch: [^]cchar_t, n: int) -> int {
	return int(_mvhline_set(c.int(y), c.int(x), wch, c.int(n)))
}

mvwhline_set :: proc(win: WINDOW, y, x: int, wch: [^]cchar_t, n: int) -> int {
	return int(_mvwhline_set(win, c.int(y), c.int(x), wch, c.int(n)))
}

vline_set :: proc(wch: [^]cchar_t, n: int) -> int {
	return int(_vline_set(wch, c.int(n)))
}

wvline_set :: proc(win: WINDOW, wch: [^]cchar_t, n: int) -> int {
	return int(_wvline_set(win, wch, c.int(n)))
}

mvvline_set :: proc(y, x: int, wch: [^]cchar_t, n: int) -> int {
	return int(_mvvline_set(c.int(y), c.int(x), wch, c.int(n)))
}

mvwvline_set :: proc(win: WINDOW, y, x: int, wch: [^]cchar_t, n: int) -> int {
	return int(_mvwvline_set(win, c.int(y), c.int(x), wch, c.int(n)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="erase")
	_erase :: proc() -> c.int ---
	@(link_name="werase")
	_werase :: proc(win: _WINDOW) -> c.int ---

	@(link_name="clear")
	_clear :: proc() -> c.int ---
	@(link_name="wclear")
	_wclear :: proc(win: _WINDOW) -> c.int ---

	@(link_name="clrtoeol")
	_clrtoeol :: proc() -> c.int ---
	@(link_name="wclrtoeol")
	_wclrtoeol :: proc(win: _WINDOW) -> c.int ---
}

erase :: proc() -> int {
	return int(_erase())
}

werase :: proc(win: WINDOW) -> int {
	return int(_werase(win))
}

clear :: proc() -> int {
	return int(_clear())
}

wclear :: proc(win: WINDOW) -> int {
	return int(_wclear(win))
}

clrtoeol :: proc() -> int {
	return int(_clrtoeol())
}

wclrtoeol :: proc(win: WINDOW) -> int {
	return int(_wclrtoeol(win))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="start_color")
	_start_color :: proc() -> c.int ---

	@(link_name="has_colors")
	_has_colors :: proc() -> c.bool ---
	@(link_name="can_change_color")
	_can_change_color :: proc() -> c.bool ---

	@(link_name="init_pair")
	_init_pair :: proc(pair, f, b: c.short) -> c.int ---
	@(link_name="init_color")
	_init_color :: proc(color, r, g, b: c.short) -> c.int ---
	@(link_name="init_extended_pair")
	_init_extended_pair :: proc(pair, f, b: c.int) -> c.int ---
	@(link_name="init_extended_color")
	_init_extended_color :: proc(color, r, g, b: c.int) -> c.int ---

	@(link_name="color_content")
	_color_content :: proc(color: c.short, r, g, b: [^]c.short) -> c.int ---
	@(link_name="pair_content")
	_pair_content :: proc(pair: c.short, f, b: [^]c.short) -> c.int ---

	@(link_name="extended_color_content")
	_extended_color_content :: proc(color: c.int, r, g, b: [^]c.int) -> c.int ---
	@(link_name="extended_pair_content")
	_extended_pair_content :: proc(pair: c.int, f, b: [^]c.int) -> c.int ---

	@(link_name="reset_color_pairs")
	_reset_color_pairs :: proc() ---

	@(link_name="COLOR_PAIR")
	_COLOR_PAIR :: proc(n: c.int) -> c.int ---
	@(link_name="PAIR_NUMBER")
	_PAIR_NUMBER :: proc(attr: c.int) -> c.int ---
}

start_color :: proc() -> int {
	return int(_start_color())
}

has_colors :: proc() -> bool {
	return bool(_has_colors())
}

can_change_color :: proc() -> bool {
	return bool(_can_change_color())
}

init_pair :: proc(pair, f, b: i16) -> int {
	return int(_init_pair(c.short(pair), c.short(f), c.short(b)))
}

init_color :: proc(color, r, g, b: i16) -> int {
	return int(_init_color(c.short(color), c.short(r), c.short(g), c.short(b)))
}

init_extended_pair :: proc(pair, f, b: int) -> int {
	return int(_init_extended_pair(c.int(pair), c.int(f), c.int(b)))
}

init_extended_color :: proc(color, r, g, b: int) -> int {
	return int(_init_extended_color(c.int(color), c.int(r), c.int(g), c.int(b)))
}

color_content :: proc(color: i16, r, g, b: [^]i16) -> int {
	return int(_color_content(
		c.short(color),
		convert_ptr(r, c.short),
		convert_ptr(g, c.short),
		convert_ptr(b, c.short),
	))
}

pair_content :: proc(pair: i16, f, b: [^]i16) -> int {
	return int(_pair_content(
		c.short(pair),
		convert_ptr(f, c.short),
		convert_ptr(b, c.short),
	))
}

extended_color_content :: proc(color: int, r, g, b: [^]i32) -> int {
	return int(_extended_color_content(
		c.int(color),
		convert_ptr(r, c.int),
		convert_ptr(g, c.int),
		convert_ptr(b, c.int),
	))
}

extended_pair_content :: proc(pair: int, f, b: [^]i32) -> int {
	return int(_extended_pair_content(
		c.int(pair),
		convert_ptr(f, c.int),
		convert_ptr(b, c.int),
	))
}

reset_color_pairs :: proc() {
	_reset_color_pairs()
}

COLOR_PAIR :: proc(n: int) -> int {
	return int(_COLOR_PAIR(c.int(n)))
}

PAIR_NUMBER :: proc(attr: int) -> int {
	return int(_PAIR_NUMBER(c.int(attr)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="delch")
	_delch :: proc() -> c.int ---
	@(link_name="wdelch")
	_wdelch :: proc(win: _WINDOW) -> c.int ---
	@(link_name="mvdelch")
	_mvdelch :: proc(y, x: c.int) -> c.int ---
	@(link_name="mvwdelch")
	_mvwdelch :: proc(win: _WINDOW, y, x: c.int) -> c.int ---
}

delch :: proc() -> int {
	return int(_delch())
}

wdelch :: proc(win: WINDOW) -> int {
	return int(_wdelch(win))
}

mvdelch :: proc(y, x: int) -> int {
	return int(_mvdelch(c.int(y), c.int(x)))
}

mvwdelch :: proc(win: WINDOW, y, x: int) -> int {
	return int(_mvwdelch(win, c.int(y), c.int(x)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="curses_version")
	_curses_version :: proc() -> cstring ---
	@(link_name="use_extended_names")
	_use_extended_names :: proc(bf: c.bool) -> c.int ---
}

curses_version :: proc() -> string {
	return string(_curses_version())
}

use_extended_names :: proc(bf: bool) -> int {
	return int(_use_extended_names(c.bool(bf)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="getch")
	_getch :: proc() -> c.int ---
	@(link_name="wgetch")
	_wgetch :: proc(win: _WINDOW) -> c.int ---
	@(link_name="mvgetch")
	_mvgetch :: proc(y, x: c.int) -> c.int ---
	@(link_name="mvwgetch")
	_mvwgetch :: proc(win: _WINDOW, y, x: c.int) -> c.int ---

	@(link_name="ungetch")
	_ungetch :: proc(_c: c.int) -> c.int ---
	@(link_name="has_key")
	_has_key :: proc(_c: c.int) -> c.int ---
}

getch :: proc() -> int {
	return int(_getch())
}

wgetch :: proc(win: WINDOW) -> int {
	return int(_wgetch(win))
}

mvgetch :: proc(y, x: int) -> int {
	return int(_mvgetch(c.int(y), c.int(x)))
}

mvwgetch :: proc(win: WINDOW, y, x: int) -> int {
	return int(_mvwgetch(win, c.int(y), c.int(x)))
}

ungetch :: proc(ch: int) -> int {
	return int(_ungetch(c.int(ch)))
}

has_key :: proc(ch: int) -> int {
	return int(_has_key(c.int(ch)))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="getstr")
	_getstr :: proc(str: cstring) -> c.int ---
	@(link_name="wgetstr")
	_wgetstr :: proc(win: _WINDOW, str: cstring) -> c.int ---
	@(link_name="mvgetstr")
	_mvgetstr :: proc(y, x: c.int, str: cstring) -> c.int ---
	@(link_name="mvwgetstr")
	_mvwgetstr :: proc(win: _WINDOW, y, x: c.int, str: cstring) -> c.int ---

	@(link_name="getnstr")
	_getnstr :: proc(str: cstring, n: c.int) -> c.int ---
	@(link_name="wgetnstr")
	_wgetnstr :: proc(win: _WINDOW, str: cstring, n: c.int) -> c.int ---
	@(link_name="mvgetnstr")
	_mvgetnstr :: proc(y, x: c.int, str: cstring, n: c.int) -> c.int ---
	@(link_name="mvwgetnstr")
	_mvwgetnstr :: proc(win: _WINDOW, y, x: c.int, str: cstring, n: c.int) -> c.int ---
}

getstr :: proc(str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_getstr(c_str))
}

wgetstr :: proc(win: WINDOW, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_wgetstr(win, c_str))
}

mvgetstr :: proc(y, x: int, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvgetstr(c.int(y), c.int(x), c_str))
}

mvwgetstr :: proc(win: WINDOW, y, x: int, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvwgetstr(win, c.int(y), c.int(x), c_str))
}

getnstr :: proc(str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_getnstr(c_str, c.int(n)))
}

wgetnstr :: proc(win: WINDOW, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_wgetnstr(win, c_str, c.int(n)))
}

mvgetnstr :: proc(y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvgetnstr(c.int(y), c.int(x), c_str, c.int(n)))
}

mvwgetnstr :: proc(win: WINDOW, y, x: int, str: string, n: int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_mvwgetnstr(win, c.int(y), c.int(x), c_str, c.int(n)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="in_wch")
	_in_wch :: proc(wch: [^]cchar_t) -> c.int ---
	@(link_name="win_wch")
	_win_wch :: proc(win: _WINDOW, wch: [^]cchar_t) -> c.int ---
	@(link_name="mvin_wch")
	_mvin_wch :: proc(y, x: c.int, wch: [^]cchar_t) -> c.int ---
	@(link_name="mvwin_wch")
	_mvwin_wch :: proc(win: _WINDOW, y, x: c.int, wch: [^]cchar_t) -> c.int ---
}

in_wch :: proc(wch: [^]cchar_t) -> int {
	return int(_in_wch(wch))
}

win_wch :: proc(win: WINDOW, wch: [^]cchar_t) -> int {
	return int(_win_wch(win, wch))
}

mvin_wch :: proc(y, x: int, wch: [^]cchar_t) -> int {
	return int(_mvin_wch(c.int(y), c.int(x), wch))
}

mvwin_wch :: proc(win: WINDOW, y, x: int, wch: [^]cchar_t) -> int {
	return int(_mvwin_wch(win, c.int(y), c.int(x), wch))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="initscr")
	_initscr :: proc() -> _WINDOW ---
	@(link_name="endwin")
	_endwin :: proc() -> c.int ---

	@(link_name="newterm")
	_newterm :: proc(type: cstring, outf: [^]c.FILE, inf: [^]c.FILE) -> SCREEN ---
	@(link_name="set_term")
	_set_term :: proc(new: SCREEN) -> SCREEN ---
	@(link_name="delscreen")
	_delscreen :: proc(sp: SCREEN) ---
}

initscr :: proc() -> WINDOW {
	win := _initscr()
	if win == nil {
		return nil
	}
	return WINDOW(&win[0])
}

endwin :: proc() -> int {
	return int(_endwin())
}

newterm :: proc(type: string, outf: [^]c.FILE, inf: [^]c.FILE, allocator: runtime.Allocator = context.temp_allocator ) -> SCREEN {
	c_str := strings.clone_to_cstring(type, allocator)
	defer delete(c_str)
	return _newterm(c_str, outf, inf)
}

set_term :: proc(new: SCREEN) -> SCREEN {
	return _set_term(new)
}

delscreen :: proc(sp: SCREEN) {
	_delscreen(sp)
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="cbreak")
	_cbreak :: proc() -> c.int ---
	@(link_name="nocbreak")
	_nocbreak :: proc() -> c.int ---

	@(link_name="echo")
	_echo :: proc() -> c.int ---
	@(link_name="noecho")
	_noecho :: proc() -> c.int ---

	@(link_name="intrflush")
	_intrflush :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
	@(link_name="keypad")
	_keypad :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
	@(link_name="meta")
	_meta :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
	@(link_name="nodelay")
	_nodelay :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
	@(link_name="notimeout")
	_notimeout :: proc(win: _WINDOW, bf: c.bool) -> c.int ---

	@(link_name="nl")
	_nl :: proc() -> c.int ---
	@(link_name="nonl")
	_nonl :: proc() -> c.int ---

	@(link_name="qiflush")
	_qiflush :: proc() ---
	@(link_name="noqiflush")
	_noqiflush :: proc() ---

	@(link_name="raw")
	_raw :: proc() -> c.int ---
	@(link_name="noraw")
	_noraw :: proc() -> c.int ---

	@(link_name="halfdelay")
	_halfdelay :: proc(tenths: c.int) -> c.int ---
	@(link_name="timeout")
	_timeout :: proc(delay: c.int) ---
	@(link_name="wtimeout")
	_wtimeout :: proc(win: _WINDOW, delay: c.int) ---

	@(link_name="typeahead")
	_typeahead :: proc(fd: c.int) -> c.int ---

	@(link_name="is_cbreak")
	_is_cbreak :: proc() -> c.int ---
	@(link_name="is_echo")
	_is_echo :: proc() -> c.int ---
	@(link_name="is_nl")
	_is_nl :: proc() -> c.int ---
	@(link_name="is_raw")
	_is_raw :: proc() -> c.int ---
}

cbreak :: proc() -> int {
	return int(_cbreak())
}

nocbreak :: proc() -> int {
	return int(_nocbreak())
}

echo :: proc() -> int {
	return int(_echo())
}

noecho :: proc() -> int {
	return int(_noecho())
}

intrflush :: proc(win: WINDOW, bf: bool) -> int {
	return int(_intrflush(win, c.bool(bf)))
}

keypad :: proc(win: WINDOW, bf: bool) -> int {
	return int(_keypad(win, c.bool(bf)))
}

meta :: proc(win: WINDOW, bf: bool) -> int {
	return int(_meta(win, c.bool(bf)))
}

nodelay :: proc(win: WINDOW, bf: bool) -> int {
	return int(_nodelay(win, c.bool(bf)))
}

notimeout :: proc(win: WINDOW, bf: bool) -> int {
	return int(_notimeout(win, c.bool(bf)))
}

nl :: proc() -> int {
	return int(_nl())
}

nonl :: proc() -> int {
	return int(_nonl())
}

qiflush :: proc() {
	_qiflush()
}

noqiflush :: proc() {
	_noqiflush()
}

raw :: proc() -> int {
	return int(_raw())
}

noraw :: proc() -> int {
	return int(_noraw())
}

halfdelay :: proc(tenths: int) -> int {
	return int(_halfdelay(c.int(tenths)))
}

timeout :: proc(delay: int) {
	_timeout(c.int(delay))
}

wtimeout :: proc(win: WINDOW, delay: int) {
	_wtimeout(win, c.int(delay))
}

typeahead :: proc(fd: int) -> int {
	return int(_typeahead(c.int(fd)))
}

is_cbreak :: proc() -> int {
	return int(_is_cbreak())
}

is_echo :: proc() -> int {
	return int(_is_echo())
}

is_nl :: proc() -> int {
	return int(_is_nl())
}

is_raw :: proc() -> int {
	return int(_is_raw())
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="def_prog_mode")
	_def_prog_mode :: proc() -> c.int ---
	@(link_name="def_shell_mode")
	_def_shell_mode :: proc() -> c.int ---

	@(link_name="reset_prog_mode")
	_reset_prog_mode :: proc() -> c.int ---
	@(link_name="reset_shell_mode")
	_reset_shell_mode :: proc() -> c.int ---

	@(link_name="resetty")
	_resetty :: proc() -> c.int ---
	@(link_name="savetty")
	_savetty :: proc() -> c.int ---

	@(link_name="getsyx")
	_getsyx :: proc(y, x: c.int) ---
	@(link_name="setsyx")
	_setsyx :: proc(y, x: c.int) ---

	@(link_name="curs_set")
	_curs_set :: proc(visibility: c.int) -> c.int ---
	@(link_name="mvcur")
	_mvcur :: proc(oldrow, oldcol, newrow, newcol: c.int) -> c.int ---
	@(link_name="napms")
	_napms :: proc(ms: c.int) -> c.int ---
	@(link_name="ripoffline")
	_ripoffline :: proc(line: c.int, init: proc "c" (win: _WINDOW, ncols: c.int) -> c.int) -> c.int ---
}

def_prog_mode :: proc() -> int {
	return int(_def_prog_mode())
}

def_shell_mode :: proc() -> int {
	return int(_def_shell_mode())
}

reset_prog_mode :: proc() -> int {
	return int(_reset_prog_mode())
}

reset_shell_mode :: proc() -> int {
	return int(_reset_shell_mode())
}

resetty :: proc() -> int {
	return int(_resetty())
}

savetty :: proc() -> int {
	return int(_savetty())
}

getsyx :: proc(y, x: int) {
	_getsyx(c.int(y), c.int(x))
}

setsyx :: proc(y, x: int) {
	_setsyx(c.int(y), c.int(x))
}

curs_set :: proc(visibility: int) -> int {
	return int(_curs_set(c.int(visibility)))
}

mvcur :: proc(oldrow, oldcol, newrow, newcol: int) -> int {
	return int(_mvcur(c.int(oldrow), c.int(oldcol), c.int(newrow), c.int(newcol)))
}

napms :: proc(ms: int) -> int {
	return int(_napms(c.int(ms)))
}

ripoffline :: proc(line: int, init: proc "c" (win: WINDOW, ncols: c.int) -> c.int) -> int {
	raw_init := cast(proc "c" (win: _WINDOW, ncols: c.int) -> c.int)init
	return int(_ripoffline(c.int(line), raw_init))
}



@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="getattrs")
	_getattrs :: proc(win: _WINDOW) -> c.int ---

	@(link_name="getbegx")
	_getbegx :: proc(win: _WINDOW) -> c.int ---
	@(link_name="getbegy")
	_getbegy :: proc(win: _WINDOW) -> c.int ---

	@(link_name="getcurx")
	_getcurx :: proc(win: _WINDOW) -> c.int ---
	@(link_name="getcury")
	_getcury :: proc(win: _WINDOW) -> c.int ---

	@(link_name="getmaxx")
	_getmaxx :: proc(win: _WINDOW) -> c.int ---
	@(link_name="getmaxy")
	_getmaxy :: proc(win: _WINDOW) -> c.int ---

	@(link_name="getparx")
	_getparx :: proc(win: _WINDOW) -> c.int ---
	@(link_name="getpary")
	_getpary :: proc(win: _WINDOW) -> c.int ---
}

getattrs :: proc(win: WINDOW) -> int {
	return int(_getattrs(win))
}

getbegx :: proc(win: WINDOW) -> int {
	return int(_getbegx(win))
}

getbegy :: proc(win: WINDOW) -> int {
	return int(_getbegy(win))
}

getcurx :: proc(win: WINDOW) -> int {
	return int(_getcurx(win))
}

getcury :: proc(win: WINDOW) -> int {
	return int(_getcury(win))
}

getmaxx :: proc(win: WINDOW) -> int {
	return int(_getmaxx(win))
}

getmaxy :: proc(win: WINDOW) -> int {
	return int(_getmaxy(win))
}

getparx :: proc(win: WINDOW) -> int {
	return int(_getparx(win))
}

getpary :: proc(win: WINDOW) -> int {
	return int(_getpary(win))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="has_mouse")
	_has_mouse :: proc() -> c.bool ---

	@(link_name="mousemask")
	_mousemask :: proc(new_mask: mmask_t, old_mask: [^]mmask_t) -> mmask_t ---

	@(link_name="getmouse")
	_getmouse :: proc(event: [^]MEVENT) -> c.int ---
	@(link_name="ungetmouse")
	_ungetmouse :: proc(event: [^]MEVENT) -> c.int ---

	@(link_name="wenclose")
	_wenclose :: proc(win: _WINDOW, y, x: c.int) -> c.bool ---

	@(link_name="mouse_trafo")
	_mouse_trafo :: proc(pY, pX: [^]c.int, to_screen: c.bool) -> c.bool ---
	@(link_name="wmouse_trafo")
	_wmouse_trafo :: proc(win: _WINDOW, pY, pX: [^]c.int, to_screen: c.bool) -> c.bool ---

	@(link_name="mouseinterval")
	_mouseinterval :: proc(erval: c.int) -> c.int ---
}

has_mouse :: proc() -> bool {
	return bool(_has_mouse())
}

mousemask :: proc(new_mask: mmask_t, old_mask: [^]mmask_t) -> mmask_t {
	return _mousemask(new_mask, old_mask)
}

getmouse :: proc(event: [^]MEVENT) -> int {
	return int(_getmouse(event))
}

ungetmouse :: proc(event: [^]MEVENT) -> int {
	return int(_ungetmouse(event))
}

wenclose :: proc(win: WINDOW, y, x: int) -> bool {
	return bool(_wenclose(win, c.int(y), c.int(x)))
}

mouse_trafo :: proc(pY, pX: [^]i32, to_screen: bool) -> bool {
	return bool(_mouse_trafo(convert_ptr(pY, c.int), convert_ptr(pX, c.int), c.bool(to_screen)))
}

wmouse_trafo :: proc(win: WINDOW, pY, pX: [^]i32, to_screen: bool) -> bool {
	return bool(_wmouse_trafo(win, convert_ptr(pY, c.int), convert_ptr(pX, c.int), c.bool(to_screen)))
}

mouseinterval :: proc(erval: int) -> int {
	return int(_mouseinterval(c.int(erval)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="move")
	_move :: proc(y, x: c.int) -> c.int ---
	@(link_name="wmove")
	_wmove :: proc(win: _WINDOW, y, x: c.int) -> c.int ---
}

move :: proc(y, x: int) -> int {
	return int(_move(c.int(y), c.int(x)))
}

wmove :: proc(win: WINDOW, y, x: int) -> int {
	return int(_wmove(win, c.int(y), c.int(x)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="is_cleared")
	_is_cleared :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_idcok")
	_is_idcok :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_idlok")
	_is_idlok :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_immedok")
	_is_immedok :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_keypad")
	_is_keypad :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_leaveok")
	_is_leaveok :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_nodelay")
	_is_nodelay :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_notimeout")
	_is_notimeout :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_pad")
	_is_pad :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_scrollok")
	_is_scrollok :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_subwin")
	_is_subwin :: proc(win: _WINDOW) -> c.bool ---
	@(link_name="is_syncok")
	_is_syncok :: proc(win: _WINDOW) -> c.bool ---

	@(link_name="wgetparent")
	_wgetparent :: proc(win: _WINDOW) -> _WINDOW ---
	@(link_name="wgetdelay")
	_wgetdelay :: proc(win: _WINDOW) -> c.int ---
	@(link_name="wgetscrreg")
	_wgetscrreg :: proc(win: _WINDOW, top, bottom: [^]c.int) -> c.int ---
}

is_cleared :: proc(win: WINDOW) -> bool {
	return bool(_is_cleared(win))
}

is_idcok :: proc(win: WINDOW) -> bool {
	return bool(_is_idcok(win))
}

is_idlok :: proc(win: WINDOW) -> bool {
	return bool(_is_idlok(win))
}

is_immedok :: proc(win: WINDOW) -> bool {
	return bool(_is_immedok(win))
}

is_keypad :: proc(win: WINDOW) -> bool {
	return bool(_is_keypad(win))
}

is_leaveok :: proc(win: WINDOW) -> bool {
	return bool(_is_leaveok(win))
}

is_nodelay :: proc(win: WINDOW) -> bool {
	return bool(_is_nodelay(win))
}

is_notimeout :: proc(win: WINDOW) -> bool {
	return bool(_is_notimeout(win))
}

is_pad :: proc(win: WINDOW) -> bool {
	return bool(_is_pad(win))
}

is_scrollok :: proc(win: WINDOW) -> bool {
	return bool(_is_scrollok(win))
}

is_subwin :: proc(win: WINDOW) -> bool {
	return bool(_is_subwin(win))
}

is_syncok :: proc(win: WINDOW) -> bool {
	return bool(_is_syncok(win))
}

wgetparent :: proc(win: WINDOW) -> WINDOW {
	return WINDOW(_wgetparent(win))
}

wgetdelay :: proc(win: WINDOW) -> int {
	return int(_wgetdelay(win))
}

wgetscrreg :: proc(win: WINDOW, top, bottom: [^]i32) -> int {
	return int(_wgetscrreg(win, convert_ptr(top, c.int), convert_ptr(bottom, c.int)))
}



@(default_calling_convention="c")
foreign lib {
    clearok :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
    idcok :: proc(win: _WINDOW, bf: c.bool) ---
    idlok :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
    immedok :: proc(win: _WINDOW, bf: c.bool) ---
    leaveok :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
    scrollok :: proc(win: _WINDOW, bf: c.bool) -> c.int ---

    setscrreg :: proc(top, bot: c.int) -> c.int ---
    wsetscrreg :: proc(win: _WINDOW, top, bot: c.int) -> c.int ---
}


@(default_calling_convention="c")
foreign lib {
    overlay :: proc(srcwin, dstwin: _WINDOW) -> c.int ---
    overwrite :: proc(srcwin, dstwin: _WINDOW) -> c.int ---
    copywin :: proc(srcwin, dstwin: _WINDOW, sminrow, smincol, dminrow, dmincol, dmaxrow, dmaxcol, overlay: c.int) -> c.int ---
}


@(private)
@(default_calling_convention="c")
foreign lib {
    @(link_name="printw")
    _printw :: proc(fmt: cstring, #c_vararg args: ..any) -> c.int ---
    @(link_name="wprintw")
    _wprintw :: proc(win: _WINDOW, fmt: cstring, #c_vararg args: ..any) -> c.int ---
    @(link_name="mvprintw")
    _mvprintw :: proc(y, x: c.int, fmt: cstring, #c_vararg args: ..any) -> c.int ---
    @(link_name="mvwprintw")
    _mvwprintw :: proc(win: _WINDOW, y, x: c.int, fmt: cstring, #c_vararg args: ..any) -> c.int ---

    @(link_name="vw_printw")
    _vw_printw :: proc(win: _WINDOW, fmt: cstring, args: c.va_list) -> c.int ---
    @(link_name="vwprintw")
    _vwprintw :: proc(win: _WINDOW, fmt: cstring, args: c.va_list) -> c.int ---
}

printw :: proc(_fmt: string, args: ..any, allocator := context.temp_allocator) -> int {
    c_str := fmt.ctprintf(_fmt, ..args)
    return int(_printw(c_str))
}

wprintw :: proc(win: WINDOW, _fmt: string, args: ..any) -> int {
    c_str := fmt.ctprintf(_fmt, ..args)
    return int(_wprintw(win, c_str))
}

mvprintw :: proc(y, x: int, _fmt: string, args: ..any) -> int {
    c_str := fmt.ctprintf(_fmt, ..args)
    return int(_mvprintw(c.int(y), c.int(x), c_str))
}

mvwprintw :: proc(win: WINDOW, y, x: int, _fmt: string, args: ..any, allocator := context.temp_allocator) -> int {
    c_str := fmt.ctprintf(_fmt, ..args)
    return int(_mvwprintw(win, c.int(y), c.int(x), c_str))
}

vw_printw :: proc(win: WINDOW, fmt: string, args: c.va_list, allocator := context.temp_allocator) -> int {
    c_fmt := strings.clone_to_cstring(fmt, allocator)
    defer delete(c_fmt, allocator)
    return int(_vw_printw(win, c_fmt, args))
}

vwprintw :: proc(win: WINDOW, fmt: string, args: c.va_list, allocator := context.temp_allocator) -> int {
    c_fmt := strings.clone_to_cstring(fmt, allocator)
    defer delete(c_fmt, allocator)
    return int(_vwprintw(win, c_fmt, args))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="refresh")
	_refresh :: proc() -> c.int ---
	@(link_name="wrefresh")
	_wrefresh :: proc(win: _WINDOW) -> c.int ---
	@(link_name="wnoutrefresh")
	_wnoutrefresh :: proc(win: _WINDOW) -> c.int ---
	@(link_name="doupdate")
	_doupdate :: proc() -> c.int ---

	@(link_name="redrawwin")
	_redrawwin :: proc(win: _WINDOW) -> c.int ---
	@(link_name="wredrawln")
	_wredrawln :: proc(win: _WINDOW, beg_line: c.int, num_lines: c.int) -> c.int ---
}

refresh :: proc() -> int {
	return int(_refresh())
}

wrefresh :: proc(win: WINDOW) -> int {
	return int(_wrefresh(win))
}

wnoutrefresh :: proc(win: WINDOW) -> int {
	return int(_wnoutrefresh(win))
}

doupdate :: proc() -> int {
	return int(_doupdate())
}

redrawwin :: proc(win: WINDOW) -> int {
	return int(_redrawwin(win))
}

wredrawln :: proc(win: WINDOW, beg_line, num_lines: int) -> int {
	return int(_wredrawln(win, c.int(beg_line), c.int(num_lines)))
}

@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="slk_init")
	_slk_init :: proc(fmt: c.int) -> c.int ---

	@(link_name="slk_set")
	_slk_set :: proc(labnum: c.int, label: cstring, align: c.int) -> c.int ---
	@(link_name="slk_wset")
	_slk_wset :: proc(labnum: c.int, label: [^]c.wchar_t, align: c.int) -> c.int ---

	@(link_name="slk_label")
	_slk_label :: proc(labnum: c.int) -> cstring ---

	@(link_name="slk_refresh")
	_slk_refresh :: proc() -> c.int ---
	@(link_name="slk_noutrefresh")
	_slk_noutrefresh :: proc() -> c.int ---
	@(link_name="slk_clear")
	_slk_clear :: proc() -> c.int ---
	@(link_name="slk_restore")
	_slk_restore :: proc() -> c.int ---
	@(link_name="slk_touch")
	_slk_touch :: proc() -> c.int ---

	@(link_name="slk_attron")
	_slk_attron :: proc(attrs: chtype) -> c.int ---
	@(link_name="slk_attroff")
	_slk_attroff :: proc(attrs: chtype) -> c.int ---
	@(link_name="slk_attrset")
	_slk_attrset :: proc(attrs: chtype) -> c.int ---
	@(link_name="slk_attr_on")
	_slk_attr_on :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
	@(link_name="slk_attr_off")
	_slk_attr_off :: proc(attrs: attr_t, opts: rawptr) -> c.int ---
	@(link_name="slk_attr_set")
	_slk_attr_set :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

	@(link_name="slk_attr")
	_slk_attr :: proc() -> attr_t ---

	@(link_name="slk_color")
	_slk_color :: proc(pair: c.short) -> c.int ---
	@(link_name="extended_slk_color")
	_extended_slk_color :: proc(pair: c.int) -> c.int ---
}

slk_init :: proc(fmt: int) -> int {
	return int(_slk_init(c.int(fmt)))
}

slk_set :: proc(labnum: int, label: string, align: int, allocator := context.temp_allocator) -> int {
	c_label := strings.clone_to_cstring(label, allocator)
	defer delete(c_label, allocator)
	return int(_slk_set(c.int(labnum), c_label, c.int(align)))
}

slk_wset :: proc(labnum: int, label: string, align: int, allocator: runtime.Allocator = context.temp_allocator) -> int {
	wstr, ptr := clone_to_wstring(label, allocator)
	defer free(ptr, allocator)
	return int(_slk_wset(c.int(labnum), wstr, c.int(align)))
}

slk_label :: proc(labnum: int) -> string {
	return string(_slk_label(c.int(labnum)))
}

slk_refresh :: proc() -> int {
	return int(_slk_refresh())
}

slk_noutrefresh :: proc() -> int {
	return int(_slk_noutrefresh())
}

slk_clear :: proc() -> int {
	return int(_slk_clear())
}

slk_restore :: proc() -> int {
	return int(_slk_restore())
}

slk_touch :: proc() -> int {
	return int(_slk_touch())
}

slk_attron :: proc(attrs: u32) -> int {
	return int(_slk_attron(chtype(attrs)))
}

slk_attroff :: proc(attrs: u32) -> int {
	return int(_slk_attroff(chtype(attrs)))
}

slk_attrset :: proc(attrs: u32) -> int {
	return int(_slk_attrset(chtype(attrs)))
}

slk_attr_on :: proc(attrs: attr_t, opts: rawptr) -> int {
	return int(_slk_attr_on(attrs, opts))
}

slk_attr_off :: proc(attrs: attr_t, opts: rawptr) -> int {
	return int(_slk_attr_off(attrs, opts))
}

slk_attr_set :: proc(attrs: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_slk_attr_set(attrs, c.short(pair), opts))
}

slk_attr :: proc() -> attr_t {
	return _slk_attr()
}

slk_color :: proc(pair: i16) -> int {
	return int(_slk_color(c.short(pair)))
}

extended_slk_color :: proc(pair: int) -> int {
	return int(_extended_slk_color(c.int(pair)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="baudrate")
	_baudrate :: proc() -> c.int ---
	@(link_name="erasechar")
	_erasechar :: proc() -> c.char ---
	@(link_name="erasewchar")
	_erasewchar :: proc(wc: [^]c.wchar_t) -> c.int ---
	@(link_name="has_ic")
	_has_ic :: proc() -> c.bool ---
	@(link_name="has_il")
	_has_il :: proc() -> c.bool ---
	@(link_name="killchar")
	_killchar :: proc() -> c.char ---
	@(link_name="killwchar")
	_killwchar :: proc(wc: [^]c.wchar_t) -> c.int ---
	@(link_name="longname")
	_longname :: proc() -> cstring ---
	@(link_name="term_attrs")
	_term_attrs :: proc() -> attr_t ---
	@(link_name="termattrs")
	_termattrs :: proc() -> chtype ---
	@(link_name="termname")
	_termname :: proc() -> cstring ---
}

baudrate :: proc() -> int {
	return int(_baudrate())
}

erasechar :: proc() -> u8 {
	return u8(_erasechar())
}

erasewchar :: proc(s: string, allocator := context.temp_allocator) -> int {
	wptr, raw := clone_to_wstring(s, allocator)
	defer free(raw, allocator)
	return int(_erasewchar(wptr))
}

has_ic :: proc() -> bool {
	return bool(_has_ic())
}

has_il :: proc() -> bool {
	return bool(_has_il())
}

killchar :: proc() -> u8 {
	return u8(_killchar())
}

killwchar :: proc(s: string, allocator := context.temp_allocator) -> int {
	wptr, raw := clone_to_wstring(s, allocator)
	defer free(raw, allocator)
	return int(_killwchar(wptr))
}

longname :: proc() -> string {
	return string(_longname())
}

term_attrs :: proc() -> u32 {
	return u32(_term_attrs())
}

termattrs :: proc() -> u32 {
	return u32(_termattrs())
}

termname :: proc() -> string {
	return string(_termname())
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="tgetent")
	_tgetent :: proc(bp: cstring, name: cstring) -> c.int ---
	@(link_name="tgetflag")
	_tgetflag :: proc(id: cstring) -> c.int ---
	@(link_name="tgetnum")
	_tgetnum :: proc(id: cstring) -> c.int ---
	@(link_name="tgetstr")
	_tgetstr :: proc(id: cstring, sbuf: [^]cstring) -> cstring ---
	@(link_name="tgoto")
	_tgoto :: proc(cap: cstring, col, row: c.int) -> cstring ---
}

tgetent :: proc(bp: string, name: string, allocator := context.temp_allocator) -> int {
	c_bp := strings.clone_to_cstring(bp, allocator)
	defer delete(c_bp, allocator)
	c_name := strings.clone_to_cstring(name, allocator)
	defer delete(c_name, allocator)
	return int(_tgetent(c_bp, c_name))
}

tgetflag :: proc(id: string, allocator := context.temp_allocator) -> int {
	c_id := strings.clone_to_cstring(id, allocator)
	defer delete(c_id, allocator)
	return int(_tgetflag(c_id))
}

tgetnum :: proc(id: string, allocator := context.temp_allocator) -> int {
	c_id := strings.clone_to_cstring(id, allocator)
	defer delete(c_id, allocator)
	return int(_tgetnum(c_id))
}

tgetstr :: proc(id: string, sbuf: []string, allocator := context.temp_allocator) -> string {
	c_id := strings.clone_to_cstring(id, allocator)
	defer delete(c_id, allocator)


	c_sbuf := make([]cstring, len(sbuf), allocator)
	defer delete(c_sbuf, allocator)


	for str, i in sbuf {
		c_sbuf[i] = strings.clone_to_cstring(str, allocator)
	}


	defer {
		for c_str in c_sbuf {
			delete(c_str, allocator)
		}
	}

	return string(_tgetstr(c_id, raw_data(c_sbuf)))
}

tgoto :: proc(cap: string, col, row: int, allocator := context.temp_allocator) -> string {
	c_cap := strings.clone_to_cstring(cap, allocator)
	defer delete(c_cap, allocator)
	return string(_tgoto(c_cap, c.int(col), c.int(row)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="setupterm")
	_setupterm :: proc(term: cstring, filedes: c.int, errret: [^]c.int) -> c.int ---
	@(link_name="set_curterm")
	_set_curterm :: proc(nterm: TERMINAL) -> TERMINAL ---
	@(link_name="del_curterm")
	_del_curterm :: proc(oterm: TERMINAL) -> c.int ---
	@(link_name="restartterm")
	_restartterm :: proc(term: cstring, filedes: c.int, errret: [^]c.int) -> c.int ---

	@(link_name="tparm")
	_tparm :: proc(str: cstring, #c_vararg args: ..any) -> cstring ---

	@(link_name="tputs")
	_tputs :: proc(str: cstring, affcnt: c.int, putc: proc "c" (c.int) -> c.int) -> c.int ---
	@(link_name="putp")
	_putp :: proc(str: cstring) -> c.int ---

	@(link_name="vidputs")
	_vidputs :: proc(attrs: chtype, putc: proc "c" (c.int) -> c.int) -> c.int ---
	@(link_name="vidattr")
	_vidattr :: proc(attrs: chtype) -> c.int ---
	@(link_name="vid_puts")
	_vid_puts :: proc(attrs: attr_t, pair: c.short, opts: rawptr, putc: proc "c" (c.int) -> c.int) -> c.int ---
	@(link_name="vid_attr")
	_vid_attr :: proc(attrs: attr_t, pair: c.short, opts: rawptr) -> c.int ---

	@(link_name="tigetflag")
	_tigetflag :: proc(cap_code: cstring) -> c.int ---
	@(link_name="tigetnum")
	_tigetnum :: proc(cap_code: cstring) -> c.int ---
	@(link_name="tigetstr")
	_tigetstr :: proc(cap_code: cstring) -> cstring ---

	@(link_name="tiparm")
	_tiparm :: proc(str: cstring, #c_vararg args: ..any) -> cstring ---

	@(link_name="tiparm_s")
	_tiparm_s :: proc(expected: c.int, mask: c.int, str: cstring, #c_vararg args: ..any) -> cstring ---
	@(link_name="tiscan_s")
	_tiscan_s :: proc(expected: [^]c.int, mask: [^]c.int, str: cstring) -> c.int ---

	@(link_name="setterm")
	_setterm :: proc(term: cstring) -> c.int ---
}

setupterm :: proc(term: string, filedes: int, errret: [^]c.int, allocator := context.temp_allocator) -> int {
	c_term := strings.clone_to_cstring(term, allocator)
	defer delete(c_term, allocator)
	return int(_setupterm(c_term, c.int(filedes), errret))
}

set_curterm :: proc(nterm: TERMINAL) -> TERMINAL {
	return _set_curterm(nterm)
}

del_curterm :: proc(oterm: TERMINAL) -> int {
	return int(_del_curterm(oterm))
}

restartterm :: proc(term: string, filedes: int, errret: [^]c.int, allocator := context.temp_allocator) -> int {
	c_term := strings.clone_to_cstring(term, allocator)
	defer delete(c_term, allocator)
	return int(_restartterm(c_term, c.int(filedes), errret))
}

tparm :: proc(str: string, args: ..any, allocator := context.temp_allocator) -> string {
	c_str := fmt.ctprintf(str, ..args)
	return string(_tparm(c_str))
}

tputs :: proc(str: string, affcnt: int, putc: proc "c" (c.int) -> c.int, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)

	return int(_tputs(c_str, c.int(affcnt), putc))
}

putp :: proc(str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_putp(c_str))
}

vidputs :: proc(attrs: u32, putc: proc "c" (c.int) -> c.int) -> int {
	return int(_vidputs(chtype(attrs), putc))
}

vidattr :: proc(attrs: u32) -> int {
	return int(_vidattr(chtype(attrs)))
}

vid_puts :: proc(attrs: attr_t, pair: i16, opts: rawptr, putc: proc "c" (c.int) -> c.int) -> int {
	return int(_vid_puts(attrs, c.short(pair), opts, putc))
}

vid_attr :: proc(attrs: attr_t, pair: i16, opts: rawptr) -> int {
	return int(_vid_attr(attrs, c.short(pair), opts))
}

tigetflag :: proc(cap_code: string, allocator := context.temp_allocator) -> int {
	c_cap := strings.clone_to_cstring(cap_code, allocator)
	defer delete(c_cap, allocator)
	return int(_tigetflag(c_cap))
}

tigetnum :: proc(cap_code: string, allocator := context.temp_allocator) -> int {
	c_cap := strings.clone_to_cstring(cap_code, allocator)
	defer delete(c_cap, allocator)
	return int(_tigetnum(c_cap))
}

tigetstr :: proc(cap_code: string, allocator := context.temp_allocator) -> string {
	c_cap := strings.clone_to_cstring(cap_code, allocator)
	defer delete(c_cap, allocator)
	return string(_tigetstr(c_cap))
}

tiparm :: proc(str: string, args: ..any, allocator := context.temp_allocator) -> string {
	c_str := fmt.ctprintf(str, ..args)
	return string(_tiparm(c_str))
}

tiparm_s :: proc(expected: int, mask: int, str: string, args: ..any, allocator := context.temp_allocator) -> string {
	c_str := fmt.ctprintf(str, ..args)
	return string(_tiparm_s(c.int(expected), c.int(mask), c_str))
}

tiscan_s :: proc(expected: [^]c.int, mask: [^]c.int, str: string, allocator := context.temp_allocator) -> int {
	c_str := strings.clone_to_cstring(str, allocator)
	defer delete(c_str, allocator)
	return int(_tiscan_s(expected, mask, c_str))
}

setterm :: proc(term: string, allocator := context.temp_allocator) -> int {
	c_term := strings.clone_to_cstring(term, allocator)
	defer delete(c_term, allocator)
	return int(_setterm(c_term))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="curses_trace")
	_curses_trace :: proc(trace_mask: c.uint) -> c.uint ---

	@(link_name="_tracef")
	__tracef :: proc(format: cstring, #c_vararg args: ..any) ---

	@(link_name="_traceattr")
	__traceattr :: proc(attr: attr_t) -> cstring ---
	@(link_name="_traceattr2")
	__traceattr2 :: proc(buffer: c.int, ch: chtype) -> cstring ---
	@(link_name="_tracecchar_t")
	__tracecchar_t :: proc(string: [^]cchar_t) -> cstring ---
	@(link_name="_tracecchar_t2")
	__tracecchar_t2 :: proc(buffer: c.int, string: [^]cchar_t) -> cstring ---
	@(link_name="_tracechar")
	__tracechar :: proc(c: c.int) -> cstring ---
	@(link_name="_tracechtype")
	__tracechtype :: proc(ch: chtype) -> cstring ---
	@(link_name="_tracechtype2")
	__tracechtype2 :: proc(buffer: c.int, ch: chtype) -> cstring ---

	@(link_name="_tracedump")
	__tracedump :: proc(label: cstring, win: _WINDOW) ---
	@(link_name="_nc_tracebits")
	__nc_tracebits :: proc() -> cstring ---
	@(link_name="_tracemouse")
	__tracemouse :: proc(event: [^]MEVENT) -> cstring ---

	/* deprecated */
	@(link_name="trace")
	_trace :: proc(trace_mask: c.uint) ---
}

curses_trace :: proc(trace_mask: u32) -> u32 {
	return u32(_curses_trace(c.uint(trace_mask)))
}

_tracef :: proc(format: string, args: ..any, allocator := context.temp_allocator) {
	c_str := fmt.ctprintf(format, ..args)
	__tracef(c_str)
}

_traceattr :: proc(attr: attr_t) -> string {
	return string(__traceattr(attr))
}

_traceattr2 :: proc(buffer: int, ch: u32) -> string {
	return string(__traceattr2(c.int(buffer), chtype(ch)))
}

_tracecchar_t :: proc(str: [^]cchar_t) -> string {
	return string(__tracecchar_t(str))
}

_tracecchar_t2 :: proc(buffer: int, str: [^]cchar_t) -> string {
	return string(__tracecchar_t2(c.int(buffer), str))
}

_tracechar :: proc(ch: int) -> string {
	return string(__tracechar(c.int(ch)))
}

_tracechtype :: proc(ch: u32) -> string {
	return string(__tracechtype(chtype(ch)))
}

_tracechtype2 :: proc(buffer: int, ch: u32) -> string {
	return string(__tracechtype2(c.int(buffer), chtype(ch)))
}

_tracedump :: proc(label: string, win: WINDOW, allocator := context.temp_allocator) {
	c_label := strings.clone_to_cstring(label, allocator)
	defer delete(c_label, allocator)
	__tracedump(c_label, win)
}

_nc_tracebits :: proc() -> string {
	return string(__nc_tracebits())
}

_tracemouse :: proc(event: [^]MEVENT) -> string {
	return string(__tracemouse(event))
}

trace :: proc(trace_mask: u32) {
	_trace(c.uint(trace_mask))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="unctrl")
	_unctrl :: proc(ch: chtype) -> cstring ---
	@(link_name="wunctrl")
	_wunctrl :: proc(wch: [^]cchar_t) -> [^]c.wchar_t ---

	@(link_name="keyname")
	_keyname :: proc(c: c.int) -> cstring ---
	@(link_name="key_name")
	_key_name :: proc(wc: c.wchar_t) -> cstring ---

	@(link_name="filter")
	_filter :: proc() ---
	@(link_name="nofilter")
	_nofilter :: proc() ---

	@(link_name="use_env")
	_use_env :: proc(bf: c.bool) ---
	@(link_name="use_tioctl")
	_use_tioctl :: proc(bf: c.bool) ---

	@(link_name="putwin")
	_putwin :: proc(win: _WINDOW, filep: [^]c.FILE) -> c.int ---
	@(link_name="getwin")
	_getwin :: proc(filep: [^]c.FILE) -> _WINDOW ---

	@(link_name="delay_output")
	_delay_output :: proc(ms: c.int) -> c.int ---
	@(link_name="flushinp")
	_flushinp :: proc() -> c.int ---
}

unctrl :: proc(ch: u32) -> string {
	return string(_unctrl(chtype(ch)))
}

wunctrl :: proc(wch: [^]cchar_t) -> [^]c.wchar_t {
	return _wunctrl(wch)
}

keyname :: proc(c_val: int) -> string {
	return string(_keyname(c.int(c_val)))
}

key_name :: proc(wc: c.wchar_t) -> string {
	return string(_key_name(wc))
}

filter :: proc() {
	_filter()
}

nofilter :: proc() {
	_nofilter()
}

use_env :: proc(bf: bool) {
	_use_env(c.bool(bf))
}

use_tioctl :: proc(bf: bool) {
	_use_tioctl(c.bool(bf))
}

putwin :: proc(win: WINDOW, filep: [^]c.FILE) -> int {
	return int(_putwin(win, filep))
}

getwin :: proc(filep: ^c.FILE) -> WINDOW {
	return WINDOW(_getwin(filep))
}

delay_output :: proc(ms: int) -> int {
	return int(_delay_output(c.int(ms)))
}

flushinp :: proc() -> int {
	return int(_flushinp())
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="newwin")
	_newwin :: proc(nlines, ncols, begin_y, begin_x: c.int) -> _WINDOW ---
	@(link_name="delwin")
	_delwin :: proc(win: _WINDOW) -> c.int ---
	@(link_name="mvwin")
	_mvwin :: proc(win: _WINDOW, y, x: c.int) -> c.int ---
	@(link_name="subwin")
	_subwin :: proc(orig: _WINDOW, nlines, ncols, begin_y, begin_x: c.int) -> _WINDOW ---
	@(link_name="derwin")
	_derwin :: proc(orig: _WINDOW, nlines, ncols, begin_y, begin_x: c.int) -> _WINDOW ---
	@(link_name="mvderwin")
	_mvderwin :: proc(win: _WINDOW, par_y, par_x: c.int) -> c.int ---
	@(link_name="dupwin")
	_dupwin :: proc(win: _WINDOW) -> _WINDOW ---
	@(link_name="wsyncup")
	_wsyncup :: proc(win: _WINDOW) ---
	@(link_name="syncok")
	_syncok :: proc(win: _WINDOW, bf: c.bool) -> c.int ---
	@(link_name="wcursyncup")
	_wcursyncup :: proc(win: _WINDOW) ---
	@(link_name="wsyncdown")
	_wsyncdown :: proc(win: _WINDOW) ---
}

newwin :: proc(nlines, ncols, begin_y, begin_x: int) -> WINDOW {
	return WINDOW(_newwin(c.int(nlines), c.int(ncols), c.int(begin_y), c.int(begin_x)))
}

delwin :: proc(win: WINDOW) -> int {
	return int(_delwin(win))
}

mvwin :: proc(win: WINDOW, y, x: int) -> int {
	return int(_mvwin(win, c.int(y), c.int(x)))
}

subwin :: proc(orig: WINDOW, nlines, ncols, begin_y, begin_x: int) -> WINDOW {
	return WINDOW(_subwin(orig, c.int(nlines), c.int(ncols), c.int(begin_y), c.int(begin_x)))
}

derwin :: proc(orig: WINDOW, nlines, ncols, begin_y, begin_x: int) -> WINDOW {
	return WINDOW(_derwin(orig, c.int(nlines), c.int(ncols), c.int(begin_y), c.int(begin_x)))
}

mvderwin :: proc(win: WINDOW, par_y, par_x: int) -> int {
	return int(_mvderwin(win, c.int(par_y), c.int(par_x)))
}

dupwin :: proc(win: WINDOW) -> WINDOW {
	return WINDOW(_dupwin(win))
}

wsyncup :: proc(win: WINDOW) {
	_wsyncup(win)
}

syncok :: proc(win: WINDOW, bf: bool) -> int {
	return int(_syncok(win, c.bool(bf)))
}

wcursyncup :: proc(win: WINDOW) {
	_wcursyncup(win)
}

wsyncdown :: proc(win: WINDOW) {
	_wsyncdown(win)
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="use_default_colors")
	_use_default_colors :: proc() -> c.int ---
	@(link_name="assume_default_colors")
	_assume_default_colors :: proc(fg, bg: c.int) -> c.int ---
}

use_default_colors :: proc() -> int {
	return int(_use_default_colors())
}

assume_default_colors :: proc(fg, bg: int) -> int {
	return int(_assume_default_colors(c.int(fg), c.int(bg)))
}


@(private)
@(default_calling_convention="c")
foreign lib {
	@(link_name="define_key")
	_define_key :: proc(definition: cstring, key_code: c.int) -> c.int ---
}

define_key :: proc(definition: string, key_code: int, allocator := context.temp_allocator) -> int {
	c_def := strings.clone_to_cstring(definition, allocator)
	defer delete(c_def, allocator)
	return int(_define_key(c_def, c.int(key_code)))
}


@(private)
convert_ptr :: proc(input: [^]$T, $U: typeid)  -> [^]U {
	#assert(size_of(T) == size_of(U), "T size mismatch")
	return ([^]U)(input)
}


@(private)
clone_to_wstring :: proc(s: string, allocator := context.temp_allocator) -> ([^]c.wchar_t, rawptr) {
	when size_of(c.wchar_t) == 2 {
		res, _ := utf16.encode_string_to_zero_terminated(s, allocator)
		return convert_ptr(raw_data(res), [^]c.wchar_t), rawptr(raw_data(res))
	} else {
		runes := utf8.string_to_runes(s, allocator)
		buffer := make([]rune, len(runes) + 1, allocator)
		copy(buffer, runes)
		buffer[len(runes)] = 0
		delete(runes, allocator)
		ptr := raw_data(buffer)
		return cast([^]c.wchar_t)rawptr(ptr), rawptr(ptr)
	}
}
