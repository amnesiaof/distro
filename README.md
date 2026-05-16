# Distro

Discord Rich Presence for Balatro.

Forked from [dvrp0/distro](https://github.com/dvrp0/distro) with modern SMODS improvements.

## Features

- Shows current Ante and Round in Discord status
- Localization: English and Russian
- Configurable display options
- Modern SMODS API (JSON metadata, SMODS.load_file)

## Installation

1. Install [Steamodded](https://github.com/Steamodded/smods)
2. Copy the `Distro` folder to `%appdata%\Balatro\Mods\`
3. Launch the game

## Configuration

Edit `src/config.lua` in the mod folder to toggle what information is displayed.

## What's New (v2.0.0)

- Modern SMODS JSON format (no more header-style)
- Modular structure with src/ directory
- Config system (toggle ante, round, blind, money, etc.)
- Localization support (en-us, ru)
- Fixed Windows Discord IPC pipe connection
- Update throttling (doesn't spam Discord on every frame)
- Game over state handling
- Uses game's `localize()` function instead of raw file reads
