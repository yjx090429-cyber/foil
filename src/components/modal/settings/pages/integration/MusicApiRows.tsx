import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Group, Row, TextField, Button } from '../../kit';
import { getAllApiBases, setApiBaseInStorage } from '../../../../../services/onlineMusic/apiBaseStorage';
import type { SettingsGroupDef } from '../../kit';

// src/components/modal/settings/pages/integration/MusicApiRows.tsx
// 网页版 / iOS 版的音乐平台后端 API 地址配置。桌面版用内嵌后端，不需要这一页。
// 用户填好地址后，登录对应平台就会走这个地址。

const MUSIC_APIS: SettingsGroupDef = { id: 'musicApis', titleKey: 'options.settingsHeadingMusicApis' };

const PROVIDERS: { key: 'netease' | 'qq' | 'kugou'; labelKey: string; placeholder: string }[] = [
    { key: 'netease', labelKey: 'options.neteaseApiBase', placeholder: 'https://your-netease-api.example.com' },
    { key: 'qq', labelKey: 'options.qqApiBase', placeholder: 'https://your-qq-api.example.com' },
    { key: 'kugou', labelKey: 'options.kugouApiBase', placeholder: 'https://your-kugou-api.example.com' },
];

export const MusicApiRows: React.FC = () => {
    const { t } = useTranslation();
    const [values, setValues] = useState(getAllApiBases());

    const handleChange = (key: 'netease' | 'qq' | 'kugou', value: string) => {
        setValues(prev => ({ ...prev, [key]: value }));
    };

    const handleSave = (key: 'netease' | 'qq' | 'kugou') => {
        setApiBaseInStorage(key, values[key]);
    };

    return (
        <Group def={MUSIC_APIS}>
            <Row
                sub
                label={t('options.musicApiBaseHint')}
                hint={t('options.musicApiBaseDesc')}
            />
            {PROVIDERS.map(({ key, labelKey, placeholder }) => (
                <Row key={key} sub label={t(labelKey)}>
                    <TextField
                        type="url"
                        value={values[key]}
                        onChange={value => handleChange(key, value)}
                        placeholder={placeholder}
                    />
                    <Button onClick={() => handleSave(key)}>{t('options.save')}</Button>
                </Row>
            ))}
        </Group>
    );
};
