const candidates = workspace.windowList();
const gameWindow = candidates.find((window) => {
    const resourceClass = String(window.resourceClass || "").toLowerCase();
    return resourceClass.includes("steam_app_");
}) || candidates.find((window) => window.fullScreen && window.normalWindow);

if (gameWindow) {
    gameWindow.minimized = false;
    workspace.activeWindow = gameWindow;
}
