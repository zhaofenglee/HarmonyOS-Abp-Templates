import fetch from '@system.fetch';
import preferences from '@ohos.data.preferences';
import { i18n } from '@kit.LocalizationKit';
import { axiosInstance, AxiosResponse } from '../api/Api';

type Texts = Record<string, string>;

interface Resource {
    texts: Texts;
    baseResources: string[];
}

type Resources = Record<string, Resource>;

interface DateTimeFormat {
    calendarAlgorithmType: string;
    dateTimeFormatLong: string;
    shortDatePattern: string;
    fullDateTimePattern: string;
    dateSeparator: string;
    shortTimePattern: string;
    longTimePattern: string;
}

interface CurrentCulture {
    displayName: string;
    englishName: string;
    threeLetterIsoLanguageName: string;
    twoLetterIsoLanguageName: string;
    isRightToLeft: boolean;
    cultureName: string;
    name: string;
    nativeName: string;
    dateTimeFormat: DateTimeFormat;
}

interface LocalizationCache {
    resources: Resources;
    currentCulture: CurrentCulture;
}

class LocalizationManager {
    private cache: LocalizationCache | null = null;


    async init() {
        // 获取语言
        let systemLanguage:string =  await AppStorage.get('User_Language') as string
        if (!systemLanguage) {
            console.log('获取系统语言');
            // 获取系统语言
            systemLanguage = i18n.System.getSystemLanguage();  // systemLanguage为当前系统语言
            if (systemLanguage=="") {
                systemLanguage = this.getDefaultLanguage();
            }
            AppStorage.setOrCreate('User_Language', systemLanguage)
        }

        /*
        const cacheKey = `localization_${systemLanguage}`;
        console.log('尝试获取本地化:'+systemLanguage)
        const cachedData = await this.getFromPreferences(cacheKey);
        if (cachedData) {
            console.log('加载本地存储'+cachedData);
            this.cache = JSON.parse(cachedData);
        } else {
            console.log('从API获取本地化资源并缓存');
            await this.fetchLocalizationData(systemLanguage);
        }*/
        //每次都通过Api获取本地化
        await this.fetchLocalizationData(systemLanguage);
    }

    private getDefaultLanguage(): string {
        return 'zh-Hans';
    }

    async fetchLocalizationData(language: string) {
        try {
            const response: AxiosResponse = await axiosInstance.get(`/api/abp/application-localization?CultureName=${language}`);
            if (response.status === 200) {
                this.cache = response.data;
                console.log('cache:'+JSON.stringify(this.cache));
                await this.saveToPreferences(`localization_${language}`, JSON.stringify(this.cache));
            }
            else {
                console.error(`Failed to fetch localization data. Code: ${response.status}`);
            }
        } catch (error) {
            console.error(`Error fetching localization data: ${error}`);
        }
    }

    async getFromPreferences(key: string): Promise<string | null> {
        try {
            const preferencesHelper = await preferences.getPreferences(globalThis.context, 'localization');
            const value = await preferencesHelper.getSync(key,null);
            return value as string | null;
        } catch (error) {
            console.error(`Failed to get data from preferences: ${error}`);
            return null;
        }
    }

    async saveToPreferences(key: string, value: string): Promise<void> {
        try {
            const preferencesHelper = await preferences.getPreferences(globalThis.context, 'localization');
            preferencesHelper.put(key, value);
            await preferencesHelper.flush();
        } catch (error) {
            console.error(`Failed to save data to preferences: ${error}`);
        }
    }

    getLocalized(formattedString: string): string {
        const splitIndex = formattedString.indexOf('::');
        if (splitIndex === -1) {
            return formattedString;
        }

        const module = formattedString.substring(0, splitIndex);
        const key = formattedString.substring(splitIndex + 2);
        if (!this.cache || !this.cache.resources[module]) {
            return formattedString;
        }

        const resource = this.cache.resources[module];
        return resource.texts[key] || formattedString;
    }
}

const localizationManager = new LocalizationManager();
const l = localizationManager;
export default localizationManager;