# AGENTS.md — TrueWorktime

## File encoding (critical)

- All `.ahk` files are **UTF-16 LE** (Unicode). The read tool cannot decode them directly.
- Use `Get-Content -Encoding Unicode` in PowerShell to read/edit `.ahk` files.
- Do NOT re-save `.ahk` files as UTF-8; that will break `#Include` paths and comments.

## Architecture

```
TrueWorktime.ahk          # Entry point (#Include modules, Log class, main loop)
modules/
  Clock.ahk               # Always-on-top timer overlay GUI
  Config.ahk              # Tabbed settings dialog
  Item.ahk                # Window/task tracking (reads/writes data/items.csv)
  TrayMenu.ahk            # System tray icon & right-click menu
data/
  items.csv               # Per-window tracking records
  log.csv                 # Daily work-time log
Config.ini                # User settings (monitor, colors, work exe list)
Cache.ini                 # Runtime state (session counters)
```

## Build & run

- No build system, CI, tests, lint, or typecheck.
- Written for **AutoHotkey v2.0.11** (Windows only).
- Run: double-click `TrueWorktime.ahk` or launch the compiled `out/TrueWorkTime.exe`.
- Compiled `.exe` lives in `out/` (not tracked; `.gitignore`).

## Git notes

- `Config.ini` and `Cache.ini` are **tracked** but contain local user state — avoid committing personal settings or runtime values.
- `src/`, `out/`, `1.5/` are in `.gitignore` and contain build resources, compiled output, and a version snapshot respectively.
- Source comments are in Chinese (Simplified).

## Editing `.ahk` files

Example command to read a module:

```powershell
Get-Content -Encoding Unicode "D:\Project\TrueWorktime\modules\Clock.ahk"
```

Always verify encoding is preserved after edits by re-reading with `Get-Content -Encoding Unicode`.
