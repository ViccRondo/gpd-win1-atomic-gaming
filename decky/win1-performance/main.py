import asyncio
import glob
import json
import os
import stat

import decky


class Plugin:
    async def _patch_mangohud_battery_detection(self):
        matches = glob.glob(
            os.path.join(
                decky.DECKY_USER_HOME,
                ".local",
                "share",
                "flatpak",
                "runtime",
                "org.freedesktop.Platform.VulkanLayer.MangoHud",
                "x86_64",
                "*",
                "active",
            )
        )
        if not matches:
            decky.logger.warning("MangoHud runtime location was not found")
            return
        runtime = os.path.realpath(sorted(matches)[-1])
        for architecture in ("i386-linux-gnu", "x86_64-linux-gnu"):
            path = os.path.join(runtime, "files", "lib", architecture, "libMangoHud.so")
            try:
                with open(path, "rb") as handle:
                    data = handle.read()
                # MangoHud 0.8.4 only accepts power-supply names containing
                # uppercase BAT. The GPD Win 1 driver exposes
                # max170xx_battery. The compiler inlines this three-byte
                # matcher, so patch its unique instruction sequences for both
                # bundled architectures.
                common = (
                    (bytes.fromhex("668138424174"), bytes.fromhex("668138626174")),
                )
                if architecture == "i386-linux-gnu":
                    patches = common + (
                        (bytes.fromhex("516a4250e8"), bytes.fromhex("516a6250e8")),
                        (bytes.fromhex("80780254758a"), bytes.fromhex("80780274758a")),
                    )
                else:
                    patches = common + (
                        (
                            bytes.fromhex("488d50febe42000000e8"),
                            bytes.fromhex("488d50febe62000000e8"),
                        ),
                        (bytes.fromhex("807802547584"), bytes.fromhex("807802747584")),
                    )

                # Undo the earlier label-only workaround if present.
                if data.count(b"bat\0") == 1:
                    data = data.replace(b"bat\0", b"BAT\0", 1)

                changed = False
                for original, replacement in patches:
                    if data.count(original) == 1:
                        data = data.replace(original, replacement, 1)
                        changed = True
                    elif data.count(replacement) != 1:
                        decky.logger.warning(
                            "Unexpected MangoHud battery matcher for %s", architecture
                        )
                        changed = False
                        break
                if not changed:
                    continue
                metadata = os.stat(path)
                temporary = path + ".win1-new"
                with open(temporary, "wb") as handle:
                    handle.write(data)
                os.chmod(temporary, stat.S_IMODE(metadata.st_mode))
                os.chown(temporary, metadata.st_uid, metadata.st_gid)
                os.replace(temporary, path)
                decky.logger.info("Patched MangoHud battery detection for %s", architecture)
            except OSError as error:
                decky.logger.warning("Could not patch MangoHud battery detection: %s", error)

    def _paths(self):
        home = decky.DECKY_USER_HOME
        return (
            os.path.join(home, ".config", "MangoHud", "MangoHud.conf"),
            os.path.join(
                home,
                ".var",
                "app",
                "com.valvesoftware.Steam",
                ".config",
                "MangoHud",
                "MangoHud.conf",
            ),
            os.path.join(decky.DECKY_PLUGIN_SETTINGS_DIR, "level.json"),
        )

    def _read_level(self):
        try:
            with open(self._paths()[2], "r", encoding="utf-8") as handle:
                return int(json.load(handle).get("level", 0))
        except (FileNotFoundError, ValueError, TypeError, json.JSONDecodeError):
            return 0

    def _config(self, level):
        lines = [
            "# Managed by the Win1 Performance Decky plugin.",
            f"preset={level}",
            "position=top-left",
            "background_alpha=0.65",
            "round_corners=6",
            "font_size=18",
            "control=mangohud",
        ]
        if level >= 2:
            lines.extend(
                (
                    "cpu_temp",
                    "cpu_custom_temp_sensor=soc_dts0,temp1_input",
                    "gpu_temp=0",
                )
            )
        if level == 0:
            lines.append("no_display")
        return "\n".join(lines) + "\n"

    async def _run_control(self, *arguments):
        process = await asyncio.create_subprocess_exec(
            "/usr/bin/mangohudctl",
            *arguments,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL,
        )
        await process.communicate()

    async def get_level(self) -> int:
        return self._read_level()

    async def set_level(self, level: int):
        level = int(level)
        if level < 0 or level > 4:
            return {"ok": False, "level": self._read_level(), "message": "无效的显示等级"}

        host_config, flatpak_config, settings_path = self._paths()
        config = self._config(level)
        for path in (host_config, flatpak_config):
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as handle:
                handle.write(config)

        os.makedirs(os.path.dirname(settings_path), exist_ok=True)
        with open(settings_path, "w", encoding="utf-8") as handle:
            json.dump({"level": level}, handle)

        await self._run_control("toggle", "reload_config")
        await self._run_control("set", "no_display", "true" if level == 0 else "false")
        return {"ok": True, "level": level, "message": "已应用"}

    async def _main(self):
        await self._patch_mangohud_battery_detection()
        decky.logger.info("Win1 Performance loaded")

    async def _unload(self):
        pass
