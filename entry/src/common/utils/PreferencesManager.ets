// PreferencesHelper.ets
import { preferences } from "@kit.ArkData";
import { TextJsonSerializer } from "./TextJsonSerializer";

export class PreferencesManager {

  getPreference(name:string,key: string): preferences.ValueType | null {
    try {
      let options: preferences.Options = { name: name };
      const preferencesHelper =  preferences.getPreferencesSync(getContext().getApplicationContext(), options);
      const value =  preferencesHelper.getSync(key,null);
      return value ;
    } catch (error) {
      console.error(`Failed to get data from preferences: ${error}`);
      return null;
    }
  }

  async getPreferenceAsync(name:string,key: string): Promise<preferences.ValueType | null> {
    try {
      let options: preferences.Options = { name: name };
      const preferencesHelper = await preferences.getPreferences(getContext().getApplicationContext(), options);
      const value = await preferencesHelper.get(key, null);
      return value ;
    } catch (error) {
      console.error(`Failed to get data from preferences: ${error}`);
      return null;
    }
  }

  get(name:string,key: string) :string|null {
    const value = this.getPreference(name,key);
    if (typeof value === "string") {
      return value;
    }
    else
      return null;
  }

  async getAsync(name:string,key: string) :Promise<string|null> {
    const value = await this.getPreferenceAsync(name,key);
    if (typeof value === "string") {
      return value;
    }
    else
      return null;
  }

  getNumber(name:string,key: string) :number|null {
    const value = this.getPreference(name,key);
    if (typeof value === "number") {
      return value;
    }
    else
      return null;
  }

  async getNumberAsync(name:string,key: string) :Promise<number|null> {
    const value = await this.getPreferenceAsync(name,key);
    if (typeof value === "number") {
      return value;
    }
    else
      return null;
  }

  getMap(name:string,key: string) :Map<string, Object> {
    const value = this.getPreference(name,key);
    if (typeof value === "string") {
      return TextJsonSerializer.jsonToMap(value);
    }
    else
      return new Map;
  }

  async getMapAsync(name:string,key: string) :Promise<Map<string, Object>|null> {
    const value = await this.getPreferenceAsync(name,key);
    if (typeof value === "string") {
      return TextJsonSerializer.jsonToMap(value);
    }
    else
      return null;
  }

  set(name:string,key: string, value:object) :void {
    this.setPreference(name,key,TextJsonSerializer.jsonStringify(value))
  }

  async setAsync(name:string,key: string, value:object) :Promise<void> {
    this.setPreferenceAsync(name,key,TextJsonSerializer.jsonStringify(value))
  }

  setMap(name:string,key: string, value: Map<string, Object>) :void {
    this.setPreference(name,key,TextJsonSerializer.jsonStringify(value))
  }

  async setMapAsync(name:string,key: string, value: Map<string, Object>) :Promise<void> {
    this.setPreferenceAsync(name,key,TextJsonSerializer.jsonStringify(value))
  }

  setPreference(name:string,key: string, value: string): void {
    try {
      let options: preferences.Options = { name: name };
      const preferencesHelper = preferences.getPreferencesSync(getContext().getApplicationContext(), options);
      preferencesHelper.put(key, value);
      preferencesHelper.flush();
    } catch (error) {
      console.error(`Failed to save data to preferences: ${error}`);
    }
  }

  async setPreferenceAsync(name:string,key: string, value: string): Promise<void> {
    try {
      let options: preferences.Options = { name: name };
      const preferencesHelper = await preferences.getPreferences(getContext().getApplicationContext(), options);
      preferencesHelper.put(key, value);
      await preferencesHelper.flush();
    } catch (error) {
      console.error(`Failed to save data to preferences: ${error}`);
    }
  }
}

const preferencesManager = new PreferencesManager();
export default preferencesManager;
