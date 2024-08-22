# Super Mania 64! Usage Guide

## Installation

[**DOWNLOAD HERE**](https://github.com/gingerphoenix10/Super-Mania-64/releases)

You can install Super Mania 64! like any other sm64coopdx mod. Drag and drop the folder from `Super Mania 64.zip` either into your game’s mod folder, the mods folder in `%appdata%\sm64ex-coop`, or you should be able to drag and drop it onto the main menu.

## Downloading Songs

I have completely reworked how packs are loaded into the game, meaning you can now have as many songs loaded at once as your drive can handle.  
Each pack is a separate mod but **requires** the base mod to run alongside it. All Mania packs should be marked with `[MANIA]` before the mod name, but that’s up to the pack creators to do. If you try to load a pack without Super Mania 64 installed, it will show a warning on the top-left of your screen, and the mod will disable itself.

You can download packs either using the install link above, or by [**clicking here**](https://github.com/gingerphoenix10/Super-Mania-64/releases).

## Controls

### Menu

- In the menu, you can use **D-PAD UP** and **D-PAD DOWN** to scroll through options. By default, blue is the selected option.
- You can also hold **D-PAD LEFT** or **D-PAD RIGHT** to change the font size while in song select. This will affect most text in the game.
- Pressing **A** will press the selected button. In the song select tab, this will start the song.
- Pressing **B** will return to the previous menu, unless on the title screen.

### In-Game

The in-game notes follow controls based on: `LEFT, DOWN, UP, RIGHT`.

- **LEFT**: D-PAD LEFT, X, JOYSTICK LEFT, C-LEFT
- **DOWN**: D-PAD DOWN, A, JOYSTICK DOWN, C-DOWN
- **UP**: D-PAD UP, Y, JOYSTICK UP, C-UP
- **RIGHT**: D-PAD RIGHT, B, JOYSTICK RIGHT, C-RIGHT
- **START**: Pause - Stops the current level and sends you to the Song Select screen

## Configuration

Most configuration is done in the `Options` tab, other than the core gameplay `hitDistanceUP` and `hitDistanceDOWN` variables, which control how close a note has to be for you to be able to hit it.  
Those variables can be configured in the `AdvancedConfig.lua` file. Defaults:
hitDistanceUP = 30
hitDistanceDOWN = 100

## Pack Information

- **FNF Pack 1** and **FNF Pack 2** are both packs featuring FNF songs that were ported to Super Mania 64, picked out by Toadeight, DropDMike75, and Me. As of right now, you can only play on the Hard difficulty (besides Funhouse which only has 1 difficulty), and you can only play as Boyfriend (right side notes).
- **The Original Pack** features the songs and charts from my original Mania! Clone for the web browser, that isn’t yet published. These songs are NOT complete and only have a few seconds of notes at max.

### FNF Pack 1 Tracks:
- Repressed from Soft Mod
- King Hit from Wii Funkin’ Wiik 3
- Take A Swig of This from Hazy River

### FNF Pack 2 Tracks:
- Nyaw from Arcade Showdown
- Funhouse from the Classified mod (sm64 mod)

### Original Pack Tracks:
- Clinozoisite by Ludicin
- Aegleseeker by Silentroom (song for Arcaea)
- Hello (BPM) 2024 by Camellia
- Cyberia B-Side by Nicopatty (song for Nico’s Nextbots)

## Upcoming / Not yet Implemented Features

- Better UI
- Hold Notes
- Multiplayer(?)
- If it’s actually possible, more than 30 fps would be nice
- In-Game configuration

## Troubleshooting

- **Starting (N) song puts a segmentation fault error on the screen**  
  This happens when you attempt to load a song, but the music file is missing. The error screen is a bug with sm64coopdx and may be fixed.
- **Starting (N) song puts a red error at the top of the screen**  
  For whatever reason, the song you are trying to play is corrupted. In the future, this may show up if the error above this is caused.
- **I can’t see hold notes**  
  Hold notes not implemented yet.
- **The notes aren’t synced with the music properly**  
  You can adjust your input offset in Options.
- **A red error shows at the top of the screen when starting the mod**  
  You’ve probably messed up your config somehow. Go to `%appdata%\sm64ex-coop\sav` and delete the `Super Mania 64!.sav` file.

## Where can I download the mod and packs?

By [**clicking here**](https://github.com/gingerphoenix10/Super-Mania-64/releases).

## How can I make a pack?

As the mod is still in development, packs aren't done yet, so there are currently no tools for making charts yet.

If you *really* want to make a pack, the main.lua file is the same in every pack, other than the name at the top of the of each file. The main.lua files *does* get updates a lot though, so it may get outdated within a few updates.
The LEVEL_NAME.lua files just define the chart table to CHART_NAME. The chart's *format* is pretty easy to understand by looking at existing packs. It's a table with the keys as times in milliseconds, and the value as a table of notes that spawn at that millisecond.
The notes have 2 values: Lane and Speed. Lane is a number from 1-4, that changes the... lane the note spawns on
The speed value isn't done yet, but will multiply the note's falling pixels per second by the value.
The Levels.lua file just contains a table called "Levels", that stores the CHART_NAME values.

## Need more help?

Message me (preferably on discord) or ping me, and I’ll try and help. I use the name “@gingerphoenix10” on everything.

Alternatively, if it's a bug with the mod, you can also either submit an issue, or a pull request it you know what the issue is.

Contributions always appreciated :)