// iOS/Capacitor 运行时的音乐平台 API 地址配置
// 桌面版用内嵌后端，网页/ iOS 版需要用户自己部署 API 并在这里配置地址。

const STORAGE_KEYS = {
    netease: 'folia.apiBase.netease',
    qq: 'folia.apiBase.qq',
    kugou: 'folia.apiBase.kugou',
} as const;

type Provider = 'netease' | 'qq' | 'kugou';

const readStorage = (key: string): string | null => {
    if (typeof localStorage === 'undefined') return null;
    const value = localStorage.getItem(key);
    if (typeof value !== 'string' || !value.trim()) return null;
    return value.trim().replace(/\/$/, '');
};

const writeStorage = (key: string, value: string): void => {
    if (typeof localStorage === 'undefined') return;
    const trimmed = value.trim().replace(/\/$/, '');
    if (trimmed) {
        localStorage.setItem(key, trimmed);
    } else {
        localStorage.removeItem(key);
    }
};

export const getApiBaseFromStorage = (provider: Provider): string | null =>
    readStorage(STORAGE_KEYS[provider]);

export const setApiBaseInStorage = (provider: Provider, value: string): void => {
    writeStorage(STORAGE_KEYS[provider], value);
};

export const getAllApiBases = (): Record<Provider, string> => ({
    netease: getApiBaseFromStorage('netease') ?? '',
    qq: getApiBaseFromStorage('qq') ?? '',
    kugou: getApiBaseFromStorage('kugou') ?? '',
});
