import { Capacitor } from '@capacitor/core';

// 当前文件：统一描述 Web、Electron 与 Capacitor iOS 的运行时能力。

export type RuntimeEnvironment = 'web' | 'electron' | 'capacitor-ios';

export const hasElectronBridge = (): boolean => (
  typeof window !== 'undefined'
  && Boolean((window as typeof window & { electron?: unknown }).electron)
);

export const isCapacitorIos = (): boolean => (
  typeof window !== 'undefined'
  && Capacitor.isNativePlatform()
  && Capacitor.getPlatform() === 'ios'
);

export const getRuntimeEnvironment = (): RuntimeEnvironment => {
  if (hasElectronBridge()) return 'electron';
  if (isCapacitorIos()) return 'capacitor-ios';
  return 'web';
};

// iOS WebView 下本地音乐导入走系统文件选择器，仍可用；这里保留接口以兼容桌面端判断。
export const supportsLocalMusicImport = (): boolean => true;
