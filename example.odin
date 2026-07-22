package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import nc "ncurses"

// ---------------------------------------------------------
// Constants
// ---------------------------------------------------------

// Key codes used by ncurses
KEY_UP    :: 0o403
KEY_DOWN  :: 0o402
KEY_ENTER :: 10

// Color Pair Identifiers
CP_NORMAL   :: 1
CP_DIR      :: 2
CP_SELECTED :: 3
CP_STATUS   :: 4

// ---------------------------------------------------------
// Application State
// ---------------------------------------------------------
Explorer_State :: struct {
    current_dir:   string,
    entries:       [dynamic]os.File_Info,
    selected_idx:  int,
    scroll_offset: int,
    running:       bool,
}

// ---------------------------------------------------------
// Main Entry Point
// ---------------------------------------------------------
main :: proc() {
    // 1. Initialize Ncurses
    init_ncurses()
    defer nc.endwin() // Ensure terminal is restored on exit

    // 2. Initialize Application State
    state := Explorer_State{
        current_dir = strings.clone("."),
        running     = true,
    }
    defer {
        delete(state.current_dir)
        clear_entries(&state.entries)
        delete(state.entries)
    }

    load_dir(&state.entries, state.current_dir)

    // 3. Main Application Loop
    for state.running {
        // Free frame-local temporary allocations at the end of each iteration
        defer free_all(context.temp_allocator)

        nc.clear()

        draw_ui(&state)
        handle_input(&state)
    }
}

// ---------------------------------------------------------
// Rendering Routine
// ---------------------------------------------------------
draw_ui :: proc(state: ^Explorer_State) {
    max_y := nc.getmaxy(nc.stdscr)
    max_x := nc.getmaxx(nc.stdscr)

    // Draw Main Border
    nc.attron(nc.COLOR_PAIR(CP_NORMAL))
    nc.box(nc.stdscr, 0, 0)

    // Draw Title
    title := fmt.tprintf(" Explorer: %s ", state.current_dir)
    nc.mvprintw(0, (max_x - len(title)) / 2, "%s", title)

    // Calculate visible area for scrolling
    max_visible := max_y - 4

    // Update scroll offset to keep selected item visible
    if state.selected_idx < state.scroll_offset {
        state.scroll_offset = state.selected_idx
    } else if state.selected_idx >= state.scroll_offset + int(max_visible) {
        state.scroll_offset = state.selected_idx - int(max_visible) + 1
    }

    // Draw File List
    for i := 0; i < int(max_visible); i += 1 {
        actual_idx := state.scroll_offset + i
        if actual_idx >= len(state.entries) do break

        info := state.entries[actual_idx]
        is_selected := (actual_idx == state.selected_idx)

        // Set colors based on directory or selection status
        if is_selected {
            nc.attron(nc.COLOR_PAIR(CP_SELECTED))
        } else if info.type == .Directory {
            nc.attron(nc.COLOR_PAIR(CP_DIR))
        } else {
            nc.attron(nc.COLOR_PAIR(CP_NORMAL))
        }

        display_name := info.name
        if info.type == .Directory && info.name != ".." {
            display_name = fmt.tprintf("/%s", info.name)
        }

        line_y := i + 2
        line_fmt := pad_right(display_name, max_x - 4)
        nc.mvprintw(line_y, 2, "%s", line_fmt)

        if is_selected do nc.attroff(nc.COLOR_PAIR(CP_SELECTED))
    }

    // Draw Status Bar
    nc.attron(nc.COLOR_PAIR(CP_STATUS))
    status_bar := pad_right(" Arrows: Move | ENTER: Open | Q: Quit", max_x)
    nc.mvprintw(max_y - 1, 0, "%s", status_bar)
    nc.attroff(nc.COLOR_PAIR(CP_STATUS))

    nc.attron(nc.COLOR_PAIR(CP_NORMAL))
}

// ---------------------------------------------------------
// Input Logic
// ---------------------------------------------------------
handle_input :: proc(state: ^Explorer_State) {
    ch := nc.getch()

    switch ch {
    case 'q', 'Q':
        state.running = false

    case KEY_UP:
        if state.selected_idx > 0 {
            state.selected_idx -= 1
        }

    case KEY_DOWN:
        if state.selected_idx < len(state.entries) - 1 {
            state.selected_idx += 1
        }

    case KEY_ENTER, '\r':
        if len(state.entries) > 0 {
            selected := state.entries[state.selected_idx]

            if selected.type == .Directory {
                // Navigate into directory
                new_dir, _ := filepath.join({state.current_dir, selected.name}, context.temp_allocator)
                new_dir, _  = filepath.clean(new_dir, context.temp_allocator)

                delete(state.current_dir)
                state.current_dir = strings.clone(new_dir)

                load_dir(&state.entries, state.current_dir)
                state.selected_idx = 0
                state.scroll_offset = 0

            } else {
                // Open and stream file contents
                open_file_viewer(state, selected.name)
            }
        }
    }
}

// ---------------------------------------------------------
// Sub-Views: Streaming File Viewer
// ---------------------------------------------------------
open_file_viewer :: proc(state: ^Explorer_State, filename: string) {
    // FIX: Using default allocator for full_path so it persists across viewer loop iterations
    full_path, _ := filepath.join({state.current_dir, filename})
    defer delete(full_path)

    file_offset := 0
    viewing := true

    for viewing {
        defer free_all(context.temp_allocator)

        nc.clear()
        max_y := nc.getmaxy(nc.stdscr)
        max_x := nc.getmaxx(nc.stdscr)
        max_visible := max_y - 3

        handle, err := os.open(full_path, os.O_RDONLY)
        if err != nil {
            nc.mvprintw(2, 2, "%s", os.error_string(err))
            nc.getch()
            return
        }

        // Stream file using bufio reader
        stream := os.to_stream(handle)
        reader: bufio.Reader
        bufio.reader_init(&reader, stream, 4096, context.temp_allocator)

        line_idx := 0
        rendered_lines := 0

        // Read line by line without storing the full file in memory
        for {
            line_bytes, read_err := bufio.reader_read_slice(&reader, '\n')

            if read_err == .EOF && len(line_bytes) == 0 {
                break
            }

            line_str := string(line_bytes)
            line_str = strings.trim_right(line_str, "\r\n")

            if line_idx >= file_offset {
                if rendered_lines < int(max_visible) {
                    if len(line_str) > int(max_x - 4) {
                        line_str = line_str[:max_x - 4]
                    }
                    nc.mvprintw(rendered_lines + 1, 2, "%s", line_str)
                    rendered_lines += 1
                }
            }

            line_idx += 1

            if read_err != nil do break
        }

        bufio.reader_destroy(&reader)
        os.close(handle)

        // Draw Header & Status Bar
        nc.attron(nc.COLOR_PAIR(CP_STATUS))
        title := fmt.tprintf(" File: %s (Line %d) ", filename, file_offset + 1)
        nc.mvprintw(0, (max_x - len(title)) / 2, "%s", title)

        status_bar := pad_right(" UP/DOWN: Scroll | Q/ESC: Back", max_x)
        nc.mvprintw(max_y - 1, 0, "%s", status_bar)
        nc.attroff(nc.COLOR_PAIR(CP_STATUS))

        // Handle user input inside viewer
        ch := nc.getch()
        switch ch {
        case 'q', 'Q', 27: // 'q' or ESC
            viewing = false
        case KEY_UP:
            if file_offset > 0 {
                file_offset -= 1
            }
        case KEY_DOWN:
            if rendered_lines >= int(max_visible) {
                file_offset += 1
            }
        }
    }
}

// ---------------------------------------------------------
// Utility Procedures
// ---------------------------------------------------------

init_ncurses :: proc() {
    nc.initscr()
    nc.noecho()
    nc.curs_set(0)
    nc.keypad(nc.stdscr, true)

    if nc.has_colors() {
        nc.start_color()
        nc.init_pair(CP_NORMAL,   nc.COLOR_WHITE, nc.COLOR_BLACK)
        nc.init_pair(CP_DIR,      nc.COLOR_CYAN,  nc.COLOR_BLACK)
        nc.init_pair(CP_SELECTED, nc.COLOR_BLACK, nc.COLOR_WHITE)
        nc.init_pair(CP_STATUS,   nc.COLOR_BLACK, nc.COLOR_CYAN)

        nc.wbkgd(nc.stdscr, u32(nc.COLOR_PAIR(CP_NORMAL)))
    }
}

pad_right :: proc(s: string, width: int) -> string {
    if len(s) >= width do return s
    pad, _ := strings.repeat(" ", width - len(s), context.temp_allocator)
    return fmt.tprintf("%s%s", s, pad)
}

clear_entries :: proc(entries: ^[dynamic]os.File_Info) {
    for info in entries {
        os.file_info_delete(info, context.allocator)
    }
    clear(entries)
}

load_dir :: proc(entries: ^[dynamic]os.File_Info, path: string) {
    clear_entries(entries)

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
