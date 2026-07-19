package ncurses

import "core:c"

WINDOW :: [^]_win_st
SCREEN :: rawptr


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
    _parent:      WINDOW,         /* pointer to parent if a sub-window */

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
cchar_t_ptr :: rawptr

MEVENT :: struct {
    id:     c.short,
    x:      c.int,
    y:      c.int,
    z:      c.int,
    bstate: mmask_t,
}


TERMINAL :: rawptr
