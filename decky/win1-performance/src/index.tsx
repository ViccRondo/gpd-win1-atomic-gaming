import { callable, definePlugin, toaster } from "@decky/api";
import {
  DropdownItem,
  PanelSection,
  PanelSectionRow,
  staticClasses,
} from "@decky/ui";
import { useEffect, useState } from "react";
import { FaChartLine } from "react-icons/fa";

type Result = { ok: boolean; level: number; message: string };
type BrightnessResult = {
  ok: boolean;
  brightness?: number;
  maximum?: number;
  message?: string;
};
type BrightnessRegistration = { unregister?: () => void };

const getLevel = callable<[], number>("get_level");
const setLevel = callable<[number], Result>("set_level");
const setBrightness = callable<[number], BrightnessResult>("set_brightness");

let brightnessRegistration: BrightnessRegistration | undefined;
let brightnessTimer: ReturnType<typeof setTimeout> | undefined;
let lastBrightness: number | undefined;

function applyBrightness(value: unknown) {
  const normalized = Number(value);
  if (!Number.isFinite(normalized) || normalized === lastBrightness) return;
  lastBrightness = normalized;
  if (brightnessTimer) clearTimeout(brightnessTimer);
  brightnessTimer = setTimeout(() => {
    setBrightness(normalized).catch((error) => {
      console.warn("[Win1] brightness bridge failed", error);
    });
  }, 40);
}

function startBrightnessBridge() {
  brightnessRegistration?.unregister?.();
  const steamClient = (window as typeof window & {
    SteamClient?: {
      System?: {
        Display?: {
          RegisterForBrightnessChanges?: (
            callback: (event: { flBrightness: number }) => void,
          ) => BrightnessRegistration;
        };
      };
    };
  }).SteamClient;
  brightnessRegistration =
    steamClient?.System?.Display?.RegisterForBrightnessChanges?.((event) =>
      applyBrightness(event.flBrightness),
    );
}

const options = [
  { data: 0, label: "关闭" },
  { data: 1, label: "仅 FPS" },
  { data: 2, label: "顶部横条（推荐）" },
  { data: 3, label: "扩展信息" },
  { data: 4, label: "详细信息" },
];

function Content() {
  const [level, updateLevel] = useState(0);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    getLevel().then(updateLevel).catch(() => updateLevel(0));
  }, []);

  const apply = async (nextLevel: number) => {
    setBusy(true);
    try {
      const result = await setLevel(nextLevel);
      updateLevel(result.level);
      if (!result.ok) {
        toaster.toast({ title: "性能面板", body: result.message });
      }
    } catch (error) {
      toaster.toast({ title: "性能面板", body: `切换失败：${String(error)}` });
    } finally {
      setBusy(false);
    }
  };

  return (
    <PanelSection title="游戏内性能显示">
      <PanelSectionRow>
        <DropdownItem
          label="显示等级"
          description={busy ? "正在应用…" : "进入游戏后显示；不占用手柄按键"}
          rgOptions={options}
          selectedOption={level}
          disabled={busy}
          onChange={(option) => apply(Number(option.data))}
        />
      </PanelSectionRow>
    </PanelSection>
  );
}

export default definePlugin(() => ({
  name: "Win1 性能面板",
  titleView: <div className={staticClasses.Title}>Win1 性能面板</div>,
  content: <Content />,
  icon: <FaChartLine />,
  onDismount() {
    brightnessRegistration?.unregister?.();
    if (brightnessTimer) clearTimeout(brightnessTimer);
  },
}));

startBrightnessBridge();
