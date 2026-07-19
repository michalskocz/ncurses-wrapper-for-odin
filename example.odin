package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import nc "ncurses"

KEY_UP   :: 0o403
KEY_DOWN :: 0o402
KEY_ENTER :: 10

main :: proc() {
    nc.initscr()
    defer nc.endwin()

    nc.noecho()
    nc.curs_set(0)
    nc.keypad(nc.stdscr, true)

    if nc.has_colors() {
        nc.start_color()

        nc.init_pair(1, nc.COLOR_WHITE, nc.COLOR_BLACK)
        nc.init_pair(2, nc.COLOR_CYAN,  nc.COLOR_BLACK)
        nc.init_pair(3, nc.COLOR_BLACK, nc.COLOR_WHITE)
        nc.init_pair(4, nc.COLOR_BLACK, nc.COLOR_CYAN)

        nc.wbkgd(nc.stdscr, nc.chtype(nc.COLOR_PAIR(1)))
    }

    current_dir := strings.clone(".")
    defer delete(current_dir)

    selected_idx := 0
    scroll_offset := 0

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

        title := fmt.ctprintf(" Explorer: %s ", current_dir)
        nc.mvprintw(0, (max_x - i32(len(title))) / 2, title)

        max_visible := max_y - 4

        if selected_idx < scroll_offset {
            scroll_offset = selected_idx
        } else if selected_idx >= scroll_offset + int(max_visible) {
            scroll_offset = selected_idx - int(max_visible) + 1
        }

        for i := 0; i < int(max_visible); i += 1 {
            actual_idx := scroll_offset + i
            if actual_idx >= len(entries) do break

            info := entries[actual_idx]
            is_selected := actual_idx == selected_idx

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
        nc.mvprintw(max_y - 1, 0, fmt.ctprintf("%-*s", max_x, "  Arrows: Move | ENTER: Open | Q: Quit"))
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
                    new_dir, _ := filepath.join({current_dir, selected.name}, context.temp_allocator)
                    new_dir, _ = filepath.clean(new_dir, context.temp_allocator)

                    delete(current_dir)
                    current_dir = strings.clone(new_dir)

                    load_dir(&entries, current_dir)
                    selected_idx = 0
                    scroll_offset = 0
                } else {
                    full_path, _ := filepath.join({current_dir, selected.name}, context.temp_allocator)
                    full_path, _ = filepath.clean(full_path, context.temp_allocator)

                    data, err := os.read_entire_file(full_path, context.temp_allocator)
                    nc.clear()

                    if err != nil {
                        nc.mvprintw(2, 2, "Error: Could not read file.")
                    } else {
                        content := string(data)
                        lines := strings.split(content, "\n", context.temp_allocator)

                        for line, idx in lines {
                            if idx >= int(max_y - 4) do break
                            // Use %s via ctprintf to safely generate a null-terminated string for ncurses
                            nc.mvprintw(i32(idx) + 2, 2, fmt.ctprintf("%s", line))
                        }
                    }

                    nc.attron(nc.COLOR_PAIR(4))
                    nc.mvprintw(max_y - 1, 0, fmt.ctprintf("%-*s", max_x, "  Press any key to go back..."))
                    nc.attroff(nc.COLOR_PAIR(4))

                    nc.getch()
                }
            }
        }

        free_all(context.temp_allocator)
    }
}

load_dir :: proc(entries: ^[dynamic]os.File_Info, path: string) {
    for info in entries {
        os.file_info_delete(info, context.allocator)
    }
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
