import fetch from '@system.fetch';
import preferences from '@ohos.data.preferences';
import { axiosInstance, AxiosResponse } from '../api/Api';
import abp,{ Auth, CurrentUser } from '../store/Abp';

interface ApplicationConfiguration {
    localization: Localization;
    auth: Auth;
    setting: Setting;
    currentUser: CurrentUser;
    features: Features;
    globalFeatures: GlobalFeatures;
    multiTenancy: MultiTenancy;
    currentTenant: CurrentTenant;
    timing: Timing;
    clock: Clock;
    objectExtensions: ObjectExtensions;
    extraProperties: Record<string, string|undefined>;
}

interface Localization {
    values: Record<string, Record<string, string>>;
    resources: Record<string, Resource>;
    languages: Language[];
    currentCulture: CultureInfo;
    defaultResourceName: string;
    languagesMap: Record<string, LanguageMapItem[]>;
    languageFilesMap: Record<string, LanguageMapItem[]>;
}

interface Resource {
    texts: Record<string, string>;
    baseResources: string[];
}

export interface Language {
    cultureName: string;
    uiCultureName: string;
    displayName: string;
    twoLetterISOLanguageName: string;
}

interface CultureInfo {
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

interface DateTimeFormat {
    calendarAlgorithmType: string;
    dateTimeFormatLong: string;
    shortDatePattern: string;
    fullDateTimePattern: string;
    dateSeparator: string;
    shortTimePattern: string;
    longTimePattern: string;
}

interface LanguageMapItem {
    name: string;
    value: string;
}

interface Setting {
    values: Record<string, string>;
}


interface Features {
    values: Record<string, string>;
}

interface GlobalFeatures {
    enabledFeatures: string[];
}

interface MultiTenancy {
    isEnabled: boolean;
}

interface CurrentTenant {
    id: string | null;
    name: string | null;
    isAvailable: boolean;
}

interface Timing {
    timeZone: TimeZone;
}

interface TimeZone {
    iana: IanaTimeZone;
    windows: WindowsTimeZone;
}

interface IanaTimeZone {
    timeZoneName: string;
}

interface WindowsTimeZone {
    timeZoneId: string;
}

interface Clock {
    kind: string;
}

interface ObjectExtensions {
    modules: Record<string, ModuleExtension>;
    enums: Record<string, EnumExtension>;
}

interface ModuleExtension {
    properties: Record<string, ExtensionProperty>;
    configuration: Record<string, string|undefined>;
}

interface EnumExtension {
    fields: Record<string, EnumField>;
    localization: Record<string, string>;
}

interface ExtensionProperty {
    type: string;
    attributes: Attribute[];
    configuration: Record<string, string|undefined>;
    ui: UIConfiguration;
}

interface Attribute {
    typeSimple: string;
    constructorArguments: string[]|undefined[];
    namedArguments: Record<string, string|undefined>;
}

interface UIConfiguration {
    onTable: UISetting;
    onCreateForm: UISetting;
    onEditForm: UISetting;
}

interface UISetting {
    isVisible: boolean;
}

interface EnumField {
    name: string;
    value: number | string;
}

class ApplicationConfigurationManager {
    private cache: ApplicationConfiguration | null = null;

    async init() {
        /*
        // 尝试从缓存中获取配置
        const cacheKey = 'application_configuration';
        const cachedData = await this.getFromPreferences(cacheKey);
        if (cachedData) {
            console.log('加载本地存储的应用配置');
            this.cache = JSON.parse(cachedData);
        } else {
            console.log('从API获取应用配置并缓存');
            await this.fetchApplicationConfiguration();
        }*/
        await this.fetchApplicationConfiguration();
    }

    async fetchApplicationConfiguration() {
        try {
            // 请求应用配置数据
            const token:string  =  AppStorage.get('access_token')??'';
            axiosInstance.defaults.headers.common['Authorization'] = `Bearer ${token}`;
            const response: AxiosResponse = await axiosInstance.get('/api/abp/application-configuration?IncludeLocalizationResources=false');
            if (response.status === 200) {
                this.cache = response.data;
                console.log('应用配置数据：' + JSON.stringify(this.cache));
                if (this.cache?.currentUser) {
                    abp.setCurrentUser(this.cache.currentUser)
                }
                if (this.cache?.auth) {
                    abp.setAuth(this.cache.auth)
                }

                // 保存配置到本地缓存
                await this.saveToPreferences('application_configuration', JSON.stringify(this.cache));
            } else {
                console.error(`获取应用配置失败，状态码：${response.status}`);
            }
        } catch (error) {
            console.error(`获取应用配置出错：${error}`);
        }
    }

    async getFromPreferences(key: string): Promise<string | null> {
        try {
            const preferencesHelper = await preferences.getPreferences(globalThis.context, 'application_configuration');
            const value = await preferencesHelper.getSync(key, null);
            return value as string | null;
        } catch (error) {
            console.error(`从偏好设置获取数据失败：${error}`);
            return null;
        }
    }

    async saveToPreferences(key: string, value: string): Promise<void> {
        try {
            const preferencesHelper = await preferences.getPreferences(globalThis.context, 'application_configuration');
            preferencesHelper.put(key, value);
            await preferencesHelper.flush();
        } catch (error) {
            console.error(`保存数据到偏好设置失败：${error}`);
        }
    }

    // 添加其他需要的方法，例如获取特定配置项
    getConfiguration(): ApplicationConfiguration | null {
        return this.cache;
    }

    // 获取 localization.languages 的方法
    getLanguages(): Language[] {
        if (this.cache && this.cache.localization && this.cache.localization.languages) {
            return this.cache.localization.languages;
        } else {
            return [];
        }
    }
}

const applicationConfigurationManager = new ApplicationConfigurationManager();
export default applicationConfigurationManager;