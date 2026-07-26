const candidates = workspace.windowList();
const steamWindow = candidates.find((window) => {
    const resourceClass = String(window.resourceClass || "").toLowerCase();
    const caption = String(window.caption || "").toLowerCase();
    return !resourceClass.includes("steam_app_") &&
        (resourceClass === "steam" ||
         resourceClass.includes("steamwebhelper") ||
         caption.includes("steam"));
});

if (steamWindow) {
    steamWindow.minimized = false;
    steamWindow.keepAbove = true;
    workspace.activeWindow = steamWindow;
    setTimeout(() => {
        steamWindow.keepAbove = false;
    }, 300);
}
