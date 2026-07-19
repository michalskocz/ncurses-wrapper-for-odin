package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import nc "ncurses"

KEY_UP    :: 0o403
KEY_DOWN  :: 0o402
KEY_ENTER :: 10

main :: proc() {
    nc.initscr()
    defer nc.endwin()

    nc.noecho()
    nc.curs_set(0)
    nc.keypad(nc.stdscr, true)

    if nc.has_colors() {
        nc.start_color()
        nc.init_pair(1, 7, 4)
        nc.init_pair(2, 3, 4)
        nc.init_pair(3, 0, 6)
        nc.init_pair(4, 7, 0)
        nc.wbkgd(nc.stdscr, nc.chtype(nc.COLOR_PAIR(1)))
    }

    current_dir := "."
    selected_idx := 0

    entries: [dynamic]os.File_Info
    defer delete(entries)
    load_dir(&entries, current_dir)

    running := true
    for running {
        nc.clear()

        max_y := nc.getmaxy(nc.stdscr)
        max_x := nc.getmaxx(nc.stdscr)

        nc.attron(nc.COLOR_PAIR(1))
        nc.box(nc.stdscr, 0, 0)

        title := fmt.ctprintf(" Eksplorator: %s ", current_dir)
        nc.mvprintw(0, (max_x - i32(len(title))) / 2, title)

        max_visible := max_y - 4

        for i in 0..<len(entries) {
            if i32(i) >= max_visible do break

            info := entries[i]
            is_selected := i == selected_idx

            if is_selected {
                nc.attron(nc.COLOR_PAIR(3))
            } else if info.type == .Directory {
                nc.attron(nc.COLOR_PAIR(2))
            } else {
                nc.attron(nc.COLOR_PAIR(1))
            }

            display_name := info.name
            if info.type == .Directory && info.name != ".." {
                display_name = fmt.tprintf("/%s", info.name)
            }

            line_y := i32(i) + 2
            nc.mvprintw(line_y, 2, fmt.ctprintf("%-*s", max_x - 4, display_name))

            if is_selected do nc.attroff(nc.COLOR_PAIR(3))
        }

        nc.attron(nc.COLOR_PAIR(4))
        nc.mvprintw(max_y - 1, 0, fmt.ctprintf("%-*s", max_x, "  Arrows: Muvment | ENTER: Open Dir | Q: Quit"))
        nc.attroff(nc.COLOR_PAIR(4))

        nc.attron(nc.COLOR_PAIR(1))

        ch := nc.getch()

        switch ch {
        case 'q', 'Q':
            running = false
        case KEY_UP:
            if selected_idx > 0 {
                selected_idx -= 1
            }
        case KEY_DOWN:
            if selected_idx < len(entries) - 1 {
                selected_idx += 1
            }
        case KEY_ENTER, '\r':
            if len(entries) > 0 {
                selected := entries[selected_idx]
                if selected.type == .Directory {
                    new_dir, _ := filepath.join({current_dir, selected.name})
                    new_dir, _ = filepath.clean(new_dir)
                    current_dir = strings.clone(new_dir)

                    load_dir(&entries, current_dir)
                    selected_idx = 0
                }
            }
        }

        free_all(context.temp_allocator)
    }
}

load_dir :: proc(entries: ^[dynamic]os.File_Info, path: string) {
    clear(entries)

    parent_info: os.File_Info
    parent_info.name = ".."
    parent_info.type = .Directory
    append(entries, parent_info)

    fd, err := os.open(path)
    if err == os.ERROR_NONE {
        defer os.close(fd)
        file_infos, _ := os.read_dir(fd, -1, context.allocator)
        for info in file_infos {
            append(entries, info)
        }
    }
}
