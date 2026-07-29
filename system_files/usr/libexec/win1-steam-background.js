let gameWasPresent = false;

function isGameWindow(window) {
    const resourceClass = String(window.resourceClass || "").toLowerCase();
    return resourceClass.includes("steam_app_") && window.normalWindow;
}

function isSteamWindow(window) {
    const resourceClass = String(window.resourceClass || "").toLowerCase();
    const caption = String(window.caption || "").toLowerCase();
    return !resourceClass.includes("steam_app_") &&
        (resourceClass === "steam" ||
         resourceClass.includes("steamwebhelper") ||
         caption.includes("steam"));
}

function updateSteamBackgroundState() {
    const windows = workspace.windowList();
    const gamePresent = windows.some(isGameWindow);
    const steamWindows = windows.filter(isSteamWindow);

    if (gamePresent) {
        for (const window of steamWindows) {
            window.keepAbove = false;
            window.minimized = true;
        }
    } else if (gameWasPresent) {
        const steamWindow = steamWindows[0];
        if (steamWindow) {
            steamWindow.minimized = false;
            workspace.activeWindow = steamWindow;
        }
    }

    gameWasPresent = gamePresent;
    setTimeout(updateSteamBackgroundState, 1000);
}

updateSteamBackgroundState();
