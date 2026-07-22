# ncurses Wrapper for Odin

A comprehensive and modular `ncurses` wrapper for the Odin programming language, bringing classic text user interface (TUI) capabilities to modern systems.

This wrapper imports most of the core functions, structures, and macros offered by the original C library, split into clean, maintainable modules.

## Quick Start (Hello World)

Here is a simple example to get a window up and running:

```odin
package main

import nc "ncurses"

main :: proc() {
    nc.initscr()
    defer nc.endwin()

    nc.mvprintw(10, 10, "Hello World !")
    c := rune(nc.getch())
}
```

## Advanced Example

The repository includes a complete TUI File Explorer application (`example.odin`) 

To run the explorer example, simply use:

```bash
odin run .
```
<img src="img=img/sc.png" alt="print scrin"/>
    
## Build and Run

Building projects using this wrapper follows the standard Odin workflow. No special flags or external build scripts are required, provided you have `ncurses` installed on your system:

```bash
odin build .
```

## Documentation & Resources

* **Official ncurses Manual:** [invisible-island.net/ncurses](https://invisible-island.net/ncurses/man/ncurses.3x.html)

## License

The wrapper code in this repository is dedicated to the public domain because its primary purpose is interacting with and loading functions from an external library.

The original `ncurses` library license can be found in the [ncurses/LICENSE](ncurses/LICENSE) file.
