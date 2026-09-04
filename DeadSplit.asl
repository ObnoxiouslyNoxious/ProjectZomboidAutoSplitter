/*
 * Project Zomboid LiveSplit Auto Splitter
 * Requires the DeadSplit Mod with LiveSplit Mode enabled in DeadSplit Settings
 * DeadSplit and Project Zomboid ASL created by ObnoxiouslyNoxious
 * https://github.com/ObnoxiouslyNoxious/ProjectZomboidAutoSplitter
 * https://steamcommunity.com/sharedfiles/filedetails/?id=3795485367
 */

state("ProjectZomboid64") {}

startup {
    settings.Add("resetMainMenu", true, "Reset when returning to Main Menu");
    settings.SetToolTip("resetMainMenu", "Resets an active LiveSplit attempt when Project Zomboid returns to its Main Menu.");
    settings.Add("populateSplits", true, "Automatically populate Category and Splits");
    settings.SetToolTip("populateSplits", "Replaces the current LiveSplit Category and Segment list with the active DeadSplit run when the timer starts.");
    settings.Add("syncAttemptCount", true, "Sync Attempt Counter with DeadSplit");
    settings.SetToolTip("syncAttemptCount", "Sets LiveSplit's own Attempt Count to match DeadSplit's Attempt Counter every time a run starts, instead of LiveSplit tracking its own separate count.");

    vars.FindTextComponent = (Func<dynamic, string, dynamic>)((state, label) => {
        foreach (dynamic component in state.Layout.Components) {
            if (component.GetType().Name == "TextComponent" && component.Settings.Text1 == label) {
                return component.Settings;
            }
        }
        return null;
    });

    vars.RunAlreadyMatches = (Func<string[], dynamic, bool>)((names, run) => {
        if (run.Count != names.Length) return false;
        for (int i = 0; i < names.Length; i++) {
            if (run[i].Name != names[i]) return false;
        }
        return true;
    });

    vars.PopulateSplits = (Func<string, string, bool, dynamic>)((categoryLabel, splitNamesCsv, force) => {
        string[] names = splitNamesCsv.Split(',');
        if (!force && vars.RunAlreadyMatches(names, timer.Run)) {
            if (categoryLabel != "" && timer.Run.CategoryName != categoryLabel) {
                timer.Run.GameName = "Project Zomboid";
                timer.Run.CategoryName = categoryLabel;
                timer.CallRunManuallyModified();
            }
            return false;
        }
        timer.Run.Clear();
        foreach (string name in names) {
            if (!string.IsNullOrWhiteSpace(name)) {
                timer.Run.AddSegment(name);
            }
        }
        if (categoryLabel != "") {
            timer.Run.GameName = "Project Zomboid";
            timer.Run.CategoryName = categoryLabel;
        }
        timer.CallRunManuallyModified();
        return true;
    });
}

init {
    vars.FilePath = Environment.ExpandEnvironmentVariables(@"%USERPROFILE%\Zomboid\Lua\DeadSplit\LiveSplitSignal.txt");
    vars.FileData = "";
    vars.RunKey = "";
    vars.RunKeyComponent = vars.FindTextComponent(timer, "Key:");
    vars.PendingPreview = "";

    if (System.IO.File.Exists(vars.FilePath)) {
        try {
            System.IO.File.WriteAllText(vars.FilePath, string.Empty);
        } catch {
        }
    }
}

update {
    vars.FileData = "";

    if (System.IO.File.Exists(vars.FilePath)) {
        try {
            vars.FileData = System.IO.File.ReadAllText(vars.FilePath).Trim();
            System.IO.File.WriteAllText(vars.FilePath, string.Empty);
        } catch {
        }
    }

    if (vars.FileData != "") {
        string[] signalParts = vars.FileData.Split('|');
        if (signalParts.Length >= 4
            && (signalParts[0] == "preview" || signalParts[0] == "start")
            && !string.IsNullOrWhiteSpace(signalParts[3])) {
            vars.RunKey = signalParts[3].Trim();
            if (vars.RunKeyComponent != null) {
                vars.RunKeyComponent.Text2 = vars.RunKey;
            }
        }

        if (signalParts[0] == "preview" && signalParts.Length >= 3) {
            vars.PendingPreview = vars.FileData;
        }

        if (signalParts[0] == "reset") {
            vars.RunKey = "";
            if (vars.RunKeyComponent != null) {
                vars.RunKeyComponent.Text2 = "";
            }
        }
    }

    if (vars.FileData == "reset|mainmenu"
        && settings["resetMainMenu"]
        && timer.CurrentPhase == TimerPhase.Ended) {
        var timerModel = new TimerModel() { CurrentState = timer };
        timerModel.Reset();
        vars.FileData = "";
    }

    if (settings["populateSplits"]
        && timer.CurrentPhase == TimerPhase.NotRunning) {
        string previewSignal = vars.FileData;
        if (previewSignal == "" && vars.PendingPreview != "") {
            previewSignal = vars.PendingPreview;
        }
        if (previewSignal != "") {
            string[] previewParts = previewSignal.Split('|');
            if (previewParts.Length >= 3
                && previewParts[0] == "preview"
                && previewParts[2] != "") {
                vars.PopulateSplits(previewParts[1], previewParts[2], false);
                vars.PendingPreview = "";
            }
        }
    }
}

start {
    string[] parts = vars.FileData.Split('|');
    if (parts.Length == 0 || parts[0] != "start") return false;

    if (settings["populateSplits"] && parts.Length >= 3 && parts[2] != "") {
        vars.PopulateSplits(parts[1], parts[2], false);
    }

    if (settings["syncAttemptCount"] && parts.Length >= 5 && parts[4] != "") {
        int attemptCount;
        if (int.TryParse(parts[4], out attemptCount)) {
            timer.Run.AttemptCount = attemptCount;
        }
    }

    return true;
}

split {
    return vars.FileData == "split";
}

reset {
    string[] parts = vars.FileData.Split('|');
    if (parts.Length == 0 || parts[0] != "reset") return false;
    if (parts.Length >= 2 && parts[1] == "mainmenu") return settings["resetMainMenu"];
    return true;
}
