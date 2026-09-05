# DeadSplit ASL Integration - Project Zomboid Auto Splitter for LiveSplit

Requires DeadSplit for Project Zomboid Build 42.20+ - [Download via the Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3795485367)

`DeadSplit.asl` populates DeadSplit's own in-game timer information into
[LiveSplit](https://livesplit.org/), so you can run LiveSplit as your visible
overlay/stream timer while the DeadSplit UI stays hidden.

## How it Works

DeadSplit has no direct way to talk to LiveSplit as Project Zomboid's Mod
scripting environment can't open network sockets. Instead, while **LiveSplit
Mode** is turned on in DeadSplit's Settings, the Mod writes a tiny signal
file (`LiveSplitSignal.txt`, in your `Zomboid/Lua/DeadSplit/` folder) every
time its own timer starts, splits, or resets. `DeadSplit.asl` polls that file
about 60 times a second and mirrors each signal into LiveSplit's own
start/split/reset actions.

DeadSplit sends your Run Category and Split list to LiveSplit when you select a Run Category in DeadSplit Settings. Every time a DeadSplit
run starts, the signal also carries the current run key into LiveSplit. The script rebuilds LiveSplit's split list (segment names, category, and game title) to match automatically, so you never need to manually type out or rebuild the split names yourself, even for categories where split names change per run. This only replaces the split list structure, not your saved comparison times. See Limitations below for how Personal Best/Best Segment data is tracked through your own .lsl files per category.

The Auto Splitter also resets an active attempt when Project Zomboid returns
to its main menu. Both this behaviour and automatic Category/Segment
population can be disabled independently in the Scriptable Auto Splitter
component's settings. Both settings are enabled by default.

## Setup

### Initial Setup:

- Download the DeadSplit.asl File (AutoSplitter) from the ProjectZomboidAutoSplitter Repository.
- (Optional) Download the DeadSplit.lsl File (Layout File) ProjectZomboidAutoSplitter Repository.

### LiveSplit Setup:

Option 1 (Manual):
1a. In LiveSplit: Right click your layout → **Edit Layout** → **+** →
   **Control** → **Scriptable Auto Splitter**.
2a. Double click on 'Scriptable Auto Splitter' to open its Settings. Point it at `DeadSplit.asl` (its location doesn't matter,
   leave it wherever's convenient).

Option 2 (Automatic):
1b. In LiveSplit: Right click your layout → **Edit Splits** → **Select 'Project Zomboid' from the 'Game Name' Menu** → **'OK'**
2b. Click Settings and adjust to your liking. Note that if 'Automatically Populate Category and Splits' is Disabled, you will need to open the previous Window and choose your Run Cateogry when switching Runs. If you leave it Enabled, DeadSplit will do this for you.

### DeadSplit Setup:

3. In DeadSplit's Settings screen (or via the right click/context DeadSplit menu),
   turn on **LiveSplit Mode**. This also hides DeadSplit's own UI panel
   automatically. Turning LiveSplit Mode back off restores whatever your
   Show/Hide DeadSplit UI setting was set to.
4. Select a Run Category in DeadSplit Settings. Ensure you hit 'APPLY' to set the Category and then start your run of choice. LiveSplit's timer should start, split, and
   reset in lockstep with it DeadSplit, no manual key presses needed
   in LiveSplit itself.

## Auto Splitter Settings

- **Reset when returning to Main Menu:** Resets an active LiveSplit attempt
  when Project Zomboid reaches its main menu. Disable this if you want an
  abandoned attempt to remain visible until you reset it manually.
- **Automatically populate Category and Splits:** Replaces LiveSplit's
  current Category and Segment list with the active DeadSplit run selected from DeadSplit Settings. Disable this to retain a manually maintained LiveSplit list.
- **Sync Attempt Counter with DeadSplit:** Sets LiveSplit's own Attempt Count
  to match DeadSplit's Attempt Counter every time a run starts. Disable this
  if you want LiveSplit to keep tracking its own separate attempt count
  instead.

LiveSplit also provides its standard Start, Split, and Reset action toggles.
Those control whether LiveSplit accepts each action at all; the three settings
above control DeadSplit-specific behaviour within those actions.

## Recommended Layout Components & Settings

```text
Layout Editor
├── Information 
│   ├── Title (Show Game Name: True / Show Category Name: True)
│   ├── Text (Left Text: 'Key:')
│   └── Detailed Timer (Timing Method: Real Time / Comparison 1: Current Comparison / Comparison 2: Best Segments)
├── List
│   └── Splits (Total Splits: 10 / Upcoming Splits: 8)
└── Control
    └── Scriptable Auto Splitter (Start: True / Split: True / Reset: True)

Settings (Right Click LiveSplit UI)
└── Compare Against (Personal Best: True / Real Time: True)
```

*All other Components in the Layout Editor are optional

## Limitations
- By Default, when you end a run which results in a new Personal Best or Best Segment Time, LiveSplit will prompt you to update your .lsl save file with these new times. The Auto-Splitters reset function does not support this functionality. As such, it is recommended to save/update your own .lsl files when a new Personal Best/Best Segment time is recorded **BEFORE** returning to the Main Menu. To do so: **Right click the LiveSplit UI** → **Save Splits** // Alternatively, you can disable 'Reset when returning to Main Menu' in Scriptable Auto Splitter settings. With this Setting disabled, you must Reset your run in LiveSplit manually.
- .lsl files cannot contain splits for multiple different run categories. It is recommended to save a separate .lsl file for each Category that you run.
- When switching between Run Categories, you will need to manually load the relevant .lsl file to populate the correct Personal Best/Best Segment times. To do so: **Right click the LiveSplit UI** → **Open Splits** → **Project Zomboid OR Open from File** → **Select the applicable Category/File**

## Notes

- The script's file path (`%USERPROFILE%\Zomboid\Lua\DeadSplit\LiveSplitSignal.txt`)
  resolves automatically for any Windows user.
- When the Auto Splitter attaches to Project Zomboid, it clears any signal
  left by an earlier session so an old event cannot start, split, or reset a
  new LiveSplit attempt.
- DeadSplit's own splits/PB comparisons (Run History, Best Segments, World
  Record) keep working exactly as before. LiveSplit Mode only adds the
  signal file and hides the redundant on-screen panel, it doesn't change how
  DeadSplit tracks or records runs.
- An uncompleted or failed run still signals LiveSplit to stop, the same as a
  completed run. It remains visible until you use Reset Run or return to the
  main menu with the main menu reset setting enabled.
