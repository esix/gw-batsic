# Not implementable in batch

GW-BASIC was written for the IBM PC running real-mode DOS in 1983.  A lot
of its surface area depends on that environment in ways a `cmd.exe` script
running under modern Windows fundamentally can't reach.  This page is
the honest list of what we will not be implementing, grouped by
*why*.  Anything not on this list either is implemented (see the earlier
articles) or is on the to-do queue.

## Direct memory & port I/O

Modern Windows runs every batch script in ring 3 with no port access and
no flat-real-mode memory; the 8086 address space simply doesn't exist
for us.  Everything here either reads or writes specific bytes by
address, or executes hand-assembled x86 code — neither has any meaning
in our host.

| Keyword | What it did |
|---|---|
| `PEEK(addr)` | Read one byte from memory.  Used heavily to inspect BASIC's own internal state at documented offsets, or read the CGA text buffer at `&HB800`. |
| `POKE addr, byte` | Write one byte.  Used to draw text via the video buffer, alter BASIC's variable storage, install ISR handlers, etc. |
| `DEF SEG = seg` | Set the 16-bit segment for subsequent PEEK/POKE/BLOAD.  Segments are part of x86 real-mode addressing. |
| `VARPTR(var)` | Return the address of a variable's storage so the program can POKE into it.  Our variables aren't in any address space. |
| `VARPTR$(var)` | Return a packed-string version of the same address (used by `PLAY` and `DRAW` to take variable-string arguments). |
| `BLOAD "name", offset` | Load a binary blob from disk into memory at offset.  Used for sprites, fonts, screen captures.  Conceptually fakeable as a byte array, but the *point* of BLOAD was to splat into video memory or a TSR. |
| `BSAVE "name", offset, len` | Save a memory block to a file.  Same problem inverted. |
| `INP(port)` | `IN AL, dx` — read a hardware I/O port.  Used to query the keyboard controller, sound chip registers, the serial UART, etc. |
| `OUT port, byte` | `OUT dx, AL`.  Same. |
| `WAIT port, mask [, xor]` | Spin until `INP(port) AND mask XOR xor` is non-zero.  Hardware polling. |
| `USR0(arg)`..`USR9(arg)` | Call a user-supplied machine-code routine.  We can't execute arbitrary bytes as x86 instructions. |
| `DEF USR0 = offset` | Register the entry offset of a USR routine. |
| `CALL var(args)` | Call a machine-code routine whose entry point is in `VARPTR(var)`. |
| `CALLS var(args)` | Same but passes args by value via stack. |

## Graphics

We don't have a framebuffer.  A modern terminal renders text — there is
no pixel-addressable surface to draw to, no display modes to switch
between, no palette to remap.  Hosting the interpreter inside an actual
graphics window (Win32 GDI, a GUI toolkit, an HTML canvas) would unlock
this whole block, but doing so is a project of its own and well outside
the "batch interpreter" scope.

| Keyword | What it did |
|---|---|
| `SCREEN mode` | Switch between text and graphics modes: 40×25 text, 80×25 text, 320×200 4-colour CGA, 640×200 mono, 640×350 16-colour EGA, 640×480 VGA. |
| `LINE (x1,y1)-(x2,y2) [, c [, B[F]]]` | Draw a line, or a hollow/filled rectangle when `B`/`BF` is given. |
| `CIRCLE (x,y), r [, c [, start, end [, aspect]]]` | Draw a circle, arc, or ellipse. |
| `DRAW "U10 R10 D10 L10 BM x,y …"` | Turtle-style drawing from a command string. |
| `PAINT (x,y) [, c [, border]]` | Flood-fill from a point. |
| `PSET (x,y) [, c]` | Set a pixel. |
| `PRESET (x,y) [, c]` | Clear a pixel (or set to background). |
| `POINT(x,y)` | Read a pixel's colour. |
| `PALETTE n, c` | Remap colour register `n` to attribute `c`. |
| `PALETTE USING arr(...)` | Bulk-remap the palette from an array. |
| `VIEW [SCREEN] (x1,y1)-(x2,y2) [, c [, b]]` | Set a graphics viewport. |
| `WINDOW [SCREEN] (x1,y1)-(x2,y2)` | World-coordinate mapping inside the viewport. |
| `PMAP coord, fn` | Convert between window and physical coords. |
| `GET (x1,y1)-(x2,y2), arr` | Capture a screen region into an array. |
| `PUT (x,y), arr [, action]` | Blit an array back to the screen. |
| `PCOPY src, dst` | Copy between screen pages. |

`COLOR fg, bg, border` in text mode could be approximated via ANSI
escape codes and we may do that eventually.  In graphics modes it
selects palette indices, which has no meaning without a palette.

## Light pen, joysticks, music

These read inputs and produce outputs that need real PC hardware (or
exact emulation of it).

| Keyword | What it did |
|---|---|
| `PEN(n)` | Light pen position / button state.  The light pen is a 1980s technology that doesn't exist on modern displays. |
| `STICK(n)` | Joystick axis position (0–3 = X/Y of each of two sticks). |
| `STRIG(n)` | Joystick button state. |
| `ON STRIG(n) GOSUB line` | Event trapping for joystick button. |
| `STRIG ON/OFF/STOP` | Enable/disable joystick trapping. |
| `SOUND freq, duration` | PC speaker tone at `freq` Hz for `duration` ticks (1/18.2 s).  The PC speaker is gone; we can approximate with `[Console]::Beep` via PowerShell, but the timing and frequency response are very different. |
| `PLAY "music-string"` | A small music DSL ("CDEFGAB", octaves, tempo, etc.) for the PC speaker.  Same problem as SOUND but harder — the "music" notion only makes sense if the underlying tone generator is faithful. |
| `ON PLAY(n) GOSUB line` | Trap when the music background queue drops below `n` notes. |
| `PLAY ON/OFF/STOP` | Enable/disable music trap. |

## Communications

The COM/LPT port file model still exists on modern Windows, but the
programs that target it expect specific 1986-era register behaviour,
buffering, and signalling.

| Keyword | What it did |
|---|---|
| `OPEN "COM1:..."` | Open the first serial port with given baud/parity/stop/handshake settings.  Modern Windows treats `COM1:` as a device but most machines no longer have one and the wire protocol expectations are dated. |
| `OPEN "LPT1:..."` | Open the parallel port. |
| `IOCTL #file, string` | Send a driver-specific control string. |
| `IOCTL$(#file)` | Read a driver-specific status string. |
| `ON COM(n) GOSUB line` | Event trap for serial-port data ready. |
| `COM(n) ON/OFF/STOP` | Enable/disable COM trapping. |

## Partial / authenticity loss

These we *could* do — but the result would be a degraded approximation,
not the GW-BASIC behaviour.  Listed here so it's clear up front what
you'd be giving up.

| Keyword | Approximate via | What's lost |
|---|---|---|
| `INKEY$` | PowerShell `[Console]::KeyAvailable` + `ReadKey` | Multi-byte sequences (arrow keys, function keys) come back differently.  Blocking vs non-blocking behaviour around terminal echo and line buffering is hard to match. |
| `LOCATE row, col` | ANSI escape `\033[r;cH` | Only works on terminals that interpret ANSI; "legacy" `cmd.exe` consoles may not. |
| `CSRLIN`, `POS(0)` | Cursor row/column queries | We track our own column in `_print_col`, but row is harder without a virtual screen buffer.  POS works for text the interpreter wrote; doesn't catch external output. |
| `SCREEN(row, col [, colorflag])` | Read character at screen position | Requires keeping our own shadow screen buffer — possible but invasive, and any external program writing to the console invalidates it. |
| `KEY n, str$` + the function-key label line | Soft-label tracking | We can store the labels but there's no 25th-row of the screen we can paint them on. |
| `KEY ON/OFF/LIST` | Same | Same — the "label row" concept doesn't exist. |
| `WIDTH n` | Adjust our own `_print_col` wrap math | The actual terminal is whatever size the user resized their window to.  We can wrap our own output, but anything the OS writes (errors, command echoes) won't respect our setting. |
| `WIDTH "LPT1:", n` | — | LPT printing isn't realistic. |
| `LLIST`, `LPRINT` | Pipe to `print` or write to file | Printer is no longer a "device file" in any useful sense on modern Windows. |

## Why this list exists

Every keyword above has the same property: implementing it would
require either (a) emulating 1980s PC hardware, or (b) hosting the
interpreter inside something other than `cmd.exe`.  Both are valid
projects but neither is *this* project.

If you have a GW-BASIC program that uses any of the above and you want
it to run, your options are roughly:

- For graphics: target a different host (a Win32 program, a web page).
  The lexer, parser, and executor parts of this project are mostly
  reusable — just swap the RTL handlers.
- For memory/port stuff: rewrite the program to express the *intent*
  without `PEEK`/`POKE`.  Most of the time these were used to do
  something — fast text output, custom input handling, etc. — that
  has a portable equivalent.
- For COM/LPT/sound: same idea, rewrite to use a modern equivalent.
