# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Neovim plugin (Lua) that manages debug configurations for nvim-dap. It lets users define debug targets (executables/scripts), argument presets, and type groupings, then converts them into DAP launch configs. The config is persisted to `.debug_config.json` in the project root.

## Commands

### Run tests
Tests use `mini.test` and must be run from within Neovim:
```
:lua MiniTest.run_file('tests/test_target.lua')
:lua MiniTest.run_file('tests/test_args.lua')
```

### Build test executables (C++)
```bash
cd dbg_test_execs && just build-cpp      # configure + build
cd dbg_test_execs && just rebuild-cpp    # clean + build
cd dbg_test_execs && just clean-cpp      # remove build dir
```

Rust targets are built via Cargo in `dbg_test_execs/rust/`. Python targets need no build step.

## Architecture

The plugin is structured in four layers:

**Data model** (`DbgConfig`, `DbgType`, `DbgTarget`, `DbgArguments`, `Enum`) — All models use Lua metatables for OOP. Each class has `new(opts)` for creating from scratch and `from_table(t)` for deserializing from JSON. `DbgConfig` is the root container; it holds a list of `DbgType`s; each type holds a list of `DbgTarget`s; each target holds a list of `DbgArguments`.

**Config I/O** (`config.lua`) — Reads/writes `.debug_config.json` using the JSON encoder/decoder configured in `plugin_config.lua`. The global `require('dbg_interface').local_dbg_config` holds the in-memory state.

**Actions** (`actions/add.lua`, `edit.lua`, `remove.lua`, `clone.lua`) — Each action is an async function (via `plenary.async`) that accepts `(dbg_config, callback)`. It uses `select.lua` for Snacks-based pickers, then opens `EditWin` for JSON editing. Actions never mutate the config in place — they produce a new config and return it via `callback(new_config)`.

**Integration** (`dap.lua`) — `to_dap_config(dbg_config)` converts the internal model to the list format expected by nvim-dap.

**Keymaps** (`keymaps.lua`) — Default bindings under `<leader>D*`. The `bind()` helper wires each action to load the current config, call the action, and persist the result on success.

## Key patterns

- **Async flow**: `plenary.async.wrap()` converts callback-based Neovim APIs into awaitable calls. Actions are run with `plenary.async.run()`.
- **EditWin**: Opens a temp buffer with pretty-printed JSON; on `:w` the buffer content is parsed and returned; on window close it cancels. This is the primary editing mechanism.
- **Picker fallback**: `select.lua` auto-selects when there is only one option; otherwise shows a Snacks picker.
- **Plugin config**: `plugin_config.lua` stores the merged user config and is accessed via `require('dbg_interface.plugin_config').get()`. The JSON encoder/decoder and EditWin split direction are user-overridable here.

## Setup signature

```lua
require('dbg_interface').setup({
    edit_win = { window = { split = "below", win = -1 } },
    json     = { encode = vim.json.encode, decode = vim.json.decode },
    keymaps  = { add_target = '<leader>Dax', ... },  -- override defaults
    debug_types = { ... },  -- passed through to DAP adapter config
})
```
